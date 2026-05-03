import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'scanner_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';
import '../providers/language_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // Default to Home/Dashboard

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClassifierScreen(),
    const MapScreen(),
    const ProfileScreen(),
  ];




  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF0F1722),
          indicatorColor: const Color(0xFF00E676).withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00E676));
            }
            return GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white54);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const ImageIcon(AssetImage('assets/icons/home_perfect.png'), color: Colors.white54),
              selectedIcon: const ImageIcon(AssetImage('assets/icons/home_perfect.png'), color: Color(0xFF00E676)),
              label: lang.getText('nav_home'),
            ),
            NavigationDestination(
              icon: const ImageIcon(AssetImage('assets/icons/Scan Icon.png'), color: Colors.white54),
              selectedIcon: const ImageIcon(AssetImage('assets/icons/Scan Icon.png'), color: Color(0xFF00E676)),
              label: lang.getText('nav_scanner'),
            ),
            NavigationDestination(
              icon: const ImageIcon(AssetImage('assets/icons/map_perfect.png'), color: Colors.white54),
              selectedIcon: const ImageIcon(AssetImage('assets/icons/map_perfect.png'), color: Color(0xFF00E676)),
              label: lang.getText('nav_map'),
            ),
            NavigationDestination(
              icon: const ImageIcon(AssetImage('assets/icons/profile_perfect.png'), color: Colors.white54),
              selectedIcon: const ImageIcon(AssetImage('assets/icons/profile_perfect.png'), color: Color(0xFF00E676)),
              label: lang.getText('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
