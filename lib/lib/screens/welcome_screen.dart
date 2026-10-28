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
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.warning_rounded, size: 38, color: AppColors.background),
              ),
              const SizedBox(height: 12),
              const Text('ViaAlerta',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text(
                'Conectando você à cidade\nque precisa de soluções.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.lightBlue, fontSize: 14, fontWeight: FontWeight.w600, height: 1.35),
              ),
              const Spacer(),
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
                      style: TextStyle(color: AppColors.lightBlue, fontSize: 13)),
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
