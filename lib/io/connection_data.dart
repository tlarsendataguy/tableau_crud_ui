import 'dart:convert';

import 'package:tableau_crud_ui/io/settings.dart';

class RequestData {
  RequestData({required this.connectionData, required this.functionData});
  final ConnectionData connectionData;
  final FunctionData functionData;

  String toJson(){
    var request = <String, dynamic>{
      "ApiKey": connectionData.apiKey,
      "Connection": connectionData.connection,
      "Table": connectionData.table,
    };
    request.addAll(functionData.parameters());
    return jsonEncode(request);
  }
}

class ConnectionData {
  ConnectionData({required this.apiKey, required this.connection, required this.table});
  final String apiKey;
  final String connection;
  final String table;

  RequestData generateRequest(FunctionData functionData){
    return RequestData(connectionData: this, functionData: functionData);
  }

  static ConnectionData fromSettings(Settings settings){
    return ConnectionData(
      apiKey: settings.apiKey,
      connection: settings.connection,
      table: settings.table,
    );
  }
}

abstract class FunctionData {
  Map<String, dynamic> parameters();
}

class TestConnectionFunction extends FunctionData {
  parameters() => {};
}

class InsertFunction extends FunctionData {
  InsertFunction(this.insertValues);
  final Map<String, dynamic> insertValues;
  Map<String, dynamic> parameters() => {"Values": insertValues};
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

  Map<String, dynamic> parameters() {
    List<Map<String,dynamic>> whereMap = whereClauses.map((v)=>v.toMap()).toList();
    return {
      "Where": whereMap,
    };
  }
}

class UpdateFunction extends FunctionData {
  UpdateFunction({required this.whereClauses, required this.updates});
  final List<Where> whereClauses;
  final Map<String,dynamic> updates;

  Map<String, dynamic> parameters() {
    List<Map<String,dynamic>> whereMap = whereClauses.map((v)=>v.toMap()).toList();
    return {
      "Where": whereMap,
      "Updates": updates,
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

  Map<String, dynamic> parameters() {
    List<Map<String,dynamic>> whereMap = whereClauses.map((v)=>v.toMap()).toList();
    return {
      "Fields": fields,
      "Where": whereMap,
      "OrderBy": orderBy,
      "PageSize": pageSize,
      "Page": page,
    };
  }
}
