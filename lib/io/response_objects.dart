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
  QueryResults({this.columnNames, this.data, this.totalRowCount})
      : assert(columnNames != null && data != null && totalRowCount != null);
  final List<String> columnNames;
  final List<List<dynamic>> data;
  final int totalRowCount;

  int rowCount(){
    if (data.length > 0) {
      return data[0].length;
    }
    return 0;
  }

  int columnCount(){
    return data.length;
  }

  dynamic getFieldValueFromRow(String fieldName, int row){
    var colIndex = columnNames.indexOf(fieldName);
    if (colIndex == -1)
      throw new Exception("$fieldName is not a column in the data.  Columns available are: $columnNames");

    var column = data[colIndex];
    if (row >= column.length){
      throw new Exception("asked for row $row but the table is only ${column.length} rows long");
    }

    return column[row];
  }

  List<dynamic> getMultiFieldValuesFromRow(List<String> fieldNames, int row){
    var returnValues = List<dynamic>.filled(fieldNames.length, null);
    var index = 0;
    for (var fieldName in fieldNames){
      returnValues[index] = getFieldValueFromRow(fieldName, row);
      index++;
    }
    return returnValues;
  }
}
