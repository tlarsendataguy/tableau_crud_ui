import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/home_pages/data_entry_dialog.dart';
import 'package:tableau_crud_ui/home_pages/data_viewer.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/response_objects.dart';
import 'package:tableau_crud_ui/io/settings.dart';
import 'package:tableau_crud_ui/styling.dart';

class Home extends StatefulWidget {
  Home(this.io);
  final IoManager io;

  createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool loaded = false;
  Settings settings;
  String tableauContext = '';
  int selectedRow = -1;

  initState(){
    super.initState();
    loadTableau();
  }

  Future loadTableau() async {
    tableauContext = await widget.io.tableau.getContext();
    settings = await widget.io.tableau.getSettings();
    setState((){});
  }

  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: Text("Loading..."));
    }

    Widget configureButton = Container();
    if (tableauContext == 'desktop'){
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
            icon: Icon(
              Icons.add,
              color: editIconColor,
            ),
            onPressed: () async {
              var editModes = settings.selectFields;
              var initialValues = editModes.keys.map((e)=>null).toList();
              await showDialog(
                context: context,
                builder: (context) => DataEntryDialog(
                  editModes: editModes,
                  initialValues: initialValues,
                  onSubmit: state.insert,
                ),
              );
            },
          ),
        ),
        StreamBuilder(
          stream: state.selectedRow,
          builder: (context, AsyncSnapshot<int> snapshot){
            var onPressed = () async {
              var editModes = state.settings.selectFields;
              var initialValues = state.getSelectedRowValues();
              await showDialog(
                context: context,
                builder: (context) => DataEntryDialog(
                  editModes: editModes,
                  initialValues: initialValues,
                  onSubmit: state.update,
                ),
              );
            };
            if (!snapshot.hasData || snapshot.data == -1) onPressed = null;
            return Tooltip(
              message: "Edit record",
              child: IconButton(
                icon: Icon(Icons.edit),
                color: editIconColor,
                onPressed: onPressed,
              ),
            );
          },
        ),
        StreamBuilder(
          stream: state.selectedRow,
          builder: (context, AsyncSnapshot<int> snapshot){
            var onPressed = ()async{
              var result = await showDialog(
                context: context,
                builder: (context) => YesNoDialog(
                  child: Text("Are you sure you want to delete this record?"),
                ),
              );
              if (result != 'Yes'){
                return;
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => LoadingDialog(message: "Deleting..."),
              );
              var err = await state.delete();
              Navigator.of(context).pop();
              if (err != ''){
                await showDialog(
                  context: null,
                  builder: (context) => OkDialog(
                    msgType: MsgType.Error,
                    child: Text("Error: $err"),
                  ),
                );
              }
            };
            if (!snapshot.hasData || snapshot.data == -1) onPressed = null;
            return Tooltip(
              message: "Delete record",
              child: IconButton(
                icon: Icon(Icons.delete),
                color: editIconColor,
                onPressed: onPressed,
              ),
            );
          },
        ),
        Tooltip(
          message: "Refresh table",
          child: IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.blue,
            ),
            onPressed: () async {
              var error = await state.readTable();
              if (error != ""){
                await showDialog(
                  context: context,
                  builder: (context) => OkDialog(
                      child: Text(error, softWrap: true),
                      msgType: MsgType.Error),
                );
              }
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.file_upload),
          onPressed: () async {
            var filePicker = FileUploadInputElement();
            filePicker.multiple = false;
            filePicker.accept = '.txt,.csv';
            filePicker.onChange.listen((event) {
              if (filePicker.files.length>0){
                var file = filePicker.files[0];
                print(file.name);
                print(file.type);
                var reader = FileReader();
                reader.onLoadEnd.listen((event) {
                  try{
                    var textValue = utf8.decode(reader.result, allowMalformed: false);
                    print(textValue);
                  } catch (ex) {
                    print('invalid file type');
                  }
                });
                reader.readAsArrayBuffer(file);
              }

            });
            filePicker.click();
          },
        ),
        Expanded(
          child: Container(),
        ),
        PageSelector(),
        configureButton,
      ],
    );

    return Material(
      color: backgroundColor,
      child: Column(
        children: <Widget>[
          Card(child: buttonBar),
          Expanded(child: Card(child: Padding(padding: EdgeInsets.all(4.0),child: DataViewer()))),
        ],
      ),
    );
  }
}

class PageSelector extends StatelessWidget {
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: state.data,
      builder: (context, AsyncSnapshot<QueryResults> snapshot){
        if (!snapshot.hasData){
          return Container();
        }
        if (snapshot.data.totalRowCount == 0 || snapshot.data.totalRowCount == null){
          return Container();
        }
        var page = state.page;
        var totalPages = (snapshot.data.totalRowCount / state.pageSize).ceil();
        return Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: page <= 1 ? null : () async {
                state.page = page-1;
                var err = await state.readTable();
                if (err != ''){
                  await showDialog(
                    context: context,
                    builder: (context) => OkDialog(
                      child: Text("Error: $err"),
                      msgType: MsgType.Error,
                    ),
                  );
                }
              },
            ),
            Text("$page of $totalPages"),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: page >= totalPages ? null : () async {
                state.page = page + 1;
                var err = await state.readTable();
                if (err != '') {
                  await showDialog(
                    context: context,
                    builder: (context) => OkDialog(
                      child: Text("Error: $err"),
                      msgType: MsgType.Error,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
