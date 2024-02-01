import 'package:exchange_rate_analyser/middle_rate_page.dart';
import 'package:flutter/material.dart';
import 'package:exchange_rate_analyser/calendar_page.dart';
import 'package:exchange_rate_analyser/graph_page.dart';
import 'package:exchange_rate_analyser/components/bottom_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchange Rate Analyser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          titleTextStyle: TextStyle(color: Colors.deepPurple),
          elevation: 0,
        ),
      ),
      home: const _RootPage(),
    );
  }
}

class _RootPage extends StatefulWidget {
  const _RootPage();

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<_RootPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const MiddleRatePage(),
    const CalendarPage(),
    const GraphPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rate Analyser'),
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNav(
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
