import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/io/parse_responses.dart';

main(){
  test("Parse test connection success", (){
    var response = '{"Success":true,"Data":{"ColumnNames":["id","category","amount","date"],"RowCount":0,"Data":[null,null,null,null],"TotalRowCount":0}}';
    var results = parseQuery(response);
    expect(results.hasError, isFalse);
    expect(results.data.columnCount(), equals(4));
    expect(results.data.rowCount(), equals(0));
    expect(results.data.data[0], isNotNull);

    print(results.data.columnNames.toString());
    print(results.data.data.toString());
  });

  var multiRowResponse = '{"Success":true,"Data":{"ColumnNames":["id","category","amount","date"],"RowCount":2,"Data":[[1,13],["blah","something"],[123.2,64.02],["2020-01-13T00:00:00Z","2020-02-03T00:00:00Z"]],"TotalRowCount":20}}';
  test("Parse read success", (){
    var results = parseQuery(multiRowResponse);
    expect(results.hasError, isFalse);
    expect(results.data.columnCount(), equals(4));
    expect(results.data.rowCount(), equals(2));

    print(results.data.columnNames.toString());
    print(results.data.data.toString());
  });

  test("Retrieve row in data",(){
    var results = parseQuery(multiRowResponse);
    var value = results.data.getFieldValueFromRow('category', 1);
    expect(value, equals("something"));
  });

  test("Retrieve field value that does not exist",(){
    var results = parseQuery(multiRowResponse);
    expect(() => results.data.getFieldValueFromRow('invalid', 1), throwsException);
  });

  test("Retrieve row past end of data",(){
    var results = parseQuery(multiRowResponse);
    expect(() => results.data.getFieldValueFromRow('category', 10), throwsException);
  });

  test("Retrieve multiple field values in row in data",(){
    var results = parseQuery(multiRowResponse);
    var value = results.data.getMultiFieldValuesFromRow(['category','id'], 1);
    expect(value, equals(["something",13]));
  });

  test("Parse read failure", (){
    var response = '{"Success":false,"Data":"missing ''page'' parameter"}';
    var results = parseQuery(response);
    expect(results.hasError, isTrue);
    expect(results.error.length, greaterThan(0));
    expect(results.data, isNull);

    print(results.error);
  });

  test("Parse exec response",(){
    var response = '{"Success":true,"Data":1}';
    var results = parseExec(response);
    expect(results.hasError, isFalse);
    expect(results.data, equals(1));
  });

  test("Parse exec failure",(){
    var response = '{"Success":false,"Data":"missing ''page'' parameter"}';
    var results = parseExec(response);
    expect(results.hasError, isTrue);
    expect(results.error.length, greaterThan(0));
    expect(results.data, equals(0));

    print(results.error);
  });

  test("Parse query invalid json response",(){
    var response = '{"invalid": "JSON"}';
    var results = parseQuery(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });

  test("Parse exec invalid json response",(){
    var response = '{"invalid": "JSON"}';
    var results = parseExec(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });

  test("Parse query not json",(){
    var response = 'invalid JSON';
    var results = parseQuery(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });

  test("Parse exec not json",(){
    var response = 'invalid JSON';
    var results = parseExec(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });

  test("Parse encrypted password",(){
    var response = '{"Success":true,"Data":"I am encrypted!"}';
    var results = parsePassword(response);
    expect(results.hasError, isFalse);
    expect(results.data, equals("I am encrypted!"));
  });

  test("Parse encrypted password invalid JSON",(){
    var response = 'invalid JSON';
    var results = parsePassword(response);
    expect(results.hasError, isTrue);
    print(results.error);
  });
}