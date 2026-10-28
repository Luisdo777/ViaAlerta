# ViaAlerta

App mobile (Flutter) para comunicação ágil entre a população e o órgão responsável
pela manutenção viária. O cidadão abre um chamado (buraco, semáforo apagado,
iluminação, calçada etc.) e acompanha o andamento; a equipe de triagem, pelo
painel administrativo, altera o status e encaminha ao órgão responsável.

## Telas

**Cidadão:** boas-vindas, criar conta, entrar, início, nova ocorrência (com GPS,
mapa e fotos), confirmação com protocolo, minhas ocorrências (filtros e busca),
detalhe com histórico e mapa de ocorrências.

**Administrador** (link "Acesso admin? Clique aqui" na tela de boas-vindas):
login administrativo, dashboard com totais e gráfico por tipo, gerenciar
ocorrências, alterar status com observação, detalhe com dados do cidadão,
encaminhamento ao órgão responsável, observação interna e relatórios simples.

## Requisitos

- [Flutter](https://docs.flutter.dev/install) 3.24 ou superior (o projeto foi ajustado com Flutter 3.47 / Dart 3.13).
- Git.
- Para Android: Android Studio (traz o SDK e o emulador) ou um celular com depuração USB ativada.
- Para iOS: um Mac com Xcode.
- Windows: ative o **Modo de desenvolvedor** (`Win + R`, digite `ms-settings:developers`), pois os plugins exigem suporte a links simbólicos.

## Rodar em uma nova máquina (a partir do repositório)

1. Instale o Flutter e confira o ambiente. Tudo o que o `flutter doctor` marcar com ✗ precisa ser resolvido para o alvo que você vai usar (Android ou iOS):

   ```bash
   flutter doctor
   ```

   No Android, se ele pedir as licenças:

   ```bash
   flutter doctor --android-licenses
   ```

2. Clone o repositório e entre na pasta:

   ```bash
   git clone <URL-DO-REPOSITORIO>
   cd <NOME-DA-PASTA>
   ```

3. Baixe as dependências:

   ```bash
   flutter pub get
   ```

4. Veja os dispositivos disponíveis e rode:

   ```bash
   flutter devices
   flutter run
   ```

   Havendo mais de um dispositivo: `flutter run -d <id-do-dispositivo>`.
   A primeira execução no Android demora, pois o Gradle baixa componentes.

5. Se algo falhar, limpe e tente de novo:

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

Para testar o painel administrativo, na tela de boas-vindas toque em "Clique aqui"
(ao lado de "Acesso admin?"). Por enquanto o login é simulado e aceita qualquer
e-mail e senha.

## Criar o projeto do zero a partir destes arquivos

Use este caminho se você tiver apenas a pasta `lib/`, o `pubspec.yaml` e este README
(por exemplo, num zip), sem as pastas `android/` e `ios/`.

```bash
flutter create --org br.com.viaalerta --project-name viaalerta viaalerta_app
```

Depois, copie para dentro de `viaalerta_app`:

- a pasta `lib/` (apague antes a `lib/` gerada pelo Flutter, para não ficar uma `lib` dentro da outra);
- o arquivo `pubspec.yaml` (substituindo o existente);
- este `README.md`.

Apague também o teste padrão `test/widget_test.dart`, que não se aplica a este app.
Em seguida, adicione as permissões abaixo e rode `flutter pub get` e `flutter run`.

### Permissões (obrigatório para GPS, câmera e mapa)

**Android:** em `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>` e antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

**iOS:** em `ios/Runner/Info.plist`, dentro de `<dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Usamos sua localização para marcar onde está o problema.</string>
<key>NSCameraUsageDescription</key>
<string>Usamos a câmera para fotografar o problema.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Usamos suas fotos para anexar à ocorrência.</string>
```

## Backend: Supabase

O app usa o [Supabase](https://supabase.com) (PostgreSQL) para autenticação, banco
de dados e armazenamento das fotos. O esquema completo está em
`supabase/schema.sql`.

### Configurar um projeto do zero

1. Crie uma conta e um projeto em [supabase.com](https://supabase.com) (plano gratuito).
2. No painel do projeto, vá em **SQL Editor > New query**, cole todo o conteúdo
   de `supabase/schema.sql` e clique em **Run**. Isso cria as tabelas, as regras
   de segurança (RLS) e a geração automática do número de protocolo.
3. Vá em **Storage > New bucket**, crie um bucket chamado `occurrence-photos` e
   marque a opção **Public bucket** (as fotos precisam ser lidas sem login).
4. Vá em **Authentication > Providers > Email** e desative **Confirm email**,
   para simplificar os testes (sem isso, cada cadastro exigiria clicar num link
   de confirmação por e-mail).
5. Vá em **Project Settings > API** e copie a **Project URL** e a chave
   **anon public**.
6. Copie `lib/core/supabase_config.example.dart` para `lib/core/supabase_config.dart`
   e cole esses dois valores:

   ```dart
   class SupabaseConfig {
     static const url = 'https://SEU-PROJETO.supabase.co';
     static const anonKey = 'SUA-CHAVE-ANON-PUBLICA';
   }
   ```

   Esse arquivo não deve ir para o Git (veja o `.gitignore`), já que o
   repositório deste projeto é público.

7. Rode `flutter pub get` e depois `flutter run`.

### Criar um usuário administrador

Não existe cadastro de admin dentro do app (só o cidadão se cadastra). Para
criar um:

1. No painel do Supabase, **Authentication > Users > Add user**, preencha e-mail
   e senha e marque **Auto Confirm User**.
2. Copie o **UUID** desse usuário, mostrado na mesma tela.
3. No **SQL Editor**, rode (trocando o valor):

   ```sql
   update public.profiles set role = 'admin' where id = 'COLE-O-UUID-AQUI';
   ```

4. No app, use esse e-mail e senha na tela "Acesso administrativo".

### Limitação desta versão

O login do cidadão e o do admin usam a mesma sessão do Supabase Auth. Se você
entrar como cidadão e, no mesmo aparelho, entrar como admin, a sessão anterior
é substituída. Para testar os dois perfis ao mesmo tempo, use dois aparelhos
(ou um aparelho físico e um emulador) com contas diferentes.

## Estrutura do código

```
lib/
├── main.dart                 rotas do app
├── core/                     tema (cores, fontes) e formatadores
├── models/                   Occurrence, status, tipos e órgãos responsáveis
├── services/                 autenticação, localização e repositório de ocorrências
├── widgets/                  botões, campos, mapa e gráfico reutilizáveis
└── screens/
    ├── (telas do cidadão)
    └── admin/                painel administrativo
```

## O que ainda não existe

- **Notificações push** quando o status de uma ocorrência muda.
- **Recuperação de senha** (o link "Esqueceu sua senha?" ainda só avisa que a função não está pronta).
- **Papel de triagem por convite**: hoje, tornar alguém admin exige rodar um comando SQL manualmente (veja acima).

## Antes de publicar

- Os tiles públicos do OpenStreetMap têm política de uso limitada; em produção use um provedor de mapas próprio ou contratado.
- Desative "Confirm email" só serve para facilitar os testes; em produção, reative a confirmação por e-mail em Authentication > Providers.
- O repositório deste projeto é público; nunca commite o arquivo `lib/core/supabase_config.dart` nem chaves do tipo `service_role` (só a `anon` é segura para o app).
