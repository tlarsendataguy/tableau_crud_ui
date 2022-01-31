import 'package:flutter/foundation.dart' as Foundation;
import 'package:tableau_crud_ui/io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/configuration_pages/configuration_page.dart';
import 'package:tableau_crud_ui/io/db_web_io.dart';
import 'package:tableau_crud_ui/home_pages/home_page.dart';
import 'package:tableau_crud_ui/io/tableau_extension_io.dart';

void main() async {
  if (Foundation.kReleaseMode) {
    runProd();
  } else {
    runMock();
  }
}

void runProd() async {
  print('Creating Tableau Extension IO object...');
  var tIo = TableauExtensionIo();
  print('Initializing Tableau Extension IO object...');
  await tIo.initialize();
  print('Creating DB connector...');
  var dbIo = DbWebIo();
  print('Running app');
  runApp(
      MyApp(IoManager(dbIo, tIo))
  );
}


void runMock() async {
  print('Mocking...');
  var tIo = TableauMockIo();
  await tIo.saveSettings(mockSettings.toJson());
  await tIo.initialize();
  var dbIo = DbMockSuccessIo();
  runApp(
    MyApp(IoManager(dbIo, tIo))
  );
}

class MyApp extends StatelessWidget {
  MyApp(this.ioManager);
  final IoManager ioManager;

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tableau CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (context) => Home(ioManager),
        "/configure": (context)=> ConfigurationPage(ioManager),
      },
    );
  }
}
