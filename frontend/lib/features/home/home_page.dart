import 'package:aura_frontend/features/contract/contrato_page.dart';
import 'package:aura_frontend/features/home/selecao_subaba_page.dart';
import 'package:aura_frontend/features/pagamentos/pagamentos_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../discover/discover_page.dart';
import '../../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DiscoverPage(),
    const ContratoListPage(),
    const PagamentosListPage(),
    const SelecaoSubabaPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: HomeBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
