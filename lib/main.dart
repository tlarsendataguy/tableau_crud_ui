import 'dart:html';

import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/db_web_io.dart';
import 'package:tableau_crud_ui/settings.dart';
import 'package:tableau_crud_ui/tableau_extension_io.dart';

void main() async {
  //var tio = TableauMockIo();
  var tIo = TableauExtensionIo();
  await tIo.initialize();
  var state = AppState(tIo: tIo, dbIo: DbWebIo());
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var tIo = BlocProvider.of<AppState>(context).tIo;

    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text("See context"),
            onPressed: () async {
              var contextStr = await tIo.getContext();
              await showDialog(
                context: context,
                child: Dialog(
                  child: Text(contextStr),
                ),
              );
            },
          ),
          RaisedButton(
            child: Text("Save settings"),
            onPressed: () async {
              var settings = Settings(
                server: "10.12.4.166",
                port: '1433',
                username: '',
                password: '',
                database: 'TEST',
                schema: 'dbo',
                table: 'test_table',
                selectFields: ['id','category','amount'],
                orderByFields: ['category','amount'],
                primaryKey: ['id'],
                filters: [],
              );
              await tIo.saveSettings(settings.toJson());
              await showDialog(
                context: context,
                child: Dialog(
                  child: Text('Settings saved'),
                ),
              );
            },
          ),
          RaisedButton(
            child: Text("See settings"),
            onPressed: () async {
              var settings = await tIo.getSettings();
              await showDialog(
                context: context,
                child: Dialog(
                  child: Text(settings.toJson()),
                ),
              );
            },
          ),
          RaisedButton(
            child: Text("List worksheets"),
            onPressed: () async {
              var tables = await tIo.getWorksheets();
              await showDialog(
                context: context,
                child: Dialog(
                  child: ListView.builder(
                    itemCount: tables.length,
                    itemBuilder: (context, index){
                      return Text(tables[index]);
                    },
                  ),
                ),
              );
            },
          ),
          RaisedButton(
            child: Text("List filters for first worksheet"),
            onPressed: () async {
              var tables = await tIo.getWorksheets();
              var filters = await tIo.getFilters(tables[0]);
              await showDialog(
                context: context,
                child: Dialog(
                  child: ListView.builder(
                    itemCount: filters.length,
                    itemBuilder: (context, index){
                      var filter = filters[index];
                      return Text("field: ${filter.fieldName}\ntype: ${filter.filterType}\nexclude: ${filter.exclude}\nisAllSelected: ${filter.isAllSelected}\nincludeNullValues: ${filter.includeNullValues}\nvalues: ${filter.values.toString()}\n");
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}