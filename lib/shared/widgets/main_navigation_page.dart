import 'package:flutter/material.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/features/chats/presentation/pages/chats_page.dart';
import 'package:unilost_found/features/home/presentation/pages/home_page.dart';
import 'package:unilost_found/features/profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  final AppSettingsController settingsController;

  const MainNavigationPage({
    super.key,
    required this.settingsController,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const ChatsPage(),
      ProfilePage(settingsController: widget.settingsController),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}