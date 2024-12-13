import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'code_generators/cubit_mixin_generator.dart';
import 'error_message_builder.dart';
import 'factories/command_class_from_method_factory.dart';
import 'factories/cubit_impl_mixin_factory.dart';
import 'factories/mixin_method_factory.dart';
import 'interfaces/code_generator.dart';

final class CubitImplGenerator
    extends GeneratorForAnnotation<GenerateCubitImpl> {
  CubitImplGenerator()
      : _errorMessageBuilder = const ErrorMessageBuilder(),
        _cubitMixinGenerator = CubitMixinGenerator(
          cubitImplMixinFactory: CubitImplMixinFactory(
            mixinMethodFactory: MixinMethodFactory(
              commandClassFactory: CommandClassFromMethodFactory(),
            ),
          ),
          commandClassFromMethodFactory: CommandClassFromMethodFactory(),
        );

  final ErrorMessageBuilder _errorMessageBuilder;
  final CodeGenerator<ClassElement> _cubitMixinGenerator;

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    _validateSourceMustBeAClass(element);
    _validateCubitClassMustBeAnnotated(annotation, element);

    final e = element as ClassElement;
    return _cubitMixinGenerator.generateFor(e);
  }

  void _validateSourceMustBeAClass(Element element) {
    if (element is ClassElement) return;
    throw InvalidGenerationSource(
      _errorMessageBuilder.messageForSourceMustBeClass(),
      element: element,
    );
  }

  void _validateCubitClassMustBeAnnotated(
    ConstantReader annotation,
    Element element,
  ) {
    if (annotation.isNull) {
      throw InvalidGenerationSource(
        _errorMessageBuilder.messageForNonAnnotatedCubitClass(),
        element: element,
      );
    }
  }
}
