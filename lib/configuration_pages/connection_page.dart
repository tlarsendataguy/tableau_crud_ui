import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/io/get_metadata.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/parse_responses.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class ConnectionPage extends StatefulWidget {
  ConnectionPage({this.io, this.settings});

  final IoManager io;
  final Settings settings;

  State<StatefulWidget> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {

  void loadSettings() {
    _server = TextEditingController(text: widget.settings.server);
    _server.addListener(()=>updateServer);
    _port = TextEditingController(text: widget.settings.port);
    _username = TextEditingController(text: widget.settings.username);
    _database = TextEditingController(text: widget.settings.database);
    _schema = TextEditingController(text: widget.settings.schema);
    _table = TextEditingController(text: widget.settings.table);
  }

  void updateServer()=>widget.settings.server = _server.text;
  void updatePort()=>widget.settings.port = _port.text;
  void updateUsername()=>widget.settings.username = _username.text;
  void updateDatabase()=>widget.settings.database = _database.text;
  void updateSchema()=>widget.settings.schema = _schema.text;
  void updateTable()=>widget.settings.table = _table.text;

  initState() {
    super.initState();
    loadSettings();
  }

  dispose() {
    _server.removeListener(updateServer);
    _port.removeListener(updatePort);
    _username.removeListener(updateUsername);
    _database.removeListener(updateDatabase);
    _schema.removeListener(updateSchema);
    _table.removeListener(updateTable);
    super.dispose();
  }

  TextEditingController _server;
  TextEditingController _port;
  TextEditingController _username;
  String _password = '';
  TextEditingController _database;
  TextEditingController _schema;
  TextEditingController _table;

  Future<String> testConnection() async {
    var queryResult = await getMetadata(widget.io.db, widget.settings);
    if (queryResult.hasError){
      print(queryResult.error);
    } else {
      widget.settings.tableColumns = queryResult.data.columnNames;
    }
    return queryResult.error;
  }

  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        TextField(
          controller: _server,
          decoration: InputDecoration(labelText: "Server"),
        ),
        TextField(
          controller: _port,
          decoration: InputDecoration(labelText: "Port"),
        ),
        TextField(
          controller: _username,
          decoration: InputDecoration(labelText: "Username"),
        ),
        InkWell(
          onTap: () async {
            var newPassword = await showDialog(
              context: context,
              builder: (context) => PasswordDialog(widget.io.db),
            );
            if (newPassword == null) return;
            setState((){
              if (newPassword.length > 0){
                _password = "**********";
              } else {
                _password = "";
              }
              widget.settings.password = newPassword;
            });
          },
          child: IgnorePointer(
            child: InputDecorator(
              child: Text(_password),
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
          ),
        ),
        TextField(
          controller: _database,
          decoration: InputDecoration(labelText: "Database"),
        ),
        TextField(
          controller: _schema,
          decoration: InputDecoration(labelText: "Schema"),
        ),
        TextField(
          controller: _table,
          decoration: InputDecoration(labelText: "Table"),
        ),
        ElevatedButton(
          child: Text("Test connection"),
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) => LoadingDialog(message: "Testing connection..."),
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
      ],
    );
  }
}

class PasswordDialog extends StatelessWidget {
  PasswordDialog(this.dbIo);
  final DbIo dbIo;

  final TextEditingController _controller = TextEditingController(text: "");

  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                controller: _controller,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: ()=>Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    child: Text("Submit"),
                    onPressed: () async => await onPasswordClick(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future onPasswordClick(BuildContext context) async {
    if (_controller.text == "") {
      Navigator.of(context).pop("");
      return;
    }
    showDialog(
      context: context,
      builder: (context) => LoadingDialog(message: "encrypting password..."),
    );
    var response = parsePassword(await dbIo.encryptPassword(_controller.text));
    Navigator.of(context).pop();
    if (response.hasError) {
      await showDialog(
        context: context,
        builder: (context) => OkDialog(
          child: Text("Error: ${response.error}"),
          msgType: MsgType.Error,
        ),
      );
      return;
    }
    Navigator.of(context).pop(response.data);
  }
}

