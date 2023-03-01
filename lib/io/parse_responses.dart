import 'dart:convert';
import 'package:tableau_crud_ui/io/response_objects.dart';

class QueryData {
  QueryData({required this.columnNames, required this.data});
  final List<String> columnNames;
  final List<List<dynamic>> data;
}

ResponseObject<QueryResults?> parseQuery(String queryResponse) {
  try {
    var decoded = jsonDecode(queryResponse);
    var success = decoded['Success'] as bool?;
    String? error = '';
    if (success == null || !success) {
      error = decoded['Data'] as String?;
      if (error == null) error = '';
      return _errorResponse<QueryResults?>(error, null);
    }

    var columnNames = <String>[];
    var data = <List<dynamic>>[];

    var decodedColumnNames = decoded['Data']['ColumnNames'] as List<dynamic>;
    for (var name in decodedColumnNames){
      columnNames.add(name as String);
    }

    var decodedData = decoded['Data']['Data'] as List<dynamic>?;
    if (decodedData == null) decodedData = <List<dynamic>>[];
    for (var column in decodedData){
      if (column == null){
        data.add(<dynamic>[]);
      } else {
        data.add(column as List<dynamic>);
      }
    }
    var totalRowCount = decoded['Data']['TotalRowCount'] as int;
    var queryResults = QueryResults(columnNames: columnNames, data: data, totalRowCount: totalRowCount);
    return ResponseObject<QueryResults>(hasError: false, error: '', data: queryResults);

  } on Exception catch (ex) {
    return _errorResponse<QueryResults?>(ex.toString(), null);
  }
}

ResponseObject<int> parseExec(String execResponse){
  try{
    var decoded = jsonDecode(execResponse);
    var success = decoded['Success'] as bool?;
    String? error = '';
    if (success == null || !success) {
      error = decoded['Data'] as String?;
      if (error == null) error = '';
      return _errorResponse<int>(error, 0);
    }

    var value = decoded['Data'] as int?;
    if (value == null) value = 0;
    return ResponseObject<int>(hasError: false, error: '', data: value);
  } on Exception catch (ex){
    return _errorResponse<int>(ex.toString(), 0);
  }
}

ResponseObject<String> parsePassword(String encryptPasswordResponse){
  try {
    var decoded = jsonDecode(encryptPasswordResponse);
    var success = decoded['Success'] as bool?;
    String? error = '';
    if (success == null || !success) {
      error = decoded['Data'] as String?;
      if (error == null) error = '';
      return _errorResponse<String>(error, "");
    }

    var value = decoded['Data'] as String?;
    if (value == null) value = "";
    return ResponseObject<String>(hasError: false, error: '', data: value);
  } on Exception catch (ex){
    return _errorResponse<String>(ex.toString(), "");
  }
}

ResponseObject<T> _errorResponse<T>(String error, T defaultData) {
  return ResponseObject<T>(
    hasError: true,
    error: error,
    data: defaultData,
  );
}