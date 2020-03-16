import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/settings.dart';

main(){
  test("Test",(){
    var jsonSettings = '{"server":"127.0.0.1","port":"1433","username":"user","password":"12345","database":"mydb","schema":"dbo","table":"test","selectFields":["field1","field2"],"orderByFields":["field1"],"primaryKey":["field1"],"filters":[{"worksheet":"sheet1","fieldName":"SomeField","mapsTo":"field1"}]}';
    var settings = Settings.fromJson(jsonSettings);
    expect(settings.toJson(), equals(jsonSettings));
  });
}