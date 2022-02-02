import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:tableau_crud_ui/home_pages/data_entry_dialog.dart';
import 'package:tableau_crud_ui/home_pages/data_viewer.dart';
import 'package:tableau_crud_ui/dialogs.dart';
import 'package:tableau_crud_ui/io/connection_data.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/parse_responses.dart';
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
  bool readingTable = false;
  Settings settings;
  String tableauContext = '';
  int selectedRow = -1;
  int pageSize = 10;
  int page = 1;
  int totalPages = 0;
  QueryResults data;

  initState(){
    super.initState();
    loadTableau();
  }

  dispose(){
    widget.io.tableau.unregisterFilterChangedOnAll();
    super.dispose();
  }

  Future loadTableau() async {
    tableauContext = await widget.io.tableau.getContext();
    settings = await widget.io.tableau.getSettings();
    setFilterChangeCallbacks();
    loaded = true;
    await readTable();
  }

  void setFilterChangeCallbacks() {
    var registerOn = <String>[];
    for (var filter in settings.filters){
      if (registerOn.contains(filter.worksheet)) continue;
      registerOn.add(filter.worksheet);
    }
    widget.io.tableau.registerFilterChangedOn(registerOn, filterChangeCallback);
  }

  void filterChangeCallback(dynamic event){
    readTable();
  }

  Future<String> insert(Map<String,dynamic> values) async {
    var requiredFields = settings.selectFields.keys.where((key) {
      var editMode = getEditMode(settings.selectFields[key]);
      return editMode == editText ||
          editMode == editMultiLineText ||
          editMode == editInteger ||
          editMode == editNumber ||
          editMode == editBool ||
          editMode == editDate ||
          editMode == editFixedList;
    });
    if (values.length != requiredFields.length){
      return "${values.length} fields were provided but ${requiredFields.length} fields were required";
    }

    var function = InsertFunction(values);
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await widget.io.db.insert(request);
    var result = parseExec(response);
    if (result.hasError) {
      print(result.error);
      return result.error;
    }
    if (result.data == 0){
      var err = 'Zero records were inserted for an unknown reason';
      print(err);
      return err;
    }
    widget.io.tableau.updateDataSources(settings.mappedDataSources);
    return await readTable();
  }

  Future<String> update(Map<String,dynamic> values) async {
    List<Where> wheres;
    try{
      wheres = generatePkWhere();
    } on Exception catch (ex){
      return ex.toString();
    }
    var function = UpdateFunction(whereClauses: wheres, updates: values);
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await widget.io.db.update(request);
    var result = parseExec(response);
    if (result.hasError) {
      print(result.error);
      return result.error;
    }
    if (result.data == 0){
      var err = 'Zero records were updated for an unknown reason';
      print(err);
      return err;
    }
    widget.io.tableau.updateDataSources(settings.mappedDataSources);
    return await readTable();
  }

  Future<String> delete() async {
    List<Where> wheres;
    try{
      wheres = generatePkWhere();
    } on Exception catch (ex){
      return ex.toString();
    }
    var function = DeleteFunction(whereClauses: wheres);
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await widget.io.db.delete(request);
    var result = parseExec(response);
    if (result.hasError) {
      print(result.error);
      return result.error;
    }
    if (result.data == 0){
      var err = 'Zero records were deleted for an unknown reason';
      print(err);
      return err;
    }
    widget.io.tableau.updateDataSources(settings.mappedDataSources);
    return await readTable();
  }

  Future<String> readTable() async {
    setState(()=>readingTable = true);
    selectedRow = -1;
    var function = ReadFunction(
      fields: settings.selectFields.keys.toList(),
      orderBy: settings.orderByFields,
      pageSize: pageSize,
      page: page,
      whereClauses: await generateWheres(),
    );
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await widget.io.db.read(request);
    var queryResult = parseQuery(response);
    if (!queryResult.hasError){
      data = queryResult.data;
    }
    if (queryResult.error != ''){
      print(queryResult.error);
    }
    totalPages = (data.totalRowCount / pageSize).ceil();
    setState(()=>readingTable = false);
    return queryResult.error;
  }

  Future<List<Where>> generateWheres() async {
    var wheres = <Where>[];
    for (var filter in settings.filters){
      var tFilters = await widget.io.tableau.getFilters(filter.worksheet);
      for (var tFilter in tFilters){
        if (tFilter.fieldName == filter.fieldName) {
          switch (tFilter.filterType){
            case 'categorical':
              if (tFilter.isAllSelected) break;
              wheres.add(
                WhereIn(
                  filter.mapsTo,
                  tFilter.exclude,
                  tFilter.values,
                ),
              );
              break;
            case 'range':
              wheres.add(
                WhereRange(
                  filter.mapsTo,
                  tFilter.values[0],
                  tFilter.values[1],
                  tFilter.includeNullValues,
                ),
              );
              break;
          }
        }
      }
    }
    return wheres;
  }

  List<Where> generatePkWhere(){
    var selected = selectedRow;
    if (selected == -1){
      throw new Exception("no row was selected");
    }
    var pk = settings.primaryKey;
    var pkValues = data.getMultiFieldValuesFromRow(pk, selected);
    var wheres = <Where>[];
    for (var index = 0; index < pk.length; index++){
      wheres.add(WhereEqual(pk[index], pkValues[index]));
    }
    return wheres;
  }

  List<dynamic> getSelectedRowValues(){
    if (data == null) return [];
    return data.getMultiFieldValuesFromRow(settings.selectFields.keys.toList(), selectedRow);
  }

  Future pageUpdated(int newPage) async {
    page = newPage;
    await readTable();
  }

  void rowSelected(int newRow) {
    setState(()=>selectedRow = newRow);
  }

  Future updateSettings() async {
    setState(()=>loaded = false);
    widget.io.tableau.unregisterFilterChangedOnAll();
    settings = await widget.io.tableau.getSettings();

    loaded = true;
    if (!settings.isEmpty()){
      readTable();
      setFilterChangeCallbacks();
    }
  }

  Widget build(BuildContext context) {
    if (!loaded) {
      return Material(
        color: backgroundColor,
        child: Center(
          child: Text("Loading..."),
        ),
      );
    }
    if (readingTable) {
      return Material(
        color: backgroundColor,
        child: Center(
            child: Text("Reading data..."),
        ),
      );
    }

    Widget configureButton = Container();
    if (tableauContext == 'desktop'){
      configureButton = Tooltip(
        message: "Configure extension",
        child: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () async {
            await Navigator.of(context).pushNamed("/configure");
            await updateSettings();
          },
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
                  onSubmit: insert,
                ),
              );
            },
          ),
        ),
        Tooltip(
          message: "Edit record",
          child: IconButton(
            icon: Icon(Icons.edit),
            color: editIconColor,
            onPressed: selectedRow == -1 ? null : () async {
              var editModes = settings.selectFields;
              var initialValues = getSelectedRowValues();
              await showDialog(
                context: context,
                builder: (context) => DataEntryDialog(
                  editModes: editModes,
                  initialValues: initialValues,
                  onSubmit: update,
                ),
              );
            },
          ),
        ),
        Tooltip(
          message: "Delete record",
          child: IconButton(
            icon: Icon(Icons.delete),
            color: editIconColor,
            onPressed: selectedRow == -1 ? null : () async {
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
              var err = await delete();
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
            },
          ),
        ),
        Tooltip(
          message: "Refresh table",
          child: IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.blue,
            ),
            onPressed: () async {
              var error = await readTable();
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
        PageSelector(onPageUpdated: pageUpdated, currentPage: page, totalPages: totalPages),
        configureButton,
      ],
    );

    return Material(
      color: backgroundColor,
      child: Column(
        children: <Widget>[
          Card(child: buttonBar),
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: DataViewer(
                  onSelectRow: rowSelected,
                  data: data,
                  settings: settings,
                  selectedRow: selectedRow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageSelector extends StatelessWidget {
  PageSelector({this.onPageUpdated, this.currentPage, this.totalPages});
  final Function(int newPage) onPageUpdated;
  final int currentPage;
  final int totalPages;

  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: currentPage <= 1 ? null : () {
            onPageUpdated(currentPage-1);
          },
        ),
        Text("$currentPage of $totalPages"),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: currentPage >= totalPages ? null : () {
            onPageUpdated(currentPage+1);
          },
        ),
      ],
    );
  }
}
