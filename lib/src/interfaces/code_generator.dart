import 'package:analyzer/dart/element/element.dart';

abstract interface class CodeGenerator<ElementType extends Element> {
  String generateFor(ElementType element);
}
