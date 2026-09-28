import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/admin_auth_service.dart';
import '../../widgets/common.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = adminAuthService.admin;
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
              child: Text(admin?.initial ?? 'AD',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text('Equipe de triagem',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.mail_outline, color: AppColors.lightBlue),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('E-mail',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      Text(admin?.email ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlineButtonX(
            label: 'Sair do painel',
            borderColor: AppColors.orangeText,
            textColor: AppColors.orangeText,
            onPressed: () {
              adminAuthService.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
