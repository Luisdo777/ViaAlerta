import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'home_tab.dart';
import 'map_tab.dart';
import 'my_occurrences_tab.dart';
import 'profile_tab.dart';

/// Aba selecionada da barra inferior. Pode ser alterada de qualquer tela.
final ValueNotifier<int> shellTabIndex = ValueNotifier<int>(0);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Abas são criadas só quando visitadas (evita pedir GPS antes da hora).
  final Set<int> _built = {0};

  @override
  void initState() {
    super.initState();
    shellTabIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: shellTabIndex,
      builder: (context, index, _) {
        _built.add(index);
        Widget tab(int i, Widget child) => _built.contains(i) ? child : const SizedBox.shrink();

        return Scaffold(
          body: IndexedStack(
            index: index,
            children: [
              tab(0, const HomeTab()),
              tab(1, const MyOccurrencesTab()),
              tab(2, const MapTab()),
              tab(3, const ProfileTab()),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => shellTabIndex.value = i,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.background,
              selectedItemColor: AppColors.lightBlue,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
                BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Ocorrências'),
                BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
              ],
            ),
          ),
        );
      },
    );
  }
}
