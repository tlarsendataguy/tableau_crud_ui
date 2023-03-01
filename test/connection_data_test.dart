import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/io/connection_data.dart';

main(){
  var connectionData = ConnectionData(
    apiKey: 'apiKey',
    connection: 'connection',
    table: 'some_table',
  );

  test("Test json generated to test connection",(){
    var request = connectionData.generateRequest(TestConnectionFunction());
    var requestJson = request.toJson();
    expect(requestJson, equals('{"ApiKey":"apiKey","Connection":"connection","Table":"some_table"}'));
    print(requestJson);
  });

  test("Test json generated to insert record",(){
    var request = connectionData.generateRequest(InsertFunction({"Field1":"test", "Field2": 123}));
    var requestJson = request.toJson();
    expect(requestJson, equals('{"ApiKey":"apiKey","Connection":"connection","Table":"some_table","Values":{"Field1":"test","Field2":123}}'));
    print(requestJson);
  });

  test("Test json generated to delete record",(){
    var request = connectionData.generateRequest(DeleteFunction(
      whereClauses: [
        WhereEqual('field1', 10),
        WhereIn('field2', false, ['A','B','C']),
        WhereRange('field3', 0, 10, false),
      ],
    ));
    var requestJson = request.toJson();
    expect(requestJson, equals('{"ApiKey":"apiKey","Connection":"connection","Table":"some_table","Where":[{"field":"field1","operator":"equals","values":[10],"includeNulls":false,"exclude":false},{"field":"field2","operator":"in","values":["A","B","C"],"includeNulls":false,"exclude":false},{"field":"field3","operator":"range","values":[0,10],"includeNulls":false,"exclude":false}]}'));
    print(requestJson);
  });

  test("Test json generated to update record",(){
    var request = connectionData.generateRequest(UpdateFunction(
      whereClauses: [
        WhereEqual('field1', 10),
      ],
      updates: {
        "field1":"A",
        "field2":123,
      },
    ));
    var requestJson = request.toJson();
    expect(requestJson, equals('{"ApiKey":"apiKey","Connection":"connection","Table":"some_table","Where":[{"field":"field1","operator":"equals","values":[10],"includeNulls":false,"exclude":false}],"Updates":{"field1":"A","field2":123}}'));
    print(requestJson);
  });

  test("Test json generated to read records",(){
    var request = connectionData.generateRequest(ReadFunction(
      whereClauses: [
        WhereEqual('field1', 10),
      ],
      fields: ["field1","field2"],
      orderBy: ["field1"],
      pageSize: 10,
      page: 1,
    ));
    var requestJson = request.toJson();
    expect(requestJson, equals('{"ApiKey":"apiKey","Connection":"connection","Table":"some_table","Fields":["field1","field2"],"Where":[{"field":"field1","operator":"equals","values":[10],"includeNulls":false,"exclude":false}],"OrderBy":["field1"],"PageSize":10,"Page":1}'));
    print(requestJson);
  });
}