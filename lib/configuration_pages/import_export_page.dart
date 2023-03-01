import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class ImportExportPage extends StatefulWidget {
  ImportExportPage({required this.settings});
  final Settings settings;

  State<StatefulWidget> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {

  TextEditingController paste = TextEditingController(text: '');
  String importMessage = '';

  Widget build(BuildContext context) {
    var settingsJson = widget.settings.toJson();
    paste.text = settingsJson;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
              labelText: "Configuration"
          ),
          controller: paste,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text("Load configuration from text"),
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
