import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/state_and_model/bloc_provider.dart';
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
    if (widget.configState.password.length > 0) {
      _password = TextEditingController(text: "          ");
    } else {
      _password = TextEditingController(text: "");
    }
    _database = TextEditingController(text: widget.configState.database);
    _schema = TextEditingController(text: widget.configState.schema);
    _table = TextEditingController(text: widget.configState.table);
    _server.addListener(_updateServer);
    _port.addListener(_updatePort);
    _username.addListener(_updateUsername);
    _database.addListener(_updateDatabase);
    _schema.addListener(_updateSchema);
    _table.addListener(_updateTable);
  }

  void _updateServer() => widget.configState.server = _server.text;
  void _updatePort() => widget.configState.port = _port.text;
  void _updateUsername() => widget.configState.username = _username.text;
  void _updateDatabase() => widget.configState.database = _database.text;
  void _updateSchema() => widget.configState.schema = _schema.text;
  void _updateTable() => widget.configState.table = _table.text;

  dispose(){
    _server.removeListener(_updateServer);
    _port.removeListener(_updatePort);
    _username.removeListener(_updateUsername);
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
        InkWell(
          onTap: () async {
            var newPassword = await showDialog(
              context: context,
              builder: (context) => PasswordDialog(),
            );
            if (newPassword == null) return;
            setState((){
              if (newPassword.length > 0){
                _password.text = "          ";
              } else {
                _password.text = "";
              }
              widget.configState.password = newPassword;
            });
          },
          child: IgnorePointer(
            child: TextField(
              enabled: false,
              readOnly: true,
              controller: _password,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
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
            var error = await widget.configState.testConnection();
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

  final TextEditingController _controller = TextEditingController(text: "");

  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
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
                    onPressed: () async => await onPasswordClick(context, state),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future onPasswordClick(BuildContext context, ConfigurationState state) async {
    if (_controller.text == "") {
      Navigator.of(context).pop("");
      return;
    }
    showDialog(
      context: context,
      builder: (context) => LoadingDialog(message: "encrypting password..."),
    );
    var response = await state.encryptPassword(_controller.text);
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

