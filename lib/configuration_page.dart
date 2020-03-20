
import 'package:flutter/material.dart';

class ConfigurationPage extends StatelessWidget{
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text("Back"),
        onPressed: ()=>Navigator.of(context).pop(),
      ),
    );
  }
}
