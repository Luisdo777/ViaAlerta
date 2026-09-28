import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/admin_auth_service.dart';
import '../../widgets/common.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await adminAuthService.signIn(email: _email.text, password: _password.text);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/admin/home', (route) => false);
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'A recuperação de senha será ativada quando o painel for conectado ao backend.'),
      ),
    );
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
                        icon: const Icon(Icons.chevron_left,
                            color: AppColors.lightBlue, size: 30),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x33C2500A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.orange),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 16, color: AppColors.orangeText),
                            SizedBox(width: 6),
                            Text('PAINEL ADMINISTRATIVO',
                                style: TextStyle(
                                    color: AppColors.orangeText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Acesso administrativo',
                          style: TextStyle(
                              color: AppColors.lightBlue,
                              fontSize: 28,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      const Text('Faça login para acessar o painel administrativo',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(height: 24),
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
                        hint: 'Senha',
                        controller: _password,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: (v) => (v ?? '').isEmpty ? 'Informe sua senha' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: const Text('Esqueceu sua senha?',
                              style: TextStyle(
                                  color: AppColors.orangeText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13)),
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(
                        label: 'Entrar',
                        color: AppColors.navy,
                        loading: _loading,
                        onPressed: _submit,
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
