import 'package:flutter/material.dart';

class TvaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TVA Management'),
      ),
      body: Center(
        child: Text(
          'Page de gestion TVAS',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
