T tryCast<T>(dynamic value, T defaultValue){
  return value != null && value is T ? value : defaultValue;
}

extension RetrieveCastedValues on Map<String, dynamic> {
  String tryString(String key) => tryCast(this[key],"");
  List<dynamic> tryDynamicList(String key) => tryCast(this[key], []);
  List<String> tryStringList(String key){
    var dynamicList = this.tryDynamicList(key);
    var stringList = List<String>();
    for (var item in dynamicList){
      if (item is String){
        stringList.add(item);
      }
    }
    return stringList;
  }
}
