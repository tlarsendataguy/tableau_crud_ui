class ResponseObject<T> {
  ResponseObject({this.hasError, this.error, this.data})
      : assert(hasError != null &&
            error != null &&
            ((!hasError && data != null) || hasError));

  final bool hasError;
  final String error;
  final T data;
}

class QueryResults {
  QueryResults({this.columnNames, this.data})
      : assert(columnNames != null && data != null);
  final List<String> columnNames;
  final List<List<dynamic>> data;

  int rowCount(){
    if (data.length > 0) {
      return data[0].length;
    }
    return 0;
  }

  int columnCount(){
    return data.length;
  }
}
