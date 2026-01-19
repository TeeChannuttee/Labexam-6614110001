import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/look_provider.dart';
import '../widgets/desktop_layout.dart';
import 'all_looks_screen.dart';
import 'add_look_screen.dart';
import 'swipe_mode_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AllLooksScreen(),
    AddLookScreen(),
    SwipeModeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LookProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleDarkMode(),
            tooltip: 'Toggle Dark Mode',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: DesktopLayout(
        currentIndex: _currentIndex,
        onNavigationChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        child: _screens[_currentIndex],
      ),
    );
  }
}

