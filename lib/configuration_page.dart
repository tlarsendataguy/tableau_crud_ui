
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/configuration_state.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/settings.dart';

class ConfigurationPage extends StatelessWidget{
  Widget build(BuildContext context) {
    var configState = BlocProvider.of<ConfigurationState>(context);
    var appState = BlocProvider.of<AppState>(context);

    return StreamBuilder(
      stream: configState.page,
      builder: (context, AsyncSnapshot<Page> snapshot){
        if (!snapshot.hasData){
          return Center(child: Text('Loading...'));
        }

        Widget content;
        var page = snapshot.data;

        switch (page){
          case Page.connection:
            content = ConnectionPage(configState: configState);
            break;
          case Page.selectFields:
            content = SelectFieldsPage();
            break;
          case Page.orderByFields:
            content = OrderByFieldsPage();
            break;
          case Page.filters:
            content = FiltersPage();
            break;
          default:
            content = Center(child: Text("Invalid page"));
        }
        return Container(
          color: Color.fromARGB(255, 220, 220, 220),
          child: Row(
            children: [
              Container(
                width: 60,
                child: Card(
                  child: ListView(
                    children: [
                      Tooltip(
                        message: 'Save settings and go back',
                        child: IconButton(
                          focusNode: FocusNode(skipTraversal: true),
                          icon: Icon(Icons.save),
                          onPressed: () async {
                            var settings = configState.generateSettings();
                            var error = settings.validate();
                            if (error != ''){
                              await showDialog(
                                context: context,
                                child: OkDialog(
                                  child: Text("WARNING! Settings not saved because of the following error: $error"),
                                  msgType: MsgType.Error,
                                ),
                              );
                              return;
                            }
                            await configState.tIo.saveSettings(settings.toJson());
                            appState.updateSettings(settings);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Tooltip(
                        message: 'Go back without saving',
                        child: IconButton(
                          focusNode: FocusNode(skipTraversal: true),
                          icon: Icon(Icons.cancel),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Container(height: 40),
                      PageButton(goToPage: Page.connection, currentPage: page),
                      PageButton(goToPage: Page.selectFields, currentPage: page),
                      PageButton(goToPage: Page.orderByFields, currentPage: page),
                      PageButton(goToPage: Page.filters, currentPage: page),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FiltersPage extends StatefulWidget {
  createState()=>_FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {

  String selectedWorksheet = '';
  List<TableauFilter> worksheetFilters = [];

  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);

    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Center(child: Text("Worksheets:")),
                Expanded(
                  child: ListView(
                  children: state.worksheets.map((e) =>
                    Card(
                      color: e == selectedWorksheet ? Colors.lightBlueAccent : null,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(e),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () async {
                                worksheetFilters = await state.getFilters(e);
                                setState(() {
                                  selectedWorksheet = e;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              Center(child: Text("Worksheet filters:")),
                Expanded(
                  child: ListView(
                  children: worksheetFilters.map((e) =>
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(e.fieldName),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () async {
                                  var mapsTo = await showDialog(context: context, child: ChooseColumnDialog("Filter on [${e.fieldName}] from worksheet [$selectedWorksheet] maps to:"));
                                  if (mapsTo == '' || mapsTo == null) return;
                                  state.addFilter(
                                    worksheet: selectedWorksheet,
                                    fieldName: e.fieldName,
                                    mapsTo: mapsTo,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: <Widget>[
              Center(child: Text("Mapped filters:")),
              Expanded(
                child: StreamBuilder(
                  stream: state.filters,
                  builder: (context, AsyncSnapshot<List<Filter>> snapshot){
                    if (!snapshot.hasData){
                      return Container();
                    }
                    var filters = snapshot.data;
                    return ListView(
                      children: filters.map((e) =>
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: (){
                                      state.removeFilter(
                                        worksheet: e.worksheet,
                                        fieldName: e.fieldName,
                                        mapsTo: e.mapsTo,
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Text("Filter on [${e.fieldName}] from worksheet [${e.worksheet}] maps to [${e.mapsTo}]"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OrderByFieldsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return ItemSelector<String>(
      leftLabel: "Available fields:",
      sourceStream: state.columnNames,
      sourceItemBuilder: (context, sourceField){
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(sourceField),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: ()=>state.addOrderByField(sourceField),
            ),
          ],
        );
      },
      rightLabel: "Order by:",
      selectorStream: state.orderByFields,
      selectorItemBuilder: (context, orderByField){
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: ()=>state.removeOrderByField(orderByField),
            ),
            Expanded(child: Text(orderByField)),
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: ()=>state.moveOrderByFieldUp(orderByField),
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: ()=>state.moveOrderByFieldDown(orderByField),
            ),
          ],
        );
      },
    );
  }
}

class SelectFieldsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return ItemSelector<String>(
      leftLabel: "Available fields:",
      sourceStream: state.columnNames,
      sourceItemBuilder: (context, sourceField){
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(sourceField),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: ()=>state.addSelectField(sourceField),
            ),
          ],
        );
      },
      rightFlex: 2,
      rightLabel: "Selected fields:",
      selectorStream: state.selectFields,
      selectorItemBuilder: (context, selectedField){
        var editMode = state.getSelectFieldEditMode(selectedField);
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                state.removeSelectField(selectedField);
                state.removePrimaryKeyField(selectedField);
              },
            ),
            Expanded(child: Text(selectedField)),
            Tooltip(
              message: "The data type to use for inserting and updating values",
              child: DropdownButton(
                value: editMode,
                items: [
                  DropdownMenuItem(value: editNone, child: Text(editNone)),
                  DropdownMenuItem(value: editText, child: Text(editText)),
                  DropdownMenuItem(value: editDate, child: Text(editDate)),
                  DropdownMenuItem(value: editInteger, child: Text(editInteger)),
                  DropdownMenuItem(value: editNumber, child: Text(editNumber)),
                  DropdownMenuItem(value: editBool, child: Text(editBool)),
                ],
                onChanged: (newValue)=>
                    state.updateSelectFieldEditMode(selectedField, newValue),
              ),
            ),
            StreamBuilder(
              stream: state.primaryKey,
              builder: (context, AsyncSnapshot<List<String>> pkSnapshot){
                if (!pkSnapshot.hasData){
                  return Container();
                }
                var pk = pkSnapshot.data;
                return Tooltip(
                  message: "Field is part of the primary key?",
                  child: Row(
                    children: [
                      Checkbox(
                        value: pk.contains(selectedField),
                        onChanged: (newValue){
                          if (newValue){
                            state.addPrimaryKeyField(selectedField);
                          } else {
                            state.removePrimaryKeyField(selectedField);
                          }
                        },
                      ),
                      Text("PK"),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: ()=>state.moveSelectFieldUp(selectedField),
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: ()=>state.moveSelectFieldDown(selectedField),
            ),
          ],
        );
      },
    );
  }
}

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

class PageButton extends StatelessWidget{
  PageButton({this.goToPage, this.currentPage});
  final Page goToPage;
  final Page currentPage;

  @override
  Widget build(BuildContext context) {
    var configState = BlocProvider.of<ConfigurationState>(context);
    String message;
    IconData icon;
    Color color;

    switch (goToPage){
      case Page.connection:
        message = "Connection info";
        icon = Icons.format_list_bulleted;
        break;
      case Page.selectFields:
        message = "Select fields";
        icon = Icons.table_chart;
        break;
      case Page.orderByFields:
        message = "Order by";
        icon = Icons.sort;
        break;
      case Page.filters:
        message = "Map filters";
        icon = Icons.filter_list;
        break;
    }

    return Tooltip(
      message: message,
      child: Container(
        width: 48,
        height: 48,
        child: goToPage == currentPage ?
        Icon(icon, color: Colors.blue) :
        IconButton(
          focusNode: FocusNode(skipTraversal: true),
          color: color,
          icon: Icon(icon),
          onPressed: goToPage == currentPage ? null :
            ()=>configState.goToPage(goToPage),
        ),
      ),
    );
  }
}

typedef Widget ItemSelectorBuilder<T>(BuildContext context, T item);

class ItemSelector<T> extends StatelessWidget {
  ItemSelector({this.sourceStream, this.sourceItemBuilder, this.selectorStream, this.selectorItemBuilder,this.leftLabel,this.rightLabel, this.leftFlex=1, this.rightFlex=1});
  final Stream<List<T>> sourceStream;
  final Stream<List<T>> selectorStream;
  final ItemSelectorBuilder<T> sourceItemBuilder;
  final ItemSelectorBuilder<T> selectorItemBuilder;
  final String leftLabel;
  final String rightLabel;
  final int leftFlex;
  final int rightFlex;

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: selectorStream,
      builder: (context, AsyncSnapshot<List<T>> selectSnapshot){
        if (!selectSnapshot.hasData) {
          return Center(child: Text("No data"));
        }
        var selected = selectSnapshot.data;
        return Row(
          children: [
            Expanded(
              flex: leftFlex,
              child: Column(
                children: [
                  Center(child: Text(leftLabel)),
                  Expanded(child:
                    StreamBuilder(
                      stream: sourceStream,
                      builder: (context, AsyncSnapshot<List<T>> sourceSnapshot){
                        if (!sourceSnapshot.hasData) {
                          return Center(child: Text("No data"));
                        }
                        var source = List<T>.from(sourceSnapshot.data);
                        for (var selectedItem in selected){
                          source.remove(selectedItem);
                        }
                        return ListView(
                          children: source.map((sourceItem)=>
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: sourceItemBuilder(context, sourceItem),
                                ),
                              ),
                          ).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: rightFlex,
              child: Column(
                children: [
                  Center(child: Text(rightLabel)),
                  Expanded(
                    child: ListView(
                      children: selected.map((sourceItem)=>
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: selectorItemBuilder(context, sourceItem),
                            ),
                          ),
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChooseColumnDialog extends StatefulWidget{
  ChooseColumnDialog(this.header);
  final String header;
  State<StatefulWidget> createState() => _ChooseColumnDialogState();
}

class _ChooseColumnDialogState extends State<ChooseColumnDialog>{
  var selectedColumn = '';

  Widget build(BuildContext context) {
    var state = BlocProvider.of<ConfigurationState>(context);
    return Dialog(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(widget.header),
                    Expanded(
                      child: StreamBuilder(
                        stream: state.columnNames,
                        builder: (context, AsyncSnapshot<List<String>> snapshot){
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return ListView(
                            children: snapshot.data.map((e) =>
                            FlatButton(
                              color: e == selectedColumn ? Colors.lightBlueAccent : null,
                              child: Text(e),
                              onPressed: ()=>setState(()=>selectedColumn=e),
                            )).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: ()=>Navigator.of(context).pop(""),
                ),
                RaisedButton(
                  child: Text("Select"),
                  onPressed: selectedColumn == "" ?
                    null :
                    ()=>Navigator.of(context).pop(selectedColumn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}