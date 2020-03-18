import 'package:js/js_util.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/settings.dart';
import 'package:tableau_crud_ui/tableau_extension_api.dart' as api;

class TableauExtensionIo extends TableauIo {
  Future initialize() async => await promiseToFuture(api.initializeAsync());
  Future<String> getContext() async => api.context;

  Future<List<TableauFilter>> getFilters(String worksheetName) async {
    for (var worksheet in api.worksheets){
      if (worksheet.name != worksheetName) continue;

      var tFilters = await promiseToFuture<List<api.Filter>>(worksheet.getFiltersAsync());
      var filters = List<TableauFilter>();
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
    return Settings.fromJson(setting.settings);
  }

  Future<List<String>> getWorksheets() async {
    var worksheetNames = List<String>();
    for (var worksheet in api.worksheets){
      worksheetNames.add(worksheet.name);
    }
    return worksheetNames;
  }

  Future saveSettings(String settingsJson) async {
    api.setSetting('settings', settingsJson);
    await promiseToFuture(api.saveSettingsAsync());
  }
}

