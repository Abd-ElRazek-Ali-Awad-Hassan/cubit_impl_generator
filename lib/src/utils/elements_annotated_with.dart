import 'package:analyzer/dart/element/element.dart';

import 'annotation_extensions_on_element.dart';

final class ElementsAnnotatedWith<AnnotationType> extends Iterable<Element> {
  final Iterable<Element> elements;

  ElementsAnnotatedWith(this.elements);

  @override
  Iterator<Element> get iterator {
    return elements.where((e) => e.hasAnnotation<AnnotationType>()).iterator;
  }
}
