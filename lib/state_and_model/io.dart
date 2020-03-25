import 'package:tableau_crud_ui/state_and_model/connection_data.dart';
import 'package:tableau_crud_ui/state_and_model/settings.dart';

abstract class DbIo {
  Future<String> testConnection(RequestData request);
  Future<String> insert(RequestData request);
  Future<String> update(RequestData request);
  Future<String> delete(RequestData request);
  Future<String> read(RequestData request);
}

abstract class TableauIo {
  Future initialize();
  Future<String> getContext();
  Future<Settings> getSettings();
  Future saveSettings(String settingsJson);
  Future<List<String>> getWorksheets();
  Future<List<TableauFilter>> getFilters(String worksheet);
  Future<Map<String,String>> getAllDataSources();
  Future updateDataSources(List<String> ids);
  void registerFilterChangedOn(List<String> worksheets, Function(dynamic) callback);
  void unregisterFilterChangedOnAll();
}

class TableauFilter{
  TableauFilter({this.fieldId,this.fieldName,this.filterType,this.isAllSelected,this.includeNullValues,this.exclude,this.values});

  final String fieldId;
  final String fieldName;
  final String filterType;
  final bool   isAllSelected;
  final bool   includeNullValues;
  final bool   exclude;
  final List<dynamic> values;
}

class DbMockSuccessIo extends DbIo {
  Future<String> testConnection(RequestData request) async =>
      '{"Success":true,"Data":{"ColumnNames":["id","category","amount","date","comment","is true"],"RowCount":0,"Data":[[],[],[],[],[],[]],"TotalRowCount":0}}';
  Future<String> insert(RequestData request) async =>
      '{"Success":true,"Data":1}';
  Future<String> update(RequestData request) async =>
      '{"Success":true,"Data":1}';
  Future<String> delete(RequestData request) async =>
      '{"Success":true,"Data":1}';
  Future<String> read(RequestData request) async =>
      '{"Success":true,"Data":{"ColumnNames":["id","category","amount","date","comment","is true"],"RowCount":2,"Data":[[1,13],["blah","something"],[123.2,64.02],["2020-01-13T00:00:00Z","2020-02-03T00:00:00Z"],["hello world","You are my sunshine"],[true,false]],"TotalRowCount":20}}';
}

class DbMockFailIo extends DbIo {
  Future<String> testConnection(RequestData request) async =>
      '{"Success":false,"Data";"test connection failed"}';
  Future<String> insert(RequestData request) async =>
      '{"Success":false,"Data";"insert failed"}';
  Future<String> update(RequestData request) async =>
      '{"Success":false,"Data";"update failed"}';
  Future<String> delete(RequestData request) async =>
      '{"Success":false,"Data";"delete failed"}';
  Future<String> read(RequestData request) async =>
      '{"Success":false,"Data";"read failed"}';
}

var mockSettings = Settings(
  server: 'test server',
  port: 'test port',
  username: 'test username',
  password: 'test password',
  database: 'test database',
  schema: 'test schema',
  table: 'test table',
  selectFields: {'id': editNone, 'category': "$editFixedList:blah|something", 'amount': editNumber, 'date': editDate, 'comment': editText, 'is true': editBool},
  orderByFields: ['id'],
  primaryKey: ['id'],
  filters: [Filter(worksheet: 'test worksheet', fieldName: 'test field', mapsTo: 'category')],
);

class TableauMockIo extends TableauIo {
  var _settings = Settings(
    server: '',
    port: '',
    username: '',
    password: '',
    database: '',
    schema: '',
    table: '',
    selectFields: {},
    orderByFields: [],
    primaryKey: [],
    filters: [],
  );

  Future initialize() async {}
  Future<String> getContext() async => 'desktop';

  Future<Settings> getSettings() async {
    return _settings;
  }

  Future saveSettings(String settingsJson) async {
    _settings = Settings.fromJson(settingsJson);
  }

  Future<List<String>> getWorksheets() async {
    return ['sheet1','sheet2'];
  }

  Future<List<TableauFilter>> getFilters(String worksheet) async {
    return <TableauFilter>[
      TableauFilter(
        fieldId: '1',
        fieldName: 'Some field',
        filterType: 'categorical',
        isAllSelected: false,
        includeNullValues: false,
        exclude: false,
        values: ['A','B'],
      ),
    ];
  }

  Future<Map<String,String>> getAllDataSources() async {
    return {"datasourceid":"datasourcename"};
  }

  Future updateDataSources(List<String> ids) async {}

  void registerFilterChangedOn(List<String> worksheets, Function callback){}
  void unregisterFilterChangedOnAll(){}
}

