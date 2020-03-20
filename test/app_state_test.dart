import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/app_state.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/settings.dart';

var testSettings = Settings(
  server: 'test server',
  port: 'test port',
  username: 'test username',
  password: 'test password',
  database: 'test database',
  schema: 'test schema',
  table: 'test table',
  selectFields: ['field 1', 'field 2'],
  orderByFields: ['pk'],
  primaryKey: ['pk'],
  filters: [Filter(worksheet: 'test worksheet', fieldName: 'test field', mapsTo: 'field 1')],
);

Future<TableauIo> generateTIo() async {
  var tIo = TableauMockIo();
  await tIo.initialize();
  return tIo;
}

main() async {
  var dbIo = DbMockSuccessIo();

  test("Get worksheets",() async {
    var tIo = await generateTIo();
    var state = AppState(tIo: tIo, dbIo: dbIo);
    var worksheets = await state.getWorksheets();
    expect(worksheets.length, equals(2));
    expect(worksheets[0], equals('sheet1'));
    expect(worksheets[1], equals('sheet2'));
  });

  test("Read table", () async {
    var tIo = await generateTIo();
    await tIo.saveSettings(testSettings.toJson());
    var state = AppState(tIo: tIo, dbIo: dbIo);
    expect(state.data, emitsInOrder([isNull, isNotNull,isNotNull]));
    expect(state.readLoaders, emitsInOrder([0,1,2,1,0]));

    await state.initialize();
    var error = await state.readTable();
    expect(error, equals(""));
  });

  test("create new record", () async {
    var tIo = await generateTIo();
    await tIo.saveSettings(testSettings.toJson());
    var state = AppState(tIo: tIo, dbIo: dbIo);
    expect(state.data, emitsInOrder([isNull, isNotNull]));

    await state.initialize();
    var error = await state.insert(['abc', 123]);
    expect(error, equals(""));
  });

  test("update record", () async {
    var tIo = await generateTIo();
    await tIo.saveSettings(testSettings.toJson());
    var state = AppState(tIo: tIo, dbIo: dbIo);
    expect(state.data, emitsInOrder([isNull, isNotNull]));

    await state.initialize();
    var error = await state.update(values: {"field 1": 'xyz', "field 2": 987}, where: {"pk": 1});
    expect(error, equals(""));
  });

  test("delete record", () async {
    var tIo = await generateTIo();
    await tIo.saveSettings(testSettings.toJson());
    var state = AppState(tIo: tIo, dbIo: dbIo);
    expect(state.data, emitsInOrder([isNull, isNotNull]));

    await state.initialize();
    var error = await state.delete(where: {"pk": 1});
    expect(error, equals(""));
  });
}