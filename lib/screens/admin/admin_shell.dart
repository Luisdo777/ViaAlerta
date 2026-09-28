import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import 'admin_dashboard_tab.dart';
import 'admin_occurrences_tab.dart';
import 'admin_profile_tab.dart';
import 'admin_reports_tab.dart';

final ValueNotifier<int> adminTabIndex = ValueNotifier<int>(0);

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final Set<int> _built = {0};

  @override
  void initState() {
    super.initState();
    adminTabIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: adminTabIndex,
      builder: (context, index, _) {
        _built.add(index);
        Widget tab(int i, Widget child) =>
            _built.contains(i) ? child : const SizedBox.shrink();

        return Scaffold(
          body: IndexedStack(
            index: index,
            children: [
              tab(0, const AdminDashboardTab()),
              tab(1, const AdminOccurrencesTab()),
              tab(2, const AdminReportsTab()),
              tab(3, const AdminProfileTab()),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => adminTabIndex.value = i,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.background,
              selectedItemColor: AppColors.lightBlue,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Dashboard'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.description_outlined), label: 'Ocorrências'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Relatórios'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
              ],
            ),
          ),
        );
      },
    );
  }
}
