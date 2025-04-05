import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'calendar_screen.dart';
import 'shop_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List of the screens to navigate between
  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    CalendarScreen(),
    ShopScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for colors

    return Scaffold(
      // Body displays the selected screen from the list
      body: IndexedStack(
        // Use IndexedStack to preserve screen state
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        // Use theme colors for consistency
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        onTap: _onItemTapped,
        // Optional: Customize background, elevation etc.
        // backgroundColor: theme.colorScheme.surfaceContainerHighest,
        // type: BottomNavigationBarType.fixed, // Or .shifting
      ),
    );
  }
}
