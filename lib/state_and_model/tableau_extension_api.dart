@JS('tableau')
library Tableau.js;

import 'package:js/js.dart';

@JS('extensions.environment.context')
external String get context;

@JS('extensions.initializeAsync')
external dynamic initializeAsync();

@JS('extensions.dashboardContent.dashboard.worksheets')
external List<Worksheet> get worksheets;

@JS('extensions.dashboardContent.dashboard.getParametersAsync')
external dynamic getParametersAsync();

@JS('extensions.dashboardContent.dashboard.findParameterAsync')
external dynamic findParameterAsync(String name);

@JS('extensions.settings.saveAsync')
external dynamic saveSettingsAsync();

@JS('extensions.settings.set')
external void setSetting(String key, String value);

@JS('extensions.settings.getAll')
external TableauSettings getAllSettings();

@JS('isDate')
external bool isDate(dynamic object);

@JS('dateToString')
external String dateToString(dynamic object);

@JS()
class Worksheet {
  external String get name;
  external dynamic getFiltersAsync();
  external Function addEventListener(String eventType, dynamic handler);
  external dynamic getDataSourcesAsync();
}

@JS()
class DataSource {
  external String get id;
  external String get name;
  external dynamic refreshAsync();
}

@JS()
class Filter {
  external String get fieldId;
  external String get fieldName;
  external String get filterType;
  external bool get isExcludeMode;
  external bool get isAllSelected;
  external bool get includeNullValues;
  external List<DataValue> get appliedValues;
  external DataValue get minValue;
  external DataValue get maxValue;
}

@JS()
class DataValue {
  external dynamic get value;
  external String get formattedValue;
  external bool get instanceof;
}

@JS()
class TableauSettings {
  external String get settings;
  external bool hasOwnProperty(String property);
}

@JS()
class Parameter {
  external DataValue get currentValue;
  external String get name;
  external String get dataType;
  external String get id;
}
