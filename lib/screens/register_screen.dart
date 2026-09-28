import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await authService.register(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.chevron_left, color: AppColors.lightBlue, size: 30),
                      ),
                      const SizedBox(height: 8),
                      const Text('Criar conta',
                          style: TextStyle(
                              color: AppColors.lightBlue, fontSize: 34, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      const Text('Preencha os dados para criar sua conta',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      const SizedBox(height: 24),
                      AppTextField(
                        hint: 'Nome completo',
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: (v) =>
                            (v ?? '').trim().length < 3 ? 'Informe seu nome completo' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        hint: 'E-mail',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Informe seu e-mail';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        hint: 'Telefone (opcional)',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        hint: 'Senha',
                        controller: _password,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v ?? '').length < 6 ? 'A senha precisa ter ao menos 6 caracteres' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        hint: 'Confirmar senha',
                        controller: _confirm,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            v != _password.text ? 'As senhas não coincidem' : null,
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Cadastrar',
                        color: AppColors.navy,
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Já tem uma conta? ',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Entrar',
                                  style: TextStyle(
                                      color: AppColors.orangeText, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
