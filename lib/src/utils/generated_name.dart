import 'capitalize_first_letter.dart';

extension GeneratedName on String {
  String generatedClassName() {
    return '${_prefixSymbol()}${_name().capitalizeFirstLetter()}';
  }

  String generatedMethodName() {
    return '${_prefixSymbol()}${_name()}';
  }

  String _name() {
    return switch (_prefixSymbolRegex.firstMatch(this)) {
      null => this,
      RegExpMatch match => substring(match.end),
    };
  }

  String _prefixSymbol() {
    final prefixSymbol = _prefixSymbolRegex.stringMatch(this) ?? '';
    final prefixSymbolChars =
        Iterable.generate(prefixSymbol.length, (i) => prefixSymbol[i]);
    var result = '_\$';
    for (final char in prefixSymbolChars) {
      if (char == '\$') result += '\$';
      if (char == '_') result = '_' + result;
    }
    return result;
  }

  RegExp get _prefixSymbolRegex => RegExp(r'^(_|\$)*');
}
