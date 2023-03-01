import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:tableau_crud_ui/io/io.dart';
import 'package:tableau_crud_ui/io/settings.dart';
import 'package:tableau_crud_ui/io/tableau_extension_api.dart' as api;

class TableauExtensionIo extends TableauIo {
  
  var _toUnregister = <Function>[];
  
  Future initialize() async => await promiseToFuture(api.initializeAsync());
  Future<String> getContext() async => api.context;

  Future<List<String>> getParameters() async {
    var tParams = await promiseToFuture<List<api.Parameter>>(api.getParametersAsync());
    List<String> params = [];
    for (var param in tParams) {
      params.add(param.name);
    }
    return params;
  }

  Future<Parameter?> getParameter(String name) async {
    var tParam = await promiseToFuture<api.Parameter?>(api.findParameterAsync(name));
    if (tParam == null) {
      return null;
    }
    return Parameter(
      name: tParam.name,
      id: tParam.id,
      dataType: tParam.dataType,
      value: tParam.currentValue.value,
      formattedValue: tParam.currentValue.formattedValue,
    );
  }

  Future<List<TableauFilter>> getFilters(String worksheetName) async {
    for (var worksheet in api.worksheets){
      if (worksheet.name != worksheetName) continue;

      var tFilters = await promiseToFuture<List<api.Filter>>(worksheet.getFiltersAsync());
      var filters = <TableauFilter>[];
      for (var tFilter in tFilters){
        if (tFilter.filterType == 'categorical'){
          filters.add(TableauFilter(
            fieldId: tFilter.fieldId,
            fieldName: tFilter.fieldName,
            filterType: tFilter.filterType,
            isAllSelected: tFilter.isAllSelected,
            includeNullValues: false,
            exclude: tFilter.isExcludeMode,
            values: tFilter.appliedValues.map((e) {
              if (tFilter.fieldName == 'Measure Names') {
                return e.formattedValue;
              }
              if (api.isDate(e.value)) {
                return api.dateToString(e.value);
              }
              return e.value;
            }).toList(),
          ));
          continue;
        }
        if (tFilter.filterType == 'range'){
          var min = tFilter.minValue.value;
          var max = tFilter.maxValue.value;
          if (min is num && min.isNaN) min = null;
          if (max is num && max.isNaN) max = null;
          if (min == null && max == null) continue;

          filters.add(TableauFilter(
            fieldId: tFilter.fieldId,
            fieldName: tFilter.fieldName,
            filterType: tFilter.filterType,
            includeNullValues: tFilter.includeNullValues,
            isAllSelected: false,
            exclude: false,
            values: [
              api.isDate(min) ? api.dateToString(min) : min,
              api.isDate(max) ? api.dateToString(max) : max,
            ],
          ));
          continue;
        }
      }
      return filters;
    }
    return [];
  }

  Future<Settings> getSettings() async {
    var setting = api.getAllSettings();
    if (!setting.hasOwnProperty('settings')){
      return Settings.fromJson('{}');
    }
    return Settings.fromJson(setting.settings);
  }

  Future<List<String>> getWorksheets() async {
    var worksheetNames = <String>[];
    for (var worksheet in api.worksheets){
      worksheetNames.add(worksheet.name);
    }
    return worksheetNames;
  }

  Future<Map<String,String>> getAllDataSources() async {
    var dataSources = Map<String,String>();
    for (var worksheet in api.worksheets){
      var tDataSources = await promiseToFuture<List<api.DataSource>>(worksheet.getDataSourcesAsync());
      for (var tDataSource in tDataSources){
        dataSources[tDataSource.id] = tDataSource.name;
      }
    }
    return dataSources;
  }

  Future updateDataSources(List<String> ids) async {
    for (var id in ids){
      var found = false;
      for (var worksheet in api.worksheets) {
        var tDataSources = await promiseToFuture<List<api.DataSource>>(
            worksheet.getDataSourcesAsync());
        for (var tDataSource in tDataSources) {
          if (tDataSource.id == id) {
            found = true;
            await promiseToFuture<void>(tDataSource.refreshAsync());
            break;
          }
        }
        if (found) break;
      }
    }
  }

  Future saveSettings(String settingsJson) async {
    api.setSetting('settings', settingsJson);
    await promiseToFuture(api.saveSettingsAsync());
  }

  void registerFilterChangedOn(List<String> worksheets, Function(dynamic) callback){
    for (var worksheet in api.worksheets){
      if (worksheets.contains(worksheet.name)){
        var interop = allowInterop((dynamic event){callback(event);});
        _toUnregister.add(worksheet.addEventListener('filter-changed', interop));
      }
    }
  }

  void unregisterFilterChangedOnAll(){
    for (var unregister in _toUnregister){
      unregister();
    }
  }

  Future registerParameterChangedOn(List<String> parameters, Function(dynamic) callback) async {
    var tParams = await promiseToFuture<List<api.Parameter>>(api.getParametersAsync());
    for (var tParam in tParams){
      if (parameters.contains(tParam.name)){
        var interop = allowInterop((dynamic event){callback(event);});
        _toUnregister.add(tParam.addEventListener('parameter-changed', interop));
      }
    }
  }
}
