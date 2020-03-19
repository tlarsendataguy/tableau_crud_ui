import 'dart:html';

import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/db_web_io.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/response_objects.dart';
import 'package:tableau_crud_ui/settings.dart';
import 'package:tableau_crud_ui/tableau_extension_io.dart';

void main() async {
  var tIo = TableauMockIo();
  //var tIo = TableauExtensionIo();
  await tIo.initialize();
  var dbIo = DbMockSuccessIo();
  //var dbIo = DbWebIo();
  var state = AppState(tIo: tIo, dbIo: dbIo);
  await state.initialize();
  runApp(
    BlocProvider<AppState>(
      child: MyApp(),
      bloc: state,
    ),
  );
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tableau CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (context)=>Home(),
        "/configure": (context)=>ConfigurePage(),
      },
    );
  }
}

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);

    Widget configureButton = null;
    if (state.tableauContext == 'desktop'){
      configureButton = Tooltip(
        message: "Configure extension",
        child: IconButton(
          icon: Icon(Icons.settings),
          onPressed: ()=>Navigator.of(context).pushNamed("/configure"),
        ),
      );
    }

    var buttonBar = Row(
      children: [
        Tooltip(
          message: "Add record",
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: null,
          ),
        ),
        Tooltip(
          message: "Edit record",
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: null,
          ),
        ),
        Tooltip(
          message: "Delete record",
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: null,
          ),
        ),
        Tooltip(
          message: "Refresh table",
          child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              var error = await state.readTable();
              if (error != ""){
                await showDialog(
                  context: context,
                  child: Dialog(
                    child: Container(
                      width: 300,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(error, softWrap: true),
                            ),
                          ),
                          RaisedButton(
                            child: Text("ok"),
                            onPressed: ()=>Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          child: Container(),
        ),
        configureButton,
      ],
    );

    return Material(
      child: Column(
        children: <Widget>[
          buttonBar,
          Expanded(child: DataViewer()),
        ],
      ),
    );
  }
}

class ConfigurePage extends StatelessWidget{
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text("Back"),
        onPressed: ()=>Navigator.of(context).pop(),
      ),
    );
  }
}

class DataViewer extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.readLoaders,
      builder: (context, AsyncSnapshot<int> snapshot){
        if (!snapshot.hasData || snapshot.data > 0){
          return Center(child: Text("Loading data..."));
        }

        return StreamBuilder(
          stream: state.data,
          builder: (context, AsyncSnapshot<QueryResults> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text("No data"));
            }
            var data = snapshot.data;

            var rows = List<TableRow>();
            rows.add(
              TableRow(
                children: data.columnNames.map((e) => Text(e)).toList(),
              ),
            );
            for (int row = 0; row < data.rowCount(); row++){
              var rowData = data.getMultiFieldValuesFromRow(data.columnNames, row);
              rows.add(
                TableRow(
                  children: rowData.map((e) => Text(e.toString())).toList(),
                ),
              );
            }
            return Table(
              border: TableBorder.all(
                color: Colors.grey,
              ),
              children: rows,
            );
          },
        );
      },
    );
  }
}