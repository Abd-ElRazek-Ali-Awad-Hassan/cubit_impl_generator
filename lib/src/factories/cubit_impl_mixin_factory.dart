import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';

import '../interfaces/factory.dart';
import '../utils/elements_annotated_with.dart';
import '../utils/type_arguments_of_annotation.dart';

final class CubitImplMixinFactory implements Factory<Mixin, ClassElement> {
  CubitImplMixinFactory({
    required Factory<Method, MethodElement> mixinMethodFactory,
  }) {
    _builder = MixinBuilder();
    _mixinMethodFactory = mixinMethodFactory;
  }

  late final MixinBuilder _builder;
  late final Factory<Method, MethodElement> _mixinMethodFactory;

  @override
  Mixin createFrom(ClassElement element) {
    _prepareMixinDeclaration(element);
    _prepareMixinMethods(element);
    return _builder.build();
  }

  void _prepareMixinDeclaration(ClassElement element) {
    final typeArguments = TypeArgumentsOfAnnotation<GenerateCubitImpl>(element);
    _builder
      ..name = '_\$${element.displayName}Mixin'
      ..on = refer('Cubit<${typeArguments.first}>');
  }

  void _prepareMixinMethods(ClassElement element) {
    final methodsAnnotated = ElementsAnnotatedWith<Command>(element.methods)
        .whereType<MethodElement>();
    _builder.methods.addAll(methodsAnnotated.map(
      _mixinMethodFactory.createFrom,
    ));
  }
}
