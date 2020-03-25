import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/state_and_model/configuration_state.dart';
import 'package:tableau_crud_ui/dialogs.dart';

class ConnectionPage extends StatefulWidget {
  ConnectionPage({this.configState});

  final ConfigurationState configState;

  State<StatefulWidget> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  initState(){
    super.initState();
    _server = TextEditingController(text: widget.configState.server);
    _port = TextEditingController(text: widget.configState.port);
    _username = TextEditingController(text: widget.configState.username);
    _password = TextEditingController(text: widget.configState.password);
    _database = TextEditingController(text: widget.configState.database);
    _schema = TextEditingController(text: widget.configState.schema);
    _table = TextEditingController(text: widget.configState.table);
    _server.addListener(_updateServer);
    _port.addListener(_updatePort);
    _username.addListener(_updateUsername);
    _password.addListener(_updatePassword);
    _database.addListener(_updateDatabase);
    _schema.addListener(_updateSchema);
    _table.addListener(_updateTable);
  }

  void _updateServer() => widget.configState.server = _server.text;
  void _updatePort() => widget.configState.port = _port.text;
  void _updateUsername() => widget.configState.username = _username.text;
  void _updatePassword() => widget.configState.password = _password.text;
  void _updateDatabase() => widget.configState.database = _database.text;
  void _updateSchema() => widget.configState.schema = _schema.text;
  void _updateTable() => widget.configState.table = _table.text;

  dispose(){
    _server.removeListener(_updateServer);
    _port.removeListener(_updatePort);
    _username.removeListener(_updateUsername);
    _password.removeListener(_updatePassword);
    _database.removeListener(_updateDatabase);
    _schema.removeListener(_updateSchema);
    _table.removeListener(_updateTable);
    super.dispose();
  }

  TextEditingController _server;
  TextEditingController _port;
  TextEditingController _username;
  TextEditingController _password;
  TextEditingController _database;
  TextEditingController _schema;
  TextEditingController _table;

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
        TextField(
          controller: _password,
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
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
        RaisedButton(
          child: Text("Test connection"),
          onPressed: () async {
            showDialog(
              context: context,
              child: LoadingDialog(message: "Testing connection..."),
            );
            var error = await widget.configState.testConnection();
            Navigator.of(context).pop();
            if (error == ""){
              await showDialog(
                context: context,
                child: OkDialog(
                  child: Text("Connection successful!"),
                  msgType: MsgType.Success,
                ),
              );
            } else {
              await showDialog(
                context: context,
                child: OkDialog(
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
