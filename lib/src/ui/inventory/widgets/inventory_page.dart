import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
      ),
      body: Center(
        child: Text(
          'Page de gestion des inventaires',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
