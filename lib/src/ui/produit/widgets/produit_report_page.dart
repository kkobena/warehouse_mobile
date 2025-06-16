import 'package:flutter/material.dart';

class ProduitReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ProduitReportPage Management'),
      ),
      body: Center(
        child: Text(
          'Page de gestion ProduitReportPage',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
