import 'package:js/js_util.dart';
import 'package:tableau_crud_ui/io.dart';
import 'package:tableau_crud_ui/settings.dart';
import 'package:tableau_crud_ui/tableau_extension_api.dart' as api;

class TableauExtensionIo extends TableauIo {
  Future initialize() async {
    await promiseToFuture(api.initializeAsync());
  }

  Future<List<TableauFilter>> getFilters(String worksheet) async {
    return [];
  }

  Future<Settings> getSettings() async {
    var all = await promiseToFuture<Map<String, String>>(api.getAll());
    var settingsJson = all['settings'];
    return Settings.fromJson(settingsJson);
  }

  Future<List<String>> getWorksheets() async {
    var worksheetNames = List<String>();
    for (var worksheet in api.worksheets){
      worksheetNames.add(worksheet.name);
    }
    return worksheetNames;
  }

  Future saveSettings(String settingsJson) async {
    api.set('settings', settingsJson);
    await promiseToFuture(api.saveAsync());
  }
}

