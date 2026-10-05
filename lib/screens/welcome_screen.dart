import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Image.asset(
                        'assets/images/viaalerta_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              PrimaryButton(
                label: 'Entrar',
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
              const SizedBox(height: 12),
              OutlineButtonX(
                label: 'Criar conta',
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Acesso admin? ',
                      style:
                          TextStyle(color: AppColors.lightBlue, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin/login'),
                    child: const Text(
                      'Clique aqui',
                      style: TextStyle(
                        color: AppColors.orangeText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.orangeText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
