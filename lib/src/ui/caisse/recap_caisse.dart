import 'package:flutter/material.dart';

  class RecapCaisse  extends StatefulWidget{
  const RecapCaisse({Key? key}) ;

@override
  State<RecapCaisse> createState() => _RecapCaisseState();
}

class _RecapCaisseState extends State<RecapCaisse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recap Caisse'),
      ),
      body: Center(
        child: Text('Recap Caisse Content Goes Here'),
      ),
    );
  }
}