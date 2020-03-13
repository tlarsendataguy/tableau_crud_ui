
import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/connection_data.dart';

main(){
  var connectionData = ConnectionData(
    server: 'server',
    port: 'port',
    username: 'username',
    password: 'password',
    database: 'test',
    schema: 'dbo',
    table: 'some_table',
  );

  test("Test json generated to test connection",(){
    var request = connectionData.generateRequest(TestConnectionFunction());
    var requestJson = request.toJson();
    expect(requestJson, equals('{"Server":"server","Port":"port","Username":"username","Password":"password","Database":"test","Schema":"dbo","Table":"some_table","Function":"TestConnection","Parameters":{}}'));
    print(requestJson);
  });

  test("Test json generated to insert record",(){
    var request = connectionData.generateRequest(InsertFunction({"Field1":"test", "Field2": 123}));
    var requestJson = request.toJson();
    expect(requestJson, equals('{"Server":"server","Port":"port","Username":"username","Password":"password","Database":"test","Schema":"dbo","Table":"some_table","Function":"Insert","Parameters":{"Field1":"test","Field2":123}}'));
    print(requestJson);
  });

  test("Test json generated to delete record",(){
    var request = connectionData.generateRequest(DeleteFunction(
      whereClauses: [
        WhereEqual('field1', 10),
        WhereIn('field2', ['A','B','C']),
        WhereRange('field3', 0, 10),
      ],
    ));
    var requestJson = request.toJson();
    expect(requestJson, equals('{"Server":"server","Port":"port","Username":"username","Password":"password","Database":"test","Schema":"dbo","Table":"some_table","Function":"Delete","Parameters":{"where":[{"field":"field1","operator":"equals","values":[10]},{"field":"field2","operator":"in","values":["A","B","C"]},{"field":"field3","operator":"range","values":[0,10]}]}}'));
    print(requestJson);
  });
}