import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard')),
            ListTile(leading: Icon(Icons.point_of_sale), title: Text('Sales')),
            ListTile(leading: Icon(Icons.inventory_2), title: Text('Inventory')),
            ListTile(leading: Icon(Icons.people), title: Text('Customers')),
            ListTile(leading: Icon(Icons.receipt_long), title: Text('Orders')),
            ListTile(leading: Icon(Icons.bar_chart), title: Text('Reports')),
            ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
          ],
        ),
      ),
    );
  }
}
