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
  late Settings settings;
  String tableauContext = '';
  int selectedRow = -1;
  int page = 1;
  int totalPages = 0;
  QueryResults? data;
  String error = '';

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
    await setFilterChangeCallbacks();
    loaded = true;
    if (settings.isEmpty()) {
      data = QueryResults(columnNames: [], data: [], totalRowCount: 0);
      setState((){});
      return;
    }
    this.error = await readTable();
    setState((){});
  }

  Future setFilterChangeCallbacks() async {
    var registerWorksheets = <String>[];
    var registerParams = <String>[];
    for (var filter in settings.filters){
      if (registerWorksheets.contains(filter.worksheet)) continue;
      if (registerParams.contains(filter.parameterName)) continue;

      if (filter.parameterName != '') {
        registerParams.add(filter.parameterName);
      } else {
        registerWorksheets.add(filter.worksheet);
      }
    }
    widget.io.tableau.registerFilterChangedOn(registerWorksheets, filterChangeCallback);
    await widget.io.tableau.registerParameterChangedOn(registerParams, parameterChangeCallback);
  }

  Future filterChangeCallback(dynamic event) async {
    this.error = await readTable();
    setState((){});
  }

  Future parameterChangeCallback(dynamic event) async{
    this.error = await readTable();
    setState((){});
  }

  Future<String> insert(Map<String,dynamic> values) async {
    var requiredFields = settings.selectFields.keys.where((key) {
      var editMode = getEditMode(settings.selectFields[key] ?? editNone);
      return editMode == editText ||
          editMode == editMultiLineText ||
          editMode == editInteger ||
          editMode == editNumber ||
          editMode == editBool ||
          editMode == editDate ||
          editMode == editFixedList ||
          editMode == editTimestamp ||
          editMode == editUser;
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
      pageSize: settings.defaultPageSize,
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
    totalPages = (data?.totalRowCount ?? 0 / settings.defaultPageSize).ceil();
    setState(()=>readingTable = false);
    return queryResult.error;
  }

  Future<List<Where>> generateWheres() async {
    var wheres = <Where>[];
    for (var filter in settings.filters){
      if (filter.parameterName != '') {
        var tParam = await widget.io.tableau.getParameter(filter.parameterName);
        if (tParam == null) {
          continue;
        }
        wheres.add(WhereEqual(filter.mapsTo, tParam.value));
        continue;
      }

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
    var pkValues = data?.getMultiFieldValuesFromRow(pk, selected) ?? [];
    var wheres = <Where>[];
    for (var index = 0; index < pk.length; index++){
      wheres.add(WhereEqual(pk[index], pkValues[index]));
    }
    return wheres;
  }

  List<dynamic> getSelectedRowValues(){
    return data?.getMultiFieldValuesFromRow(settings.selectFields.keys.toList(), selectedRow) ?? [];
  }

  Future pageUpdated(int newPage) async {
    page = newPage;
    this.error = await readTable();
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
      this.error = await readTable();
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

    var buttonBarChildren = <Widget>[];
    if (settings.enableInsert) {
      buttonBarChildren.add(
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
                  io: widget.io,
                ),
              );
            },
          ),
        ),
      );
    }

    if (settings.enableUpdate) {
      buttonBarChildren.add(
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
                  io: widget.io,
                ),
              );
            },
          ),
        ),
      );
    }

    if (settings.enableDelete) {
      buttonBarChildren.add(
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
                  context: context,
                  builder: (context) => OkDialog(
                    msgType: MsgType.Error,
                    child: Text("Error: $err"),
                  ),
                );
              }
            },
          ),
        ),
      );
    }

    buttonBarChildren.addAll([
      Tooltip(
        message: "Refresh table",
        child: IconButton(
          icon: Icon(
            Icons.refresh,
            color: Colors.blue,
          ),
          onPressed: () async {
            this.error = await readTable();
            setState((){});
          },
        ),
      ),
      Expanded(
        child: Container(),
      ),
      PageSelector(onPageUpdated: pageUpdated, currentPage: page, totalPages: totalPages),
      configureButton,
    ]);

    var buttonBar = Row(
      children: buttonBarChildren,
    );

    Widget dataWidget;
    if (this.error != '') {
      dataWidget = Center(child: Text(this.error));
    } else {
      dataWidget = DataViewer(
        onSelectRow: rowSelected,
        data: data,
        settings: settings,
        selectedRow: selectedRow,
      );
    }

    return Material(
      color: backgroundColor,
      child: Column(
        children: <Widget>[
          Card(child: buttonBar),
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: dataWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageSelector extends StatelessWidget {
  PageSelector({required this.onPageUpdated, required this.currentPage, required this.totalPages});
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
