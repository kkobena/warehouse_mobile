import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Configuration'),
      ),
      body: Center(
        child: Text(
          'Page de Configuration',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
