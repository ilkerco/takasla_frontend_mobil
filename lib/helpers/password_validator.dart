bool validateStructure(String value) {
  String pattern = r'^(?=.*?[A-z])(?=.*?[0-9]).{7,15}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}
