import 'package:flutter/foundation.dart' as Foundation;
import 'package:tableau_crud_ui/io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/io/app_state.dart';
import 'package:tableau_crud_ui/io/bloc_provider.dart';
import 'package:tableau_crud_ui/configuration_pages/configuration_page.dart';
import 'package:tableau_crud_ui/io/configuration_state.dart';
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
  print('Creating application state...');
  var appState = AppState(tIo: tIo, dbIo: dbIo);
  print('Initializing application state...');
  await appState.initialize();
  print('Creating configuration state...');
  var configurationState = ConfigurationState(tIo: tIo, dbIo: dbIo);
  print('Initializing configuration state...');
  await configurationState.initialize();
  print('Running app');
  runApp(
    BlocProvider<AppState>(
      child: BlocProvider<ConfigurationState>(
        child: MyApp(),
        bloc: configurationState,
      ),
      bloc: appState,
    ),
  );
}


void runMock() async {
  print('Mocking...');
  var tIo = TableauMockIo();
  await tIo.saveSettings(mockSettings.toJson());
  await tIo.initialize();
  var dbIo = DbMockSuccessIo();
  var appState = AppState(tIo: tIo, dbIo: dbIo);
  await appState.initialize();
  var configurationState = ConfigurationState(tIo: tIo, dbIo: dbIo);
  await configurationState.initialize();
  runApp(
    BlocProvider<AppState>(
      child: BlocProvider<ConfigurationState>(
        child: MyApp(),
        bloc: configurationState,
      ),
      bloc: appState,
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
        "/": (context) => Home(),
        "/configure": (context)=> ConfigurationPage(),
      },
    );
  }
}
