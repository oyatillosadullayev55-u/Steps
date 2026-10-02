import 'package:flutter/material.dart';

import '../services/tracking_service.dart';
import 'history_page.dart';
import 'home_page.dart';

/// Pastki navigatsiya: "Bugun" va "Tarix" sahifalari orasida almashadi.
/// TrackingService shu yerda yaratiladi va ikkala sahifaga beriladi.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _service = TrackingService();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(service: _service),
          HistoryPage(service: _service),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.directions_walk), label: 'Bugun'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Tarix'),
        ],
      ),
    );
  }
}