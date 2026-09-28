import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.user;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Perfil',
              style: TextStyle(
                  color: AppColors.lightBlue, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.orange,
              child: Text(user?.initial ?? '?',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(user?.name ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 24),
          _InfoTile(icon: Icons.mail_outline, label: 'E-mail', value: user?.email ?? '-'),
          const SizedBox(height: 10),
          _InfoTile(icon: Icons.phone_outlined, label: 'Telefone', value: user?.phone ?? 'Não informado'),
          const SizedBox(height: 32),
          OutlineButtonX(
            label: 'Sair da conta',
            borderColor: AppColors.orangeText,
            textColor: AppColors.orangeText,
            onPressed: () {
              authService.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightBlue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
