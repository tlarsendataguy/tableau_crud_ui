@JS()
library Tableau.js;

import 'package:js/js.dart';

@JS('tableau.extensions')
external dynamic initializeAsync();

@JS('tableau.extensions.dashboardContent.dashboard')
external List<Worksheet> get worksheets;

@JS('tableau.extensions.settings')
external dynamic saveAsync();
external void set(String key, String value);
external dynamic getAll();

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
