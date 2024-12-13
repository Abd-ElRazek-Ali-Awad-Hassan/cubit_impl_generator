import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

extension AnnotationExtensionsOnElement on Element {
  DartObject? annotation<AnnotationType>() {
    return TypeChecker.fromRuntime(AnnotationType).firstAnnotationOf(this);
  }

  bool hasAnnotation<AnnotationType>() {
    return TypeChecker.fromRuntime(AnnotationType).hasAnnotationOf(this);
  }
}
