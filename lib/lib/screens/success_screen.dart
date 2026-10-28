import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.protocol});
  final String protocol;

  void _backToShell(BuildContext context, int tab) {
    shellTabIndex.value = tab;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToShell(context, 0);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F4A2A),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF1B9A4B),
                      child: Icon(Icons.check, size: 36, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Ocorrência enviada\ncom sucesso!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.lightBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sua ocorrência foi registrada\ne recebeu o número',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.blue),
                  ),
                  child: Text(protocol,
                      style: const TextStyle(
                          color: AppColors.lightBlue, fontSize: 22, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Você pode acompanhar o status\nna seção "Minhas ocorrências".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Ver minhas ocorrências',
                  color: AppColors.navy,
                  onPressed: () => _backToShell(context, 1),
                ),
                const SizedBox(height: 12),
                OutlineButtonX(
                  label: 'Voltar para o início',
                  borderColor: AppColors.blue,
                  textColor: AppColors.lightBlue,
                  onPressed: () => _backToShell(context, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
