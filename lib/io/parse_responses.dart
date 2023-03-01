import 'dart:convert';
import 'package:http/http.dart';
import 'package:tableau_crud_ui/io/response_objects.dart';

class QueryData {
  QueryData({required this.columnNames, required this.data});
  final List<String> columnNames;
  final List<List<dynamic>> data;
}

ResponseObject<QueryResults?> parseQuery(Response queryResponse) {
  try {
    if (queryResponse.statusCode != 200) {
      return _errorResponse(queryResponse.body, null);
    }
    var decoded = jsonDecode(queryResponse.body);
    if (decoded['ColumnNames'] == null || decoded['Data'] == null || decoded['TotalRowCount'] == null) {
      return _errorResponse("response '${queryResponse.body}' was not in the expected json format", null);
    }
    var columnNames = <String>[];
    var data = <List<dynamic>>[];

    var decodedColumnNames = decoded['ColumnNames'] as List<dynamic>;
    for (var name in decodedColumnNames){
      columnNames.add(name as String);
    }

    var decodedData = decoded['Data'] as List<dynamic>?;
    if (decodedData == null) decodedData = <List<dynamic>>[];
    for (var column in decodedData){
      if (column == null){
        data.add(<dynamic>[]);
      } else {
        data.add(column as List<dynamic>);
      }
    }
    var totalRowCount = decoded['TotalRowCount'] as int;
    var queryResults = QueryResults(columnNames: columnNames, data: data, totalRowCount: totalRowCount);
    return ResponseObject<QueryResults>(hasError: false, error: '', data: queryResults);

  } on Exception catch (ex) {
    return _errorResponse<QueryResults?>(ex.toString(), null);
  }
}

ResponseObject<int> parseExec(Response execResponse){
  try{
    if (execResponse.statusCode != 200) {
      return _errorResponse(execResponse.body, 0);
    }
    var value = int.parse(execResponse.body);
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