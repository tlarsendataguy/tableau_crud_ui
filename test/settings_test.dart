import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/io/settings.dart';

main(){
  test("Test from and to JSON",(){
    var jsonSettings = '{"server":"127.0.0.1","port":"1433","username":"user","password":"12345","database":"mydb","schema":"dbo","table":"test","selectFields":{"field1":"None","field2":"Text"},"orderByFields":["field1"],"primaryKey":["field1"],"filters":[{"worksheet":"sheet1","fieldName":"SomeField","parameterName":"","mapsTo":"field1"}],"defaultPageSize":10,"mappedDataSources":[],"tableColumns":[],"enableInsert":true,"enableUpdate":false,"enableDelete":false}';
    var settings = Settings.fromJson(jsonSettings);
    expect(settings.toJson(), equals(jsonSettings));
  });

  test("Validate when errors are present",(){
    var settings = Settings(
        selectFields: {},
        primaryKey: [],
        orderByFields: [],
        server: '',
        port: '',
        username: '',
        password: '',
        database: '',
        defaultPageSize: 10,
        enableDelete: false,
        enableInsert: false,
        enableUpdate: false,
        filters: [],
        mappedDataSources: [],
        schema: '',
        table: '',
        tableColumns: []
    );
    var error = settings.validate();
    expect(error, equals("no fields were selected, no primary key was selected, no order by fields were defined"));
  });

  test("Validate without errors",(){
    var settings = Settings(
        selectFields: {'field 1':editNone},
        primaryKey: ['field 1'],
        orderByFields: ['field 1'],
        server: '',
        port: '',
        username: '',
        password: '',
        database: '',
        defaultPageSize: 10,
        enableDelete: false,
        enableInsert: false,
        enableUpdate: false,
        filters: [],
        mappedDataSources: [],
        schema: '',
        table: '',
        tableColumns: []
    );
    var error = settings.validate();
    expect(error, equals(""));
  });

  test("Test from JSON when empty",(){
    var jsonSettings = '{}';
    var settings = Settings.fromJson(jsonSettings);
    expect(settings.isEmpty(), isTrue);
    expect(settings.toJson(), equals('{"server":"","port":"","username":"","password":"","database":"","schema":"","table":"","selectFields":{},"orderByFields":[],"primaryKey":[],"filters":[],"defaultPageSize":10,"mappedDataSources":[],"tableColumns":[],"enableInsert":false,"enableUpdate":false,"enableDelete":false}'));
    expect(settings.defaultPageSize, equals(10));
  });

  test("Parse fixed list edit mode",(){
    var settings = editFixedList + ":Item 1|Item 2|Item 3";
    var fixedListItems = parseFixedList(settings);
    expect(fixedListItems, equals(['Item 1','Item 2','Item 3']));
  });

  test("Parse invalid fixed list edit mode",(){
    var settings = "invalid";
    var fixedListItems = parseFixedList(settings);
    expect(fixedListItems, isEmpty);
  });

  test("Fixed list to string",(){
    var fixedListItems = <String>['Item 1','Item 2','Item 3'];
    var setting = generateFixedList(fixedListItems);
    expect(setting, equals("$editFixedList:Item 1|Item 2|Item 3"));
  });

  test("Is fixed list",(){
    expect(isFixedList("Fixed List:Item 1"), isTrue);
    expect(isFixedList("Fixed List:"), isTrue);
    expect(isFixedList("Fixed List:Item 1|Item 2"), isTrue);
    expect(isFixedList("Fixed List"), isFalse);
    expect(isFixedList("Fixed List:Item\r\n1|Item 2"), isFalse);
  });

  test("Get edit mode",(){
    expect(getEditMode(editNone), equals(editNone));
    expect(getEditMode("$editFixedList:Item 1|Item 2"), equals(editFixedList));
    expect(getEditMode(editDate), equals(editDate));
    expect(getEditMode(editBool), equals(editBool));
    expect(getEditMode(editNumber), equals(editNumber));
    expect(getEditMode(editInteger), equals(editInteger));
    expect(getEditMode(editText), equals(editText));
    expect(getEditMode("invalid"), equals(editNone));
  });

  test("Get edit mode data",(){
    expect(getEditModeData(editNone), equals(""));
    expect(getEditModeData("$editFixedList:Item 1|Item 2"), equals("Item 1|Item 2"));
    expect(getEditModeData(editDate), equals(""));
    expect(getEditModeData(editBool), equals(""));
    expect(getEditModeData(editNumber), equals(""));
    expect(getEditModeData(editInteger), equals(""));
    expect(getEditModeData(editText), equals(""));
    expect(getEditModeData("invalid"), equals(""));
  });
}