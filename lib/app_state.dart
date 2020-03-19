import 'package:rxdart/rxdart.dart';
import 'package:tableau_crud_ui/bloc_state.dart';
import 'package:tableau_crud_ui/connection_data.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/parse_responses.dart';
import 'package:tableau_crud_ui/response_objects.dart';
import 'package:tableau_crud_ui/settings.dart';

class AppState extends BlocState {
  AppState({this.tIo, this.dbIo});

  final TableauIo tIo;
  final DbIo dbIo;

  int page = 1;
  int pageSize;
  String _tableauContext;
  int _reads = 0;

  var _settings = BehaviorSubject<Settings>.seeded(null);
  Stream<Settings> get settings => _settings.stream;

  var _tableColumns = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get tableColumns => _tableColumns.stream;

  var _data = BehaviorSubject<QueryResults>.seeded(null);
  Stream<QueryResults> get data => _data.stream;

  var _readLoaders = BehaviorSubject<int>.seeded(0);
  Stream<int> get readLoaders => _readLoaders.stream;

  Future initialize() async {
    var settings = await tIo.getSettings();
    _tableauContext = await tIo.getContext();
    pageSize = settings.defaultPageSize;
    _settings.add(settings);
    if (!settings.isEmpty()){
      readTable();
    }
  }

  String get tableauContext =>_tableauContext;

  Future setSettings(Settings settings) async {
    await tIo.saveSettings(settings.toJson());
    _settings.add(settings);
  }

  Future<List<String>> getWorksheets() async {
    return await tIo.getWorksheets();
  }

  Future<String> testConnection(Settings settings) async {
    var function = TestConnectionFunction();
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await dbIo.testConnection(request);
    var queryResult = parseQuery(response);
    if (!queryResult.hasError){
      await setSettings(settings);
      _tableColumns.add(queryResult.data.columnNames);
    }
    return queryResult.error;
  }

  Future<String> readTable() async {
    _readLoaders.add(++_reads);
    var settings = _settings.value;
    var function = ReadFunction(
      fields: settings.selectFields,
      orderBy: settings.orderByFields,
      pageSize: pageSize,
      page: page,
      whereClauses: await _generateWheres(),
    );
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await dbIo.read(request);
    var queryResult = parseQuery(response);
    if (!queryResult.hasError){
      _data.add(queryResult.data);
    }
    _readLoaders.add(--_reads);
    return queryResult.error;
  }

  Future<String> insert(List<dynamic> values) async {
    var settings = _settings.value;
    if (values.length != settings.selectFields.length){
      return "${values.length} fields were provided but ${settings.selectFields.length} fields were required";
    }

    var insertValues = Map<String,dynamic>();
    for (var index = 0; index < values.length; index++){
      insertValues[settings.selectFields[index]] = values[index];
    }
    var function = InsertFunction(insertValues);
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await dbIo.insert(request);
    var result = parseExec(response);
    if (result.hasError) {
      return result.error;
    }
    return await readTable();
  }

  Future<String> update({Map<String,dynamic> values, Map<String,dynamic> where}) async {
    var settings = _settings.value;
    if (where.length != settings.primaryKey.length){
      return "${where.length} where clauses were provided but there are ${settings.primaryKey.length} primary key fields";
    }

    var wheres = List<Where>();
    for (var key in where.keys){
      if (!settings.primaryKey.contains(key)){
        return "$key is not a primary key field";
      }
      wheres.add(WhereEqual(key, where[key]));
    }
    var function = UpdateFunction(whereClauses: wheres, updates: values);
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await dbIo.update(request);
    var result = parseExec(response);
    if (result.hasError) {
      return result.error;
    }
    return await readTable();
  }

  Future<String> delete({Map<String,dynamic> where}) async {
    var settings = _settings.value;
    if (where.length != settings.primaryKey.length){
      return "${where.length} where clauses were provided but there are ${settings.primaryKey.length} primary key fields";
    }

    var wheres = List<Where>();
    for (var key in where.keys){
      if (!settings.primaryKey.contains(key)){
        return "$key is not a primary key field";
      }
      wheres.add(WhereEqual(key, where[key]));
    }
    var function = DeleteFunction(whereClauses: wheres);
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await dbIo.delete(request);
    var result = parseExec(response);
    if (result.hasError) {
      return result.error;
    }
    return await readTable();
  }

  void dispose() {
    _settings.close();
    _tableColumns.close();
    _data.close();
    _readLoaders.close();
  }

  Future<List<Where>> _generateWheres() async {
    var wheres = List<Where>();
    var settings = _settings.value;
    for (var filter in settings.filters){
      var tFilters = await tIo.getFilters(filter.worksheet);
      for (var tFilter in tFilters){
        if (tFilter.fieldName == filter.fieldName) {
          switch (tFilter.filterType){
            case 'categorical':
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