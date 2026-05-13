import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/sfttv_logo.dart';
import 'home_dashboard.dart';
import 'settings_screen.dart';
import 'tools_hub_screen.dart';
import 'guides_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
          title: _index == 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SfttvLogo(size: 36),
                    SizedBox(width: 10),
                    Text(
                      'Send files to TV',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : Text(
                  _index == 1 ? 'Tools' : 'Guides',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
        body: IndexedStack(
          index: _index,
          children: const [
            HomeDashboard(),
            ToolsHubScreen(),
            GuidesScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.build_outlined),
              selectedIcon: Icon(Icons.build),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Guides',
            ),
          ],
        ),
      ),
    );
  }
}
