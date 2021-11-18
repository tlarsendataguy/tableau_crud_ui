import 'package:rxdart/rxdart.dart';
import 'package:tableau_crud_ui/io/bloc_state.dart';
import 'package:tableau_crud_ui/io/connection_data.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/parse_responses.dart';
import 'package:tableau_crud_ui/io/response_objects.dart';
import 'package:tableau_crud_ui/io/settings.dart';

class AppState extends BlocState {
  AppState({this.tIo, this.dbIo});

  final TableauIo tIo;
  final DbIo dbIo;

  int page = 1;
  int pageSize;
  String _tableauContext;
  int _reads = 0;
  Settings _settings;

  Settings get settings => _settings;

  var _tableColumns = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get tableColumns => _tableColumns.stream;

  var _data = BehaviorSubject<QueryResults>.seeded(null);
  Stream<QueryResults> get data => _data.stream;

  var _readLoaders = BehaviorSubject<int>.seeded(0);
  Stream<int> get readLoaders => _readLoaders.stream;

  var _selectedRow = BehaviorSubject<int>.seeded(-1);
  Stream<int> get selectedRow => _selectedRow.stream;

  List<dynamic> getSelectedRowValues(){
    if (_data.value == null) return [];
    return _data.value.getMultiFieldValuesFromRow(_settings.selectFields.keys.toList(), _selectedRow.value);
  }

  Future initialize() async {
    _settings = await tIo.getSettings();
    _tableauContext = await tIo.getContext();
    pageSize = _settings.defaultPageSize;
    if (!_settings.isEmpty()){
      await readTable();
      setFilterChangeCallbacks();
    }
  }

  String get tableauContext =>_tableauContext;

  Future updateSettings(Settings settings) async {
    tIo.unregisterFilterChangedOnAll();
    _settings = await tIo.getSettings();
    if (!_settings.isEmpty()){
      readTable();
      setFilterChangeCallbacks();
    }
  }

  void setFilterChangeCallbacks(){
    var registerOn = List<String>();
    for (var filter in _settings.filters){
      if (registerOn.contains(filter.worksheet)) continue;
      registerOn.add(filter.worksheet);
    }
    tIo.registerFilterChangedOn(registerOn, filterChangeCallback);
  }

  void filterChangeCallback(dynamic event){
    readTable();
  }

  void selectRow(int selection){
    _selectedRow.add(selection);
  }

  Future<List<String>> getWorksheets() async {
    return await tIo.getWorksheets();
  }

  Future<String> readTable() async {
    _readLoaders.add(++_reads);
    _selectedRow.add(-1);
    var function = ReadFunction(
      fields: _settings.selectFields.keys.toList(),
      orderBy: _settings.orderByFields,
      pageSize: pageSize,
      page: page,
      whereClauses: await _generateWheres(),
    );
    var request = ConnectionData.fromSettings(_settings).generateRequest(function);
    var response = await dbIo.read(request);
    var queryResult = parseQuery(response);
    if (!queryResult.hasError){
      _data.add(queryResult.data);
    }
    _readLoaders.add(--_reads);
    if (queryResult.error != ''){
      print(queryResult.error);
    }
    return queryResult.error;
  }

  Future<String> insert(Map<String,dynamic> values) async {
    var requiredFields = _settings.selectFields.keys.where((key) {
      var editMode = getEditMode(_settings.selectFields[key]);
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
    var request = ConnectionData.fromSettings(_settings).generateRequest(function);
    var response = await dbIo.insert(request);
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
    tIo.updateDataSources(_settings.mappedDataSources);
    return await readTable();
  }

  Future<String> update(Map<String,dynamic> values) async {
    List<Where> wheres;
    try{
      wheres = _generatePkWhere();
    } on Exception catch (ex){
      return ex.toString();
    }
    var function = UpdateFunction(whereClauses: wheres, updates: values);
    var request = ConnectionData.fromSettings(_settings).generateRequest(function);
    var response = await dbIo.update(request);
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
    tIo.updateDataSources(_settings.mappedDataSources);
    return await readTable();
  }

  Future<String> delete() async {
    List<Where> wheres;
    try{
      wheres = _generatePkWhere();
    } on Exception catch (ex){
      return ex.toString();
    }
    var function = DeleteFunction(whereClauses: wheres);
    var request = ConnectionData.fromSettings(_settings).generateRequest(function);
    var response = await dbIo.delete(request);
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
    tIo.updateDataSources(_settings.mappedDataSources);
    return await readTable();
  }

  void dispose() {
    _tableColumns.close();
    _data.close();
    _readLoaders.close();
  }

  List<Where> _generatePkWhere(){
    var selected = _selectedRow.value;
    if (selected == -1){
      throw new Exception("no row was selected");
    }
    var pk = _settings.primaryKey;
    var pkValues = _data.value.getMultiFieldValuesFromRow(pk, selected);
    var wheres = List<Where>();
    for (var index = 0; index < pk.length; index++){
      wheres.add(WhereEqual(pk[index], pkValues[index]));
    }
    return wheres;
  }

  Future<List<Where>> _generateWheres() async {
    var wheres = List<Where>();
    for (var filter in _settings.filters){
      var tFilters = await tIo.getFilters(filter.worksheet);
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
}