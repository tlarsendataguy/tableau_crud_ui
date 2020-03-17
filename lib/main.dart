import 'dart:html';

import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/settings.dart';
import 'package:tableau_crud_ui/tableau_extension_io.dart';

TableauIo io;

void main() async {
  //io = TableauMockIo();
  io = TableauExtensionIo();
  await io.initialize();
  runApp(MyApp());
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
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
              await io.saveSettings(settings.toJson());
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
              var settings = await io.getSettings();
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
              var tables = await io.getWorksheets();
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
        ],
      ),
    );
  }
}