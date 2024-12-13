import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../interfaces/factory.dart';
import '../utils/annotation_extensions_on_element.dart';
import '../utils/constant_reader_extensions.dart';
import '../utils/generated_name.dart';
import '../utils/invocation/arg_by_param_mapping.dart';
import '../utils/invocation/command_invocation.dart';
import '../utils/param_to_required_named_parameter.dart';

final class MixinMethodFactory implements Factory<Method, MethodElement> {
  MixinMethodFactory({
    required Factory<Class, MethodElement> commandClassFactory,
  }) {
    _builder = MethodBuilder();
    _commandClassFactory = commandClassFactory;
  }

  late final MethodBuilder _builder;
  late final Factory<Class, MethodElement> _commandClassFactory;

  @override
  Method createFrom(MethodElement element) {
    _prepareMethodDeclaration(element);
    _prepareMethodBody(element);
    return _builder.build();
  }

  void _prepareMethodDeclaration(MethodElement element) {
    final command = ConstantReader(element.annotation<Command>())
        .getAnnotationOfType<Command>();
    _builder
      ..name = element.name.generatedMethodName()
      ..optionalParameters.addAll(command.params.map(
        (e) => e.toRequiredNamedParameter(),
      ))
      ..modifier = MethodModifier.async
      ..returns = refer('${Future<void>}');
  }

  void _prepareMethodBody(MethodElement element) {
    _builder.body = Block(
      (builder) => builder
        ..addExpression(
          _commandClassFactory
              .createFrom(element)
              .invokeCommand(ArgByParamMapping(
                mapper: (param) => refer(param.name),
              )),
        ),
    );
  }
}
