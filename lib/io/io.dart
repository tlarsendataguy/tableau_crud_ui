import 'package:tableau_crud_ui/io/connection_data.dart';
import 'package:tableau_crud_ui/io/settings.dart';
import 'package:http/http.dart';

class IoManager {
  IoManager(this.db, this.tableau);
  final DbIo db;
  final TableauIo tableau;
}

abstract class DbIo {
  Future<Response> testConnection(RequestData request);
  Future<Response> insert(RequestData request);
  Future<Response> update(RequestData request);
  Future<Response> delete(RequestData request);
  Future<Response> read(RequestData request);
}

abstract class TableauIo {
  Future initialize();
  Future<String> getContext();
  Future<Settings> getSettings();
  Future saveSettings(String settingsJson);
  Future<List<String>> getParameters();
  Future<Parameter?> getParameter(String name);
  Future<List<String>> getWorksheets();
  Future<List<TableauFilter>> getFilters(String worksheet);
  Future<Map<String,String>> getAllDataSources();
  Future updateDataSources(List<String> ids);
  void registerFilterChangedOn(List<String> worksheets, Function(dynamic) callback);
  Future registerParameterChangedOn(List<String> parameters, Function(dynamic) callback);
  void unregisterFilterChangedOnAll();
}

class TableauFilter{
  TableauFilter({required this.fieldId, required this.fieldName, required this.filterType, required this.isAllSelected, required this.includeNullValues, required this.exclude, required this.values});

  final String fieldId;
  final String fieldName;
  final String filterType;
  final bool   isAllSelected;
  final bool   includeNullValues;
  final bool   exclude;
  final List<dynamic> values;
}

class DbMockSuccessIo extends DbIo {
  Future<Response> testConnection(RequestData request) async =>
      Response('{"ColumnNames":["id","category","amount","date","comment","is true"],"RowCount":0,"Data":[[],[],[],[],[],[]],"TotalRowCount":0}', 200);
  Future<Response> insert(RequestData request) async =>
      Response('1', 200);
  Future<Response> update(RequestData request) async =>
      Response('1', 200);
  Future<Response> delete(RequestData request) async =>
      Response('1', 200);
  Future<Response> read(RequestData request) async =>
      Response('{"ColumnNames":["id","category","amount","date","comment","is true","long text"],"RowCount":2,"Data":[[1,13,14],["blah","something",null],[123.2,64.02,null],["2020-01-13T00:00:00Z","2020-02-03T00:00:00Z",null],["hello world","You are my sunshine",null],[true,false,null],["The rain in Spain stays mainly on the plain","",""]],"TotalRowCount":20}', 200);
}

class DbMockFailIo extends DbIo {
  Future<Response> testConnection(RequestData request) async =>
      Response("test connection failed", 500);
  Future<Response> insert(RequestData request) async =>
      Response("insert failed", 500);
  Future<Response> update(RequestData request) async =>
      Response("update failed", 500);
  Future<Response> delete(RequestData request) async =>
      Response("delete failed", 500);
  Future<Response> read(RequestData request) async =>
      Response("read failed", 500);
}

var mockSettings = Settings(
  apiKey: 'api key',
  connection: 'test connection',
  table: 'test table',
  selectFields: {'id': editNone, 'category': "$editFixedList:blah|something", 'amount': editNumber, 'date': editDate, 'comment': editText, 'is true': editBool},
  orderByFields: ['id'],
  primaryKey: ['id'],
  filters: [Filter(worksheet: 'test worksheet', fieldName: 'test field', mapsTo: 'category', parameterName: ''),Filter(worksheet: '', fieldName: '', parameterName: 'test parameter', mapsTo: 'type of record')],
  tableColumns: ['id', 'category', 'amount', 'date', 'comment', 'is true', 'long text'],
  defaultPageSize: 25,
  enableUpdate: false,
  enableInsert: false,
  enableDelete: false,
  mappedDataSources: [],
);

class TableauMockIo extends TableauIo {
  var _settings = Settings(
    apiKey: '',
    connection: '',
    table: '',
    selectFields: {},
    orderByFields: [],
    primaryKey: [],
    filters: [],
    tableColumns: [],
    defaultPageSize: 25,
    enableUpdate: false,
    enableInsert: false,
    enableDelete: false,
    mappedDataSources: [],  );

  Future initialize() async {}
  Future<String> getContext() async => 'desktop';

  Future<Settings> getSettings() async {
    return _settings;
  }

  Future saveSettings(String settingsJson) async {
    _settings = Settings.fromJson(settingsJson);
  }

  Future<List<String>> getParameters() async {
    return ["Param1"];
  }

  Future<Parameter?> getParameter(String name) async {
    if (name != 'Param1') {
      return null;
    }
    return Parameter(
      name: 'Param1',
      id: 'ParamId1',
      value: 12345,
      formattedValue: '12345',
      dataType: 'Integer',
    );
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
  Future registerParameterChangedOn(List<String> worksheets, Function callback) async {}
  void unregisterFilterChangedOnAll(){}
}

class Parameter {
  Parameter({required this.id, required this.name, required this.value, required this.formattedValue, required this.dataType});
  final String id;
  final String name;
  final dynamic value;
  final String formattedValue;
  final String dataType;
}