-- ViaAlerta — esquema do banco de dados (Supabase / PostgreSQL)
-- Rode este arquivo inteiro em: Supabase > SQL Editor > New query > Run.

-- ========== EXTENSÕES ==========
create extension if not exists "pgcrypto"; -- gera uuid (gen_random_uuid)

-- ========== PERFIS (um por usuário do Supabase Auth) ==========
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  phone text,
  role text not null default 'citizen' check (role in ('citizen', 'admin')),
  created_at timestamptz not null default now()
);

-- ========== OCORRÊNCIAS ==========
-- Gera o número de protocolo automaticamente, ex.: #2026-000124
create sequence if not exists public.occurrences_protocol_seq start 124;

create or replace function public.next_protocol()
returns text
language sql
as $$
  select '#' || extract(year from now())::text || '-' ||
         lpad(nextval('public.occurrences_protocol_seq')::text, 6, '0');
$$;

create table if not exists public.occurrences (
  id uuid primary key default gen_random_uuid(),
  protocol text not null unique default public.next_protocol(),
  type text not null check (type in (
    'pothole', 'trafficLight', 'damagedSign', 'streetLight',
    'damagedSidewalk', 'drainage', 'roadMarking', 'other'
  )),
  description text not null,
  address text not null,
  city_line text not null,
  latitude double precision not null,
  longitude double precision not null,
  status text not null default 'open' check (status in ('open', 'inProgress', 'resolved')),
  department text check (department in (
    'publicWorks', 'streetLighting', 'traffic', 'civilDefense', 'sanitation', 'other'
  )),
  citizen_id uuid not null references auth.users (id),
  citizen_name text not null,
  citizen_email text not null,
  created_at timestamptz not null default now()
);

-- ========== HISTÓRICO DE CADA OCORRÊNCIA ==========
create table if not exists public.occurrence_history (
  id uuid primary key default gen_random_uuid(),
  occurrence_id uuid not null references public.occurrences (id) on delete cascade,
  text text not null,
  created_at timestamptz not null default now()
);

-- ========== FOTOS DE CADA OCORRÊNCIA ==========
create table if not exists public.occurrence_photos (
  id uuid primary key default gen_random_uuid(),
  occurrence_id uuid not null references public.occurrences (id) on delete cascade,
  url text not null,
  created_at timestamptz not null default now()
);

-- ========== FUNÇÃO AUXILIAR: o usuário logado é admin? ==========
-- security definer: consulta a tabela ignorando a própria política de RLS,
-- evitando que a política de 'profiles' vire uma referência circular.
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ========== CRIA O PERFIL AUTOMATICAMENTE AO CADASTRAR UM USUÁRIO ==========
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, name, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data ->> 'phone',
    'citizen'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ========== SEGURANÇA (Row Level Security) ==========
alter table public.profiles enable row level security;
alter table public.occurrences enable row level security;
alter table public.occurrence_history enable row level security;
alter table public.occurrence_photos enable row level security;

-- profiles: cada um vê e edita o próprio perfil; admin vê todos.
create policy "profiles_select" on public.profiles
  for select using (auth.uid() = id or public.is_admin());
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- occurrences: cidadão vê e cria as próprias; admin vê e atualiza todas.
create policy "occurrences_select" on public.occurrences
  for select using (auth.uid() = citizen_id or public.is_admin());
create policy "occurrences_insert" on public.occurrences
  for insert with check (auth.uid() = citizen_id);
create policy "occurrences_update_admin" on public.occurrences
  for update using (public.is_admin());

-- occurrence_history: visível e editável por quem pode ver a ocorrência.
create policy "history_select" on public.occurrence_history
  for select using (
    exists (
      select 1 from public.occurrences o
      where o.id = occurrence_id and (o.citizen_id = auth.uid() or public.is_admin())
    )
  );
create policy "history_insert" on public.occurrence_history
  for insert with check (
    exists (
      select 1 from public.occurrences o
      where o.id = occurrence_id and (o.citizen_id = auth.uid() or public.is_admin())
    )
  );

-- occurrence_photos: cidadão dono sobe as fotos; todos que veem a ocorrência leem.
create policy "photos_select" on public.occurrence_photos
  for select using (
    exists (
      select 1 from public.occurrences o
      where o.id = occurrence_id and (o.citizen_id = auth.uid() or public.is_admin())
    )
  );
create policy "photos_insert" on public.occurrence_photos
  for insert with check (
    exists (
      select 1 from public.occurrences o
      where o.id = occurrence_id and o.citizen_id = auth.uid()
    )
  );

-- ========== ARMAZENAMENTO DAS FOTOS ==========
-- Antes de rodar esta parte, crie o bucket pelo painel:
-- Storage > New bucket > nome "occurrence-photos" > marque "Public bucket".
create policy "occurrence_photos_upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'occurrence-photos');

-- ========== COMO TORNAR UM USUÁRIO ADMINISTRADOR ==========
-- 1. Crie o usuário em Authentication > Users > Add user (marque "Auto Confirm User").
-- 2. Copie o UUID dele na mesma tela e rode (trocando o valor):
-- update public.profiles set role = 'admin' where id = 'COLE-O-UUID-AQUI';
