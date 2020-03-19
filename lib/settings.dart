import 'dart:convert';
import 'package:tableau_crud_ui/try_cast.dart';

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
      }
  );

  final String server;
  final String port;
  final String username;
  final String password;
  final String database;
  final String schema;
  final String table;
  final List<String> selectFields;
  final List<String> orderByFields;
  final List<String> primaryKey;
  final List<Filter> filters;
  final int defaultPageSize;

  bool isEmpty() {
    return server == '' &&
        port == '' &&
        username == '' &&
        password == '' &&
        database == '' &&
        schema == '' &&
        table == '' &&
        selectFields == [] &&
        orderByFields == [] &&
        primaryKey == [] &&
        filters == [] &&
        defaultPageSize == 0;
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
    var selectFields = mapped.tryStringList(_selectFields);
    var orderByFields = mapped.tryStringList(_orderByFields);
    var primaryKey = mapped.tryStringList(_primaryKey);
    var defaultPageSize = mapped.tryInt(_defaultPageSize);

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
