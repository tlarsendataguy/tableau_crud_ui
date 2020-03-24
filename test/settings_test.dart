import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/settings.dart';

main(){
  test("Test from and to JSON",(){
    var jsonSettings = '{"server":"127.0.0.1","port":"1433","username":"user","password":"12345","database":"mydb","schema":"dbo","table":"test","selectFields":{"field1":"None","field2":"Text"},"orderByFields":["field1"],"primaryKey":["field1"],"filters":[{"worksheet":"sheet1","fieldName":"SomeField","mapsTo":"field1"}],"defaultPageSize":10,"mappedDataSources":[]}';
    var settings = Settings.fromJson(jsonSettings);
    expect(settings.toJson(), equals(jsonSettings));
  });

  test("Validate when errors are present",(){
    var settings = Settings(
        selectFields: {},
        primaryKey: [],
        orderByFields: []
    );
    var error = settings.validate();
    expect(error, equals("no fields were selected, no primary key was selected, no order by fields were defined"));
  });

  test("Validate without errors",(){
    var settings = Settings(
        selectFields: {'field 1':editNone},
        primaryKey: ['field 1'],
        orderByFields: ['field 1']
    );
    var error = settings.validate();
    expect(error, equals(""));
  });

  test("Test from JSON when empty",(){
    var jsonSettings = '{}';
    var settings = Settings.fromJson(jsonSettings);
    expect(settings.isEmpty(), isTrue);
    expect(settings.toJson(), equals('{"server":"","port":"","username":"","password":"","database":"","schema":"","table":"","selectFields":{},"orderByFields":[],"primaryKey":[],"filters":[],"defaultPageSize":10,"mappedDataSources":[]}'));
    expect(settings.defaultPageSize, equals(10));
  });
}