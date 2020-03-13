import 'dart:convert';

class ConnectionData {
  ConnectionData({this.server, this.port, this.username, this.password, this.database, this.schema, this.table});
  final String server;
  final String port;
  final String username;
  final String password;
  final String database;
  final String schema;
  final String table;

  RequestData<T> generateRequest<T>(FunctionData functionData){
    return RequestData<T>(connectionData: this, functionData: functionData);
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
  Map<String, dynamic> parameters() => insertValues;
}

abstract class Where {
  String get field;
  String get operator;
  List<dynamic> get values;

  Map<String, dynamic> toMap(){
    return {
      "field": field,
      "operator": operator,
      "values": values,
    };
  }
}

class WhereEqual extends Where {
  WhereEqual(String field, dynamic value){
    _field = field;
    _value = value;
  }

  String _field;
  dynamic _value;

  String get field => _field;
  String get operator => 'equals';
  List<dynamic> get values => [_value];
}

class WhereIn extends Where {
  WhereIn(String field, List<dynamic> values){
    _field = field;
    _values = values;
  }

  String _field;
  List<dynamic> _values;

  String get field => _field;
  String get operator => 'in';
  List<dynamic> get values => _values;
}

class WhereRange extends Where {
  WhereRange(String field, dynamic min, dynamic max){
    _field = field;
    _min = min;
    _max = max;
  }

  String _field;
  dynamic _min;
  dynamic _max;

  String get field => _field;
  String get operator => 'range';
  List<dynamic> get values => [_min, _max];
}

class DeleteFunction extends FunctionData {
  DeleteFunction({this.whereClauses});
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
  UpdateFunction({this.whereClauses,this.updates});
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
  ReadFunction({this.fields, this.whereClauses, this.orderBy, this.pageSize, this.page});
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

class RequestData<T> {
  RequestData({this.connectionData, this.functionData}) : assert(connectionData != null && functionData != null);
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

