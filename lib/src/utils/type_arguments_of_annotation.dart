import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'annotation_extensions_on_element.dart';

final class TypeArgumentsOfAnnotation<AnnotationType>
    extends Iterable<DartType> {
  TypeArgumentsOfAnnotation(Element element) {
    _element = element;
  }

  late final Element _element;

  @override
  Iterator<DartType> get iterator => _typeArguments.iterator;

  Iterable<DartType> get _typeArguments =>
      switch (_element.annotation<AnnotationType>()?.type) {
        ParameterizedType type => type.typeArguments,
        _ => Iterable<DartType>.empty(),
      };
}
