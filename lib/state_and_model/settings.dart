import 'dart:convert';
import 'package:tableau_crud_ui/state_and_model/try_cast.dart';

const _server = "server";
const _port = "port";
const _username = "username";
const _password = "password";
const _database = "database";
const _schema = "schema";
const _table = "table";
const _selectFields = "selectFields";
const _orderByFields = "orderByFields";
const _primaryKey = "primaryKey";
const _filters = "filters";
const _worksheet = "worksheet";
const _fieldName = "fieldName";
const _mapsTo = "mapsTo";
const _defaultPageSize = "defaultPageSize";
const _mappedDataSources = 'mappedDataSources';

const editNone = 'None';
const editInteger = 'Integer';
const editNumber = 'Number';
const editText = 'Text';
const editDate = 'Date';
const editBool = 'Bool';
const editFixedList = 'Fixed List';
const editFilterList = 'Filter List';

class Settings {
  Settings(
      {
        this.server,
        this.port,
        this.username,
        this.password,
        this.database,
        this.schema,
        this.table,
        this.selectFields,
        this.orderByFields,
        this.primaryKey,
        this.filters,
        this.defaultPageSize,
        this.mappedDataSources,
      }
  );

  final String server;
  final String port;
  final String username;
  final String password;
  final String database;
  final String schema;
  final String table;
  final Map<String,String> selectFields;
  final List<String> orderByFields;
  final List<String> primaryKey;
  final List<Filter> filters;
  final int defaultPageSize;
  final List<String> mappedDataSources;

  bool isEmpty() {
    return server == '' &&
      port == '' &&
      username == '' &&
      password == '' &&
      database == '' &&
      schema == '' &&
      table == '' &&
      selectFields.isEmpty &&
      orderByFields.isEmpty &&
      primaryKey.isEmpty &&
      filters.isEmpty &&
      mappedDataSources.isEmpty;
  }

  String validate(){
    var errors = <String>[];
    if (selectFields.length == 0){
      errors.add("no fields were selected");
    }
    if (primaryKey.length == 0){
      errors.add("no primary key was selected");
    }
    if (orderByFields.length == 0){
      errors.add("no order by fields were defined");
    }
    return errors.join(", ");
  }

  String toJson() {
    var mapped = <String, dynamic>{
      _server: server,
      _port: port,
      _username: username,
      _password: password,
      _database: database,
      _schema: schema,
      _table: table,
      _selectFields: selectFields,
      _orderByFields: orderByFields,
      _primaryKey: primaryKey,
      _filters: filters.map((e) => e.toJson()).toList(),
      _defaultPageSize: defaultPageSize,
      _mappedDataSources: mappedDataSources,
    };
    return jsonEncode(mapped);
  }

  static Settings fromJson(String jsonSettings) {
    var mapped = tryCast<Map<String, dynamic>>(jsonDecode(jsonSettings), {});
    var server = mapped.tryString(_server);
    var port = mapped.tryString(_port);
    var username = mapped.tryString(_username);
    var password = mapped.tryString(_password);
    var database = mapped.tryString(_database);
    var schema = mapped.tryString(_schema);
    var table = mapped.tryString(_table);
    var selectFields = mapped.tryStringStringMap(_selectFields);
    var orderByFields = mapped.tryStringList(_orderByFields);
    var primaryKey = mapped.tryStringList(_primaryKey);
    var defaultPageSize = mapped.tryInt(_defaultPageSize);
    if (defaultPageSize == 0) defaultPageSize = 10;
    var mappedDataSources = mapped.tryStringList(_mappedDataSources);

    var dynamicFilters = mapped.tryDynamicList(_filters);
    var filters = List<Filter>();
    for (var dynamicFilter in dynamicFilters) {
      var mappedFilter = tryCast<Map<String, dynamic>>(dynamicFilter, {});
      var filter = Filter.fromJson(mappedFilter);
      if (filter != null) filters.add(filter);
    }
    return Settings(
      server: server,
      port: port,
      username: username,
      password: password,
      database: database,
      schema: schema,
      table: table,
      selectFields: selectFields,
      orderByFields: orderByFields,
      primaryKey: primaryKey,
      filters: filters,
      defaultPageSize: defaultPageSize,
      mappedDataSources: mappedDataSources,
    );
  }
}

class Filter {
  Filter({this.worksheet, this.fieldName, this.mapsTo});

  final String worksheet;
  final String fieldName;
  final String mapsTo;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      _worksheet: worksheet,
      _fieldName: fieldName,
      _mapsTo: mapsTo,
    };
  }

  static Filter fromJson(Map<String, dynamic> jsonMap) {
    var worksheet = jsonMap.tryString(_worksheet);
    var fieldName = jsonMap.tryString(_fieldName);
    var mapsTo = jsonMap.tryString(_mapsTo);
    if ([worksheet, fieldName, mapsTo].contains("")) {
      return null;
    }
    return Filter(worksheet: worksheet, fieldName: fieldName, mapsTo: mapsTo);
  }
}

List<String> parseFixedList(String fixedList){
  if (!isFixedList(fixedList)) return [];
  var itemStr = getEditModeData(fixedList);
  return itemStr.split('|');
}

String generateFixedList(List<String> fixedListItems) {
  return "${editFixedList}:${fixedListItems.join('|')}";
}

bool isFixedList(String fixedList){
  var regex = RegExp("^$editFixedList:([^|\r\n]+)?(\\|[^|\r\n]+)*\$");
  return regex.hasMatch(fixedList);
}

String getEditMode(String editMode){
  if ([editNone,editText,editInteger,editNumber,editBool,editDate].contains(editMode)) return editMode;
  if (isFixedList(editMode)){
    return editFixedList;
  }
  return editNone;
}

String getEditModeData(String editMode){
  if (isFixedList(editMode)){
    return editMode.replaceRange(0, editFixedList.length+1, "");
  }
  return "";
}
