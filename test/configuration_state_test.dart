

import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/state_and_model/configuration_state.dart';
import 'package:tableau_crud_ui/state_and_model/io.dart';
import 'package:tableau_crud_ui/state_and_model/settings.dart';

var testSettings = Settings(
  server: 'test server',
  port: 'test port',
  username: 'test username',
  password: 'test password',
  database: 'test database',
  schema: 'test schema',
  table: 'test table',
  selectFields: {'field 1': editNone, 'field 2': editText},
  orderByFields: ['pk1','pk2'],
  primaryKey: ['pk1','pk2'],
  filters: [Filter(worksheet: 'test worksheet', fieldName: 'test field', mapsTo: 'field 1')],
  mappedDataSources: [],
);

main(){
  var dbIo = DbMockSuccessIo();
  var tIo = TableauMockIo();
  tIo.saveSettings(testSettings.toJson());

  test("Initialize configuration state from saved settings",() async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2']]));
    expect(state.orderByFields, emitsInOrder([isEmpty,['pk1','pk2']]));
    expect(state.primaryKey, emitsInOrder([isEmpty,['pk1','pk2']]));
    expect(state.filters, emitsInOrder([isEmpty, isNotEmpty]));
    expect(state.columnNames, emitsInOrder([isEmpty,["id","category","amount","date","comment","is true"]]));
    expect(state.mappedDataSources, emitsInOrder([isEmpty,isEmpty]));

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
    expect(state.columnNames, emitsInOrder([isEmpty,["id","category","amount","date","comment","is true"]]));

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
    expect(settings.selectFields, equals({'field 1':editNone,'field 2':editText}));
    expect(settings.defaultPageSize, equals(10));
  });

  test("Add select field", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2'],['field 1','field 2', 'some other field']]));
    await state.initialize();
    state.addSelectField('some other field');
  });

  test("Remove select field", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2'],['field 1']]));
    await state.initialize();
    state.removeSelectField('field 2');
  });

  test("Move select field up", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2'],['field 2','field 1']]));
    await state.initialize();
    state.moveSelectFieldUp('field 2');
  });

  test("Move select field down", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2'],['field 2','field 1']]));
    await state.initialize();
    state.moveSelectFieldDown('field 1');
  });

  test("Add order by field", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.orderByFields, emitsInOrder([isEmpty,['pk1','pk2'],['pk1','pk2','some other field']]));
    await state.initialize();
    state.addOrderByField('some other field');
  });

  test("Remove order by field", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.orderByFields, emitsInOrder([isEmpty,['pk1','pk2'],['pk1']]));
    await state.initialize();
    state.removeOrderByField('pk2');
  });

  test("Move order by field up", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.orderByFields, emitsInOrder([isEmpty,['pk1','pk2'],['pk2','pk1']]));
    await state.initialize();
    state.moveOrderByFieldUp('pk2');
  });

  test("Move order by field down", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.orderByFields, emitsInOrder([isEmpty,['pk1','pk2'],['pk2','pk1']]));
    await state.initialize();
    state.moveOrderByFieldDown('pk1');
  });

  test("Add primary key field", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.primaryKey, emitsInOrder([isEmpty,['pk1','pk2'],['pk1','pk2','some other field']]));
    await state.initialize();
    state.addPrimaryKeyField('some other field');
  });

  test("Remove primary key field", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.primaryKey, emitsInOrder([isEmpty,['pk1','pk2'],['pk1']]));
    await state.initialize();
    state.removePrimaryKeyField('pk2');
  });

  test("Add filter", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(
      state.filters.map((e)=>e.map((f)=>f.mapsTo)),
      emitsInOrder([isEmpty,['field 1'],['field 1','some other field']]),
    );
    await state.initialize();
    state.addFilter(
      worksheet: 'sheet1',
      fieldName: 'some field on sheet1',
      mapsTo: 'some other field',
    );
  });

  test("Remove filter", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(
      state.filters.map((e)=>e.map((f)=>f.mapsTo)),
      emitsInOrder([isEmpty,['field 1'],isEmpty]),
    );
    await state.initialize();
    state.removeFilter(worksheet: 'test worksheet', fieldName: 'test field', mapsTo: 'field 1');
  });

  test("Get select field edit value",()async{
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    await state.initialize();
    var editValue = state.getSelectFieldEditMode('field 1');
    expect(editValue, equals(editNone));
  });

  test("Update select field edit value",()async{
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.selectFields, emitsInOrder([isEmpty,['field 1','field 2'],['field 1','field 2']]));
    await state.initialize();
    state.updateSelectFieldEditMode('field 1',editInteger);
    var editValue = state.getSelectFieldEditMode('field 1');
    expect(editValue, equals(editInteger));
  });

  test("Add and remove mapped data source", () async {
    var state = ConfigurationState(tIo: tIo, dbIo: dbIo);
    expect(state.mappedDataSources, emitsInOrder([isEmpty,isEmpty,isNotEmpty,isEmpty]));
    await state.initialize();

    state.addMappedDataSource('id1');
    state.removeMappedDataSource('id1');
  });
}