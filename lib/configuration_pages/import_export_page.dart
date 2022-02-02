
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class ImportExportPage extends StatefulWidget {
  ImportExportPage({this.settings});
  final Settings settings;

  State<StatefulWidget> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {

  TextEditingController paste = TextEditingController(text: '');
  String importMessage = '';

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 20),
        ElevatedButton(
          child: Text("Copy configuration to clipboard"),
          onPressed: (){
            Clipboard.setData(ClipboardData(text: widget.settings.toJson()));
            setState(()=>importMessage = '');
          },
        ),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
              labelText: "Paste configuration"
          ),
          controller: paste,
        ),
        ElevatedButton(
          child: Text("Load configuration from pasted text"),
          onPressed: (){
            var newSettings = Settings.fromJson(paste.text);
            widget.settings.copyFrom(newSettings);
            setState(()=>importMessage = 'settings updated');
          },
        ),
        SizedBox(height: 10),
        Text(importMessage, textAlign: TextAlign.center),
      ],
    );
  }
}
