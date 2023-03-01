import 'dart:convert';

import 'package:tableau_crud_ui/io/settings.dart';

class RequestData {
  RequestData({required this.connectionData, required this.functionData});
  final ConnectionData connectionData;
  final FunctionData functionData;

  String toJson(){
    var request = {
      "Server": connectionData.server,
      "Port": connectionData.port,
      "Username": connectionData.username,
      "Password": connectionData.password,
      "Database": connectionData.database,
      "Schema": connectionData.schema,
      "Table": connectionData.table,
      "Function": functionData.function(),
      "Parameters": functionData.parameters(),
    };
    return jsonEncode(request);
  }
}

class ConnectionData {
  ConnectionData({required this.server, required this.port, required this.username, required this.password, required this.database, required this.schema, required this.table});
  final String server;
  final String port;
  final String username;
  final String password;
  final String database;
  final String schema;
  final String table;

  RequestData generateRequest(FunctionData functionData){
    return RequestData(connectionData: this, functionData: functionData);
  }

  static ConnectionData fromSettings(Settings settings){
    return ConnectionData(
      server: settings.server,
      port: settings.port,
      username: settings.username,
      password: settings.password,
      database: settings.database,
      schema: settings.schema,
      table: settings.table,
    );
  }
}

abstract class FunctionData {
  String function();
  Map<String, dynamic> parameters();
}

class TestConnectionFunction extends FunctionData {
  String function() => 'TestConnection';
  parameters() => {};
}

class InsertFunction extends FunctionData {
  InsertFunction(this.insertValues);
  final Map<String, dynamic> insertValues;
  String function() => 'Insert';
  Map<String, dynamic> parameters() => {"values": insertValues};
}

abstract class Where {
  String get        field;
  String get        operator;
  bool get          exclude;
  bool get          includeNulls;
  List<dynamic> get values;

  Map<String, dynamic> toMap(){
    return {
      "field": field,
      "operator": operator,
      "values": values,
      "includeNulls": includeNulls,
      "exclude": exclude,
    };
  }
}

class WhereEqual extends Where {
  WhereEqual(String field, dynamic value){
    _field = field;
    _value = value;
  }

  late String _field;
  dynamic _value;

  String get field => _field;
  String get operator => 'equals';
  bool   get exclude => false;
  bool   get includeNulls => false;
  List<dynamic> get values => [_value];
}

class WhereIn extends Where {
  WhereIn(String field, bool exclude, List<dynamic> values){
    _field = field;
    _values = values;
    _exclude = exclude;
  }

  late String _field;
  late bool   _exclude;
  late List<dynamic> _values;

  String get field => _field;
  String get operator => 'in';
  bool   get exclude => _exclude;
  bool   get includeNulls => false;
  List<dynamic> get values => _values;
}

class WhereRange extends Where {
  WhereRange(String field, dynamic min, dynamic max, bool includeNulls){
    _field = field;
    _min = min;
    _max = max;
    _includeNulls = includeNulls;
  }

  late String _field;
  dynamic _min;
  dynamic _max;
  late bool    _includeNulls;

  String get field => _field;
  String get operator => 'range';
  bool   get includeNulls => _includeNulls;
  bool   get exclude => false;
  List<dynamic> get values => [_min, _max];
}

class DeleteFunction extends FunctionData {
  DeleteFunction({required this.whereClauses});
  final List<Where> whereClauses;

  String function() => 'Delete';
  Map<String, dynamic> parameters() {
    List<Map<String,dynamic>> whereMap = whereClauses.map((v)=>v.toMap()).toList();
    return {
      "where": whereMap,
    };
  }
}

class UpdateFunction extends FunctionData {
  UpdateFunction({required this.whereClauses, required this.updates});
  final List<Where> whereClauses;
  final Map<String,dynamic> updates;

  String function() => 'Update';
  Map<String, dynamic> parameters() {
    List<Map<String,dynamic>> whereMap = whereClauses.map((v)=>v.toMap()).toList();
    return {
      "where": whereMap,
      "updates": updates,
    };
  }
}

class ReadFunction extends FunctionData {
  ReadFunction({required this.fields, required this.whereClauses, required this.orderBy, required this.pageSize, required this.page});
  final List<String> fields;
  final List<Where> whereClauses;
  final List<String> orderBy;
  final int pageSize;
  final int page;

  String function() => 'Read';
  Map<String, dynamic> parameters() {
    List<Map<String,dynamic>> whereMap = whereClauses.map((v)=>v.toMap()).toList();
    return {
      "fields": fields,
      "where": whereMap,
      "orderBy": orderBy,
      "pageSize": pageSize,
      "page": page,
    };
  }
}
