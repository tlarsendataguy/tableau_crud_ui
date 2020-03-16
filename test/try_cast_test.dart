import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/try_cast.dart';

main(){
  test("cast string",(){
    dynamic value = "hello world";
    var casted = tryCast<String>(value, "");
    expect(casted, equals("hello world"));
  });

  test("cast null string",(){
    dynamic value;
    var casted = tryCast<String>(value, "null value");
    expect(casted, equals("null value"));
  });

  test("cast non-string to string",(){
    dynamic value = 123;
    var casted = tryCast<String>(value, "not a string");
    expect(casted, equals("not a string"));
  });
}