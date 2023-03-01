import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:tableau_crud_ui/io/parse_responses.dart';

main(){
  test("Parse test connection success", (){
    var response = Response('{"ColumnNames":["id","category","amount","date"],"RowCount":0,"Data":[null,null,null,null],"TotalRowCount":0}', 200);
    var results = parseQuery(response);
    expect(results.hasError, isFalse);
    var data = results.data;
    if (data == null) {
      fail("data is null");
    }
    expect(data.columnCount(), equals(4));
    expect(data.rowCount(), equals(0));
    expect(data.data[0], isNotNull);

    print(data.columnNames.toString());
    print(data.data.toString());
  });

  var multiRowResponse = Response('{"ColumnNames":["id","category","amount","date"],"RowCount":2,"Data":[[1,13],["blah","something"],[123.2,64.02],["2020-01-13T00:00:00Z","2020-02-03T00:00:00Z"]],"TotalRowCount":20}', 200);
  test("Parse read success", (){
    var results = parseQuery(multiRowResponse);
    expect(results.hasError, isFalse);
    var data = results.data;
    if (data == null) {
      fail("data is null");
    }
    expect(data.columnCount(), equals(4));
    expect(data.rowCount(), equals(2));

    print(data.columnNames.toString());
    print(data.data.toString());
  });

  test("Retrieve row in data",(){
    var results = parseQuery(multiRowResponse);
    var data = results.data;
    if (data == null) {
      fail("data is null");
    }
    var value = data.getFieldValueFromRow('category', 1);
    expect(value, equals("something"));
  });

  test("Retrieve field value that does not exist",(){
    var results = parseQuery(multiRowResponse);
    var data = results.data;
    if (data == null) {
      fail("data is null");
    }
    expect(() => data.getFieldValueFromRow('invalid', 1), throwsException);
  });

  test("Retrieve row past end of data",(){
    var results = parseQuery(multiRowResponse);
    var data = results.data;
    if (data == null) {
      fail("data is null");
    }
    expect(() => data.getFieldValueFromRow('category', 10), throwsException);
  });

  test("Retrieve multiple field values in row in data",(){
    var results = parseQuery(multiRowResponse);
    var data = results.data;
    if (data == null) {
      fail("data is null");
    }
    var value = data.getMultiFieldValuesFromRow(['category','id'], 1);
    expect(value, equals(["something",13]));
  });

  test("Parse read failure", (){
    var response = Response('missing ''page'' parameter', 500);
    var results = parseQuery(response);
    expect(results.hasError, isTrue);
    expect(results.error.length, greaterThan(0));
    expect(results.data, isNull);

    print(results.error);
  });

  test("Parse exec response",(){
    var response = Response('1', 200);
    var results = parseExec(response);
    expect(results.hasError, isFalse);
    expect(results.data, equals(1));
  });

  test("Parse exec failure",(){
    var response = Response('missing ''page'' parameter', 500);
    var results = parseExec(response);
    expect(results.hasError, isTrue);
    expect(results.error.length, greaterThan(0));
    expect(results.data, equals(0));

    print(results.error);
  });

  test("Parse query invalid json response",(){
    var response = Response('{"invalid": "JSON"}', 200);
    var results = parseQuery(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });

  test("Parse exec invalid int",(){
    var response = Response('abcdefg', 200);
    var results = parseExec(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });

  test("Parse query not json",(){
    var response = Response('invalid JSON', 200);
    var results = parseQuery(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });
}