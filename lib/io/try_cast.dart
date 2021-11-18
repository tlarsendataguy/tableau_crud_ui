T tryCast<T>(dynamic value, T defaultValue){
  return value != null && value is T ? value : defaultValue;
}

extension RetrieveCastedValues on Map<String, dynamic> {
  String tryString(String key) => tryCast(this[key],"");
  int tryInt(String key) => tryCast(this[key], 0);
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
  Map<String,String> tryStringStringMap(String key){
    var dynamicMap = tryCast(this[key], Map<String,dynamic>());
    var stringMap = Map<String,String>();
    for (var key in dynamicMap.keys){
      var value = dynamicMap[key];
      if (value is String){
        stringMap[key] = value;
      }
    }
    return stringMap;
  }
}
