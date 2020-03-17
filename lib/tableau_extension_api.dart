@JS('tableau')
library Tableau.js;

import 'package:js/js.dart';


@JS('extensions.initializeAsync')
external dynamic initializeAsync();

@JS('extensions.dashboardContent.dashboard.worksheets')
external List<Worksheet> get worksheets;

@JS('extensions.settings.saveAsync')
external dynamic saveSettingsAsync();

@JS('extensions.settings.set')
external void setSetting(String key, String value);

@JS('extensions.settings.getAll')
external Settings getAllSettings();

@JS()
class Worksheet {
  external String get name;
  external dynamic getFiltersAsync();
}

@JS()
class Filter {
  external String get fieldId;
  external String get fieldName;
  external String get filterType;
  external bool get isExcludeMode;
  external List<DataValue> get appliedValues;
  external DataValue get minValue;
  external DataValue get maxValue;
}

@JS()
class DataValue {
  external dynamic get value;
}

@JS()
class Settings {
  external String get settings;
}
