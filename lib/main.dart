import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/bloc_provider.dart';
import 'package:tableau_crud_ui/configuration_page.dart';
import 'package:tableau_crud_ui/db_web_io.dart';
import 'package:tableau_crud_ui/home_page.dart';
import 'package:tableau_crud_ui/io.dart';
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
        "/configure": (context)=>ConfigurationPage(),
      },
    );
  }
}
