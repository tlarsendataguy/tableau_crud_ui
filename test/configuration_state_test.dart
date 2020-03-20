

import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/configuration_state.dart';
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

main(){
  var dbIo = DbMockSuccessIo();
  var tIo = TableauMockIo();
  tIo.saveSettings(testSettings.toJson());

  test("Initialize configuration state from saved settings",() async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2']]));
    expect(state.orderByFields, emitsInOrder([isEmpty,['pk']]));
    expect(state.primaryKey, emitsInOrder([isEmpty,['pk']]));
    expect(state.filters, emitsInOrder([isEmpty, isNotEmpty]));
    expect(state.columnNames, emitsInOrder([isEmpty,["id","category","amount","date"]]));

    await state.initialize();
    expect(state.server, equals("test server"));
    expect(state.port, equals("test port"));
    expect(state.username, equals("test username"));
    expect(state.password, equals("test password"));
    expect(state.database, equals("test database"));
    expect(state.schema, equals("test schema"));
    expect(state.table, equals("test table"));
  });

  test("Test connection", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    state.server = 'test server';
    state.port = 'test port';
    state.username = 'test username';
    state.password = 'test password';
    state.database = 'test database';
    state.schema = 'test schema';
    state.table = 'test table';
    expect(state.columnNames, emitsInOrder([isEmpty,["id","category","amount","date"]]));

    var error = await state.testConnection();
    expect(error, equals(''));
  });

  test("Change pages", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.page, emitsInOrder([Page.connection, Page.selectFields, Page.orderByFields, Page.filters]));
    state.goToPage(Page.selectFields);
    state.goToPage(Page.orderByFields);
    state.goToPage(Page.filters);
  });

  test("Get worksheets", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.worksheets, isNull);
    await state.initialize();
    expect(state.worksheets, equals(['sheet1','sheet2']));
  });

  test("Get filters",() async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    await state.initialize();
    var filters = await state.getFilters('sheet1');
    expect(filters.length, equals(1));
  });

  test("Generate settings", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    await state.initialize();
    state.server = 'new server';
    state.port = 'new port';
    state.username = 'new username';
    state.password = 'new password';
    state.database = 'new database';
    state.schema = 'new schema';
    state.table = 'new table';
    var settings = state.generateSettings();
    expect(settings.server, equals('new server'));
    expect(settings.port, equals('new port'));
    expect(settings.username, equals('new username'));
    expect(settings.password, equals('new password'));
    expect(settings.database, equals('new database'));
    expect(settings.schema, equals('new schema'));
    expect(settings.table, equals('new table'));
    expect(settings.selectFields, equals(['field 1','field 2']));
  });

  test("Update select fields", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2'],['some other field']]));
    await state.initialize();
    state.setSelectFields(['some other field']);
  });

  test("Update order by fields", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.orderByFields, emitsInOrder([isEmpty,['pk'],['some other field']]));
    await state.initialize();
    state.setOrderByFields(['some other field']);
  });

  test("Update primary key fields", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.primaryKey, emitsInOrder([isEmpty,['pk'],['some other field']]));
    await state.initialize();
    state.setPrimaryKey(['some other field']);
  });

  test("Update filters", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(
      state.filters.map((e)=>e.map((f)=>f.mapsTo)),
      emitsInOrder([isEmpty,['field 1'],['some other field']]),
    );
    await state.initialize();
    state.setFilters([
      Filter(
        worksheet: 'sheet1',
        fieldName: 'some field on sheet1',
        mapsTo: 'some other field',
      ),
    ]);
  });
}