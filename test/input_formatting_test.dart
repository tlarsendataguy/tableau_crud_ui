import 'package:flutter_test/flutter_test.dart';
import 'package:tableau_crud_ui/state_and_model/input_formatting.dart';

main(){
  test("Validate properly formatted decimals",(){
    expect(isTextDecimal("123.45"), isTrue);
    expect(isTextDecimal("-123.45"), isTrue);
    expect(isTextDecimal("123"), isTrue);
    expect(isTextDecimal("-123"), isTrue);
    expect(isTextDecimal("123."), isTrue);
    expect(isTextDecimal("-123."), isTrue);
    expect(isTextDecimal("-"), isTrue);
    expect(isTextDecimal(""), isTrue);
  });

  test("Validate improperly formatted decimals",(){
    expect(isTextDecimal("--123.45"), isFalse);
    expect(isTextDecimal("123.45-"), isFalse);
    expect(isTextDecimal("ABC"), isFalse);
    expect(isTextDecimal("123,45"), isFalse);
    expect(isTextDecimal("123 45"), isFalse);
  });

  test("Validate properly formatted integers",(){
    expect(isTextInteger("123"), isTrue);
    expect(isTextInteger("-123"), isTrue);
    expect(isTextInteger("-"), isTrue);
    expect(isTextInteger(""), isTrue);
  });

  test("Validate improperly formatted decimals",(){
    expect(isTextInteger("-123.45"), isFalse);
    expect(isTextInteger("-123.45"), isFalse);
    expect(isTextInteger("ABC"), isFalse);
    expect(isTextInteger("123-"), isFalse);
    expect(isTextInteger("123,456"), isFalse);
  });

  test("Validate properly formatted dates",(){
    expect(isTextDate("2020-01-01"), isTrue);
    expect(isTextDate("2020-02-29"), isTrue);
    expect(isTextDate("2020-12-31"), isTrue);
    expect(isTextDate("2999-12-31"), isTrue);
    expect(isTextDate("2020-04-30"), isTrue);
    expect(isTextDate(""), isTrue);
    expect(isTextDate("2"), isTrue);
    expect(isTextDate("20"), isTrue);
    expect(isTextDate("202"), isTrue);
    expect(isTextDate("2020"), isTrue);
    expect(isTextDate("2020-"), isTrue);
    expect(isTextDate("2020-0"), isTrue);
    expect(isTextDate("2020-1"), isTrue);
    expect(isTextDate("2020-01"), isTrue);
    expect(isTextDate("2020-02"), isTrue);
    expect(isTextDate("2020-03"), isTrue);
    expect(isTextDate("2020-04"), isTrue);
    expect(isTextDate("2020-05"), isTrue);
    expect(isTextDate("2020-06"), isTrue);
    expect(isTextDate("2020-07"), isTrue);
    expect(isTextDate("2020-08"), isTrue);
    expect(isTextDate("2020-09"), isTrue);
    expect(isTextDate("2020-10"), isTrue);
    expect(isTextDate("2020-11"), isTrue);
    expect(isTextDate("2020-12"), isTrue);
    expect(isTextDate("2020-01-"), isTrue);
    expect(isTextDate("2020-01-0"), isTrue);
    expect(isTextDate("2020-01-1"), isTrue);
    expect(isTextDate("2020-01-2"), isTrue);
    expect(isTextDate("2020-01-3"), isTrue);
    expect(isTextDate("2020-02-0"), isTrue);
    expect(isTextDate("2020-02-1"), isTrue);
    expect(isTextDate("2020-02-2"), isTrue);
    expect(isTextDate("2020-04-0"), isTrue);
    expect(isTextDate("2020-04-1"), isTrue);
    expect(isTextDate("2020-04-2"), isTrue);
    expect(isTextDate("2020-04-3"), isTrue);
  });

  test("Validate improperly formatted dates", (){
    expect(isTextDate("2019-02-29"), isFalse);
    expect(isTextDate("2020/01/01"), isFalse);
    expect(isTextDate("ABC"), isFalse);
    expect(isTextDate("2020-01-011"), isFalse);
    expect(isTextDate("1999-12-31"), isFalse);
    expect(isTextDate("2020-20-31"), isFalse);
    expect(isTextDate("2020-01-32"), isFalse);
    expect(isTextDate("2020-02-3"), isFalse);
  });
}