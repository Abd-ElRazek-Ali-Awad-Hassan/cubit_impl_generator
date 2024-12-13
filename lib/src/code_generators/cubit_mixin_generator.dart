import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';
import 'package:cubit_impl_generator/src/interfaces/factory.dart';

import '../interfaces/code_generator.dart';
import '../utils/elements_annotated_with.dart';

final class CubitMixinGenerator implements CodeGenerator<ClassElement> {
  CubitMixinGenerator({
    required Factory<Mixin, ClassElement> cubitImplMixinFactory,
    required Factory<Class, MethodElement> commandClassFromMethodFactory,
  })  : _emitter = DartEmitter(useNullSafetySyntax: true),
        _cubitImplMixinFactory = cubitImplMixinFactory,
        _commandClassFromMethodFactory = commandClassFromMethodFactory;

  final DartEmitter _emitter;
  final Factory<Mixin, ClassElement> _cubitImplMixinFactory;
  final Factory<Class, MethodElement> _commandClassFromMethodFactory;

  @override
  String generateFor(ClassElement element) {
    final buffer = StringBuffer()
      ..writeAll(
        <Spec>[
          _cubitImplMixinFactory.createFrom(element),
          _buildCommandInterface(),
          ...ElementsAnnotatedWith<Command>(element.methods)
              .whereType<MethodElement>()
              .map(_commandClassFromMethodFactory.createFrom),
        ].map((e) => e.accept(_emitter)),
      );
    return buffer.toString();
  }

  Class _buildCommandInterface() {
    return Class(
      (builder) => builder
        ..abstract = true
        ..name = '_\$Command'
        ..modifier = ClassModifier.interface
        ..methods.add(Method(
          (builder) => builder
            ..name = 'call'
            ..returns = refer('${Future<void>}'),
        )),
    );
  }
}
