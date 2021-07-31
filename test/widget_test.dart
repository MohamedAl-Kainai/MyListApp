string (key,value){
  print ("$key: $value");
  return {};
}

main(){
  Map<String, bool> data = {"name":false, "age":false};
  var x = data.map((key, value) => MapEntry(key, value)).;
  print(x);
}