
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/settings.dart';

import '../io/get_metadata.dart';

class GeneralSettingsPage extends StatefulWidget {
  GeneralSettingsPage({required this.settings, required this.io});
  final Settings settings;
  final IoManager io;

  createState()=>_GeneralSettingsPageState();
}

const _inputWidth = 60.0;

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {

  late TextEditingController pageSizeController;
  late TextEditingController _apiKey;
  late TextEditingController _connection;
  late TextEditingController _table;

  initState(){
    super.initState();
    pageSizeController = TextEditingController(text: widget.settings.defaultPageSize.toString());
    _apiKey = TextEditingController(text: widget.settings.apiKey);
    _apiKey.addListener(saveApiKey);
    _connection = TextEditingController(text: widget.settings.connection);
    _connection.addListener(saveConnection);
    _table = TextEditingController(text: widget.settings.table);
    _table.addListener(saveTable);
  }

  saveApiKey()=>widget.settings.apiKey = _apiKey.text;
  saveConnection()=>widget.settings.connection = _connection.text;
  saveTable()=>widget.settings.table = _table.text;

  dispose() {
    _apiKey.removeListener(saveApiKey);
    _connection.removeListener(saveConnection);
    _table.removeListener(saveTable);
    super.dispose();
  }

  Future<String> testConnection() async {
    widget.settings.apiKey = _apiKey.text;
    widget.settings.connection = _connection.text;
    widget.settings.table = _table.text;


    var queryResult = await getMetadata(widget.io.db, widget.settings);
    if (queryResult.hasError){
      print(queryResult.error);
    } else {
      widget.settings.tableColumns = queryResult.data?.columnNames ?? [];
    }
    return queryResult.error;
  }

  Widget build(BuildContext context) {
    return ListView(
      itemExtent: 60,
      children: [
        Row(
          children: [
            Expanded(
              child: Text("Default page size:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: TextField(
                controller: pageSizeController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                onChanged: (newValueStr) {
                  var newValue = int.tryParse(newValueStr);
                  if (newValue == null) {
                    return;
                  }
                  widget.settings.defaultPageSize = newValue;
                },
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text("Enable insert:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: Checkbox(
                value: widget.settings.enableInsert,
                onChanged: (newValue) {
                  if (newValue != null){
                    setState(()=>widget.settings.enableInsert = newValue);
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text("Enable update:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: Checkbox(
                value: widget.settings.enableUpdate,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(()=>widget.settings.enableUpdate = newValue);
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text("Enable delete:"),
            ),
            SizedBox(
              width: _inputWidth,
              child: Checkbox(
                value: widget.settings.enableDelete,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(()=>widget.settings.enableDelete = newValue);
                  }
                },
              ),
            ),
          ],
        ),
        TextField(
          controller: _apiKey,
          decoration: InputDecoration(labelText: "API Key"),
        ),
        TextField(
          controller: _connection,
          decoration: InputDecoration(labelText: "Connection"),
        ),
        TextField(
          controller: _table,
          decoration: InputDecoration(labelText: "Table"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: ElevatedButton(
            child: Text("Test connection"),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => LoadingDialog(message: "Get metadata..."),
              );
              var error = await testConnection();
              Navigator.of(context).pop();
              if (error == ""){
                await showDialog(
                  context: context,
                  builder: (context) => OkDialog(
                    child: Text("Connection successful!"),
                    msgType: MsgType.Success,
                  ),
                );
              } else {
                await showDialog(
                  context: context,
                  builder: (context) => OkDialog(
                    child: Text("Error: $error"),
                    msgType: MsgType.Error,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}