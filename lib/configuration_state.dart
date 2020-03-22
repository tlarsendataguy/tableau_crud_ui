import 'package:rxdart/rxdart.dart';
import 'package:tableau_crud_ui/bloc_state.dart';
import 'package:tableau_crud_ui/connection_data.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/parse_responses.dart';
import 'package:tableau_crud_ui/settings.dart';

enum Page {
  connection,
  selectFields,
  orderByFields,
  filters,
}

class ConfigurationState extends BlocState {
  ConfigurationState({this.tIo, this.dbIo});
  final TableauIo tIo;
  final DbIo dbIo;

  String server;
  String port;
  String username;
  String password;
  String database;
  String schema;
  String dbo;
  String table;

  var _selectFields = BehaviorSubject<Map<String,String>>.seeded({});
  Stream<List<String>> get selectFields => _selectFields.stream.map((s)=>s.keys.toList());

  var _orderByFields = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get orderByFields => _orderByFields.stream;

  var _primaryKey = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get primaryKey => _primaryKey.stream;

  var _filters = BehaviorSubject<List<Filter>>.seeded([]);
  Stream<List<Filter>> get filters => _filters.stream;

  var _columnNames = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get columnNames => _columnNames.stream;

  var _page = BehaviorSubject<Page>.seeded(Page.connection);
  Stream<Page> get page => _page.stream;

  List<String> _worksheets;
  List<String> get worksheets => _worksheets;

  Future initialize() async {
    var settings = await tIo.getSettings();
    _worksheets = await tIo.getWorksheets();
    server = settings.server;
    port = settings.port;
    username = settings.username;
    password = settings.password;
    database = settings.database;
    schema = settings.schema;
    table = settings.table;
    _selectFields.add(settings.selectFields);
    _orderByFields.add(settings.orderByFields);
    _primaryKey.add(settings.primaryKey);
    _filters.add(settings.filters);
    if (!settings.isEmpty()){
      await testConnection();
    }
  }

  Future<String> testConnection() async {
    var settings = Settings(
      server: server,
      port: port,
      username: username,
      password: password,
      database: database,
      schema: schema,
      table: table,
    );
    var function = TestConnectionFunction();
    var request = ConnectionData.fromSettings(settings).generateRequest(function);
    var response = await dbIo.testConnection(request);
    var queryResult = parseQuery(response);
    if (!queryResult.hasError){
      _columnNames.add(queryResult.data.columnNames);
    }
    return queryResult.error;
  }

  void goToPage(Page page){
    _page.add(page);
  }

  Future<List<TableauFilter>> getFilters(String worksheet) async {
    return await tIo.getFilters(worksheet);
  }

  void addSelectField(String newSelectField){
    var newSelectFields = Map<String,String>.from(_selectFields.value);
    newSelectFields[newSelectField] = editNone;
    _selectFields.add(newSelectFields);
  }

  void removeSelectField(String toRemove){
    var newSelectFields = Map<String,String>.from(_selectFields.value);
    newSelectFields.remove(toRemove);
    _selectFields.add(newSelectFields);
  }

  void moveSelectFieldUp(String field){
    var oldSelectFields = Map<String,String>.from(_selectFields.value);
    var fields = oldSelectFields.keys.toList();
    var index = fields.indexOf(field);
    if (index < 1) return;
    index--;
    fields.remove(field);
    fields.insert(index, field);
    var newSelectFields = Map<String,String>();
    for (var field in fields){
      newSelectFields[field] = oldSelectFields[field];
    }
    _selectFields.add(newSelectFields);
  }

  void moveSelectFieldDown(String field){
    var oldSelectFields = Map<String,String>.from(_selectFields.value);
    var fields = oldSelectFields.keys.toList();
    var index = fields.indexOf(field);
    if (index == -1 || index == fields.length-1) return;
    index++;
    fields.remove(field);
    fields.insert(index, field);
    var newSelectFields = Map<String,String>();
    for (var field in fields){
      newSelectFields[field] = oldSelectFields[field];
    }
    _selectFields.add(newSelectFields);
  }

  void addOrderByField(String newOrderByField){
    var newOrderByFields = List<String>.from(_orderByFields.value);
    newOrderByFields.add(newOrderByField);
    _orderByFields.add(newOrderByFields);
  }

  void removeOrderByField(String toRemove){
    var newOrderByFields = List<String>.from(_orderByFields.value);
    newOrderByFields.remove(toRemove);
    _orderByFields.add(newOrderByFields);
  }

  void moveOrderByFieldUp(String field){
    var newOrderByFields = List<String>.from(_orderByFields.value);
    var index = newOrderByFields.indexOf(field);
    if (index < 1) return;
    index--;
    newOrderByFields.remove(field);
    newOrderByFields.insert(index, field);
    _orderByFields.add(newOrderByFields);
  }

  void moveOrderByFieldDown(String field){
    var newOrderByFields = List<String>.from(_orderByFields.value);
    var index = newOrderByFields.indexOf(field);
    if (index == -1 || index == newOrderByFields.length-1) return;
    index++;
    newOrderByFields.remove(field);
    newOrderByFields.insert(index, field);
    _orderByFields.add(newOrderByFields);
  }

  void addPrimaryKeyField(String newPrimaryKeyField){
    var newPrimaryKey = List<String>.from(_primaryKey.value);
    newPrimaryKey.add(newPrimaryKeyField);
    _primaryKey.add(newPrimaryKey);
  }

  void removePrimaryKeyField(String removePrimaryKeyField){
    var newPrimaryKey = List<String>.from(_primaryKey.value);
    newPrimaryKey.remove(removePrimaryKeyField);
    _primaryKey.add(newPrimaryKey);
  }

  String getSelectFieldEditMode(String selectField){
    return _selectFields.value[selectField];
  }

  void updateSelectFieldEditMode(String selectField, String editMode){
    var newSelectFields = Map<String,String>.from(_selectFields.value);
    newSelectFields[selectField] = editMode;
    _selectFields.add(newSelectFields);
  }

  void addFilter({String worksheet, String fieldName, String mapsTo}){
    var newFilters = List<Filter>.from(_filters.value);
    newFilters.add(Filter(
      worksheet: worksheet,
      fieldName: fieldName,
      mapsTo: mapsTo,
    ));
    _filters.add(newFilters);
  }

  void removeFilter({String worksheet, String fieldName, String mapsTo}){
    var newFilters = List<Filter>.from(_filters.value);
    newFilters.removeWhere((f)=>f.worksheet == worksheet && f.fieldName == fieldName && f.mapsTo == mapsTo);
    _filters.add(newFilters);
  }

  Settings generateSettings(){
    return Settings(
      server: server,
      port: port,
      username: username,
      password: password,
      database: database,
      schema: schema,
      table: table,
      selectFields: _selectFields.value,
      primaryKey: _primaryKey.value,
      orderByFields: _orderByFields.value,
      filters: _filters.value,
    );
  }

  void dispose() {
    _selectFields.close();
    _orderByFields.close();
    _primaryKey.close();
    _filters.close();
    _columnNames.close();
    _page.close();
  }
}