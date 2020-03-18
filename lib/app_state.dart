

import 'package:tableau_crud_ui/bloc_state.dart';
import 'package:tableau_crud_ui/io.dart';

class AppState extends BlocState {
  AppState({this.tIo, this.dbIo});

  final TableauIo tIo;
  final DbIo dbIo;

  Future initialize() async {}

  void dispose() {
    // TODO: implement dispose
  }
}