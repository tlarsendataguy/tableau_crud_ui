
final decimalFormat = RegExp(r'^-?[0-9]*\.?[0-9]*$');
final integerFormat = RegExp(r'^-?[0-9]*$');
final dateFormat = RegExp(r'^2[0-9]{3}-[0-1][0-9]-[0-3][0-9]$');
final sampleDate = '2000-01-10';

bool isTextDecimal(String text) {
  return decimalFormat.hasMatch(text) || text.isEmpty;
}

bool isTextInteger(String text) {
  return integerFormat.hasMatch(text) || text.isEmpty;
}

bool isTextDate(String text) {
  if (text.isEmpty) return true;
  if (text.length > 10) return false;
  var filledIn = text;
  if (text.length == 9 && text.substring(8) == '0') {
    filledIn += '1';
  } else {
    filledIn += sampleDate.substring(text.length);
  }
  if (!dateFormat.hasMatch(filledIn)) return false;
  try {
    var parsed = DateTime.parse(filledIn);
    if (parsed.toIso8601String().substring(0,10) != filledIn) return false;
    return true;
  } catch (ex) {
    return false;
  }
}