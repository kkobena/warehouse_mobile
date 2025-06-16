import 'package:flutter/material.dart';

class BalancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Management'),
      ),
      body: Center(
        child: Text(
          'Page de gestion Balance',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
