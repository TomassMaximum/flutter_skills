import 'package:flutter/material.dart';
import 'package:skill_showcase/presentation/pages/showcase_home_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ShowcaseHomeTab(),
    Center(child: Text('🎞 动画', style: TextStyle(fontSize: 24))),
    Center(child: Text('🌐 网络', style: TextStyle(fontSize: 24))),
    Center(child: Text('⚙️ 设置', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), 
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation, 
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation), 
            child: child)),
            child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex, 
        animationDuration: const Duration(milliseconds: 400),
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.movie_outlined), label: 'Animation'),
          NavigationDestination(icon: Icon(Icons.public_outlined), label: 'Network'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}