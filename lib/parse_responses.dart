import 'dart:convert';
import 'package:tableau_crud_ui/response_objects.dart';

class QueryData {
  QueryData({this.columnNames, this.data}) : assert(columnNames != null && data != null);
  final List<String> columnNames;
  final List<List<dynamic>> data;
}

ResponseObject<QueryResults> parseQuery(String queryResponse) {
  try {
    var decoded = jsonDecode(queryResponse);
    var success = decoded['Success'] as bool;
    var error = '';
    if (success == null || !success) {
      error = decoded['Data'] as String;
      if (error == null) error = '';
      return _errorResponse<QueryResults>(error, null);
    }

    var columnNames = List<String>();
    var data = List<List<dynamic>>();

    var decodedColumnNames = decoded['Data']['ColumnNames'] as List<dynamic>;
    for (var name in decodedColumnNames){
      columnNames.add(name as String);
    }

    var decodedData = decoded['Data']['Data'] as List<dynamic>;
    if (decodedData == null) decodedData = List<List<dynamic>>();
    for (var column in decodedData){
      if (column == null){
        data.add(List<dynamic>());
      } else {
        data.add(column as List<dynamic>);
      }
    }
    var queryResults = QueryResults(columnNames: columnNames, data: data);
    return ResponseObject<QueryResults>(hasError: false, error: '', data: queryResults);

  } on Exception catch (ex) {
    return _errorResponse<QueryResults>(ex.toString(), null);
  }
}

ResponseObject<int> parseExec(String execResponse){
  try{
    var decoded = jsonDecode(execResponse);
    var success = decoded['Success'] as bool;
    var error = '';
    if (success == null || !success) {
      error = decoded['Data'] as String;
      if (error == null) error = '';
      return _errorResponse<int>(error, 0);
    }

    var value = decoded['Data'] as int;
    if (value == null) value = 0;
    return ResponseObject<int>(hasError: false, error: '', data: value);
  } on Exception catch (ex){
    return _errorResponse<int>(ex.toString(), 0);
  }
}

ResponseObject<T> _errorResponse<T>(String error, T defaultData) {
  return ResponseObject<T>(
    hasError: true,
    error: error,
    data: defaultData,
  );
}