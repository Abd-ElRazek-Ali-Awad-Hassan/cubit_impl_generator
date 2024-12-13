import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../interfaces/factory.dart';
import '../utils/annotation_extensions_on_element.dart';
import '../utils/constant_reader_extensions.dart';
import '../utils/generated_name.dart';
import '../utils/invocation/method_invocation.dart';
import '../utils/param_to_required_named_parameter.dart';
import '../utils/to_internal_field_name.dart';
import '../utils/type_arguments_of_annotation.dart';
import 'method_from_async_operation_factory.dart';

final class CommandClassFromMethodFactory
    implements Factory<Class, MethodElement> {
  @override
  Class createFrom(MethodElement element) {
    final builder = ClassBuilder()
      ..modifier = ClassModifier.final$
      ..name = '${element.name.generatedClassName()}Command'
      ..implements.add(refer('_\$Command'));
    _buildCommandConstructorWith(builder.constructors, element);
    _buildCommandInternalFieldsWith(builder.fields, element);
    _buildCommandMethodsWith(builder.methods, element);
    return builder.build();
  }

  void _buildCommandConstructorWith(
    ListBuilder<Constructor> constructors,
    MethodElement element,
  ) {
    constructors.add(Constructor(
      (builder) => builder
        ..optionalParameters.addAll(_constructorParameters(element))
        ..body = Code(
          _constructorParameters(element)
              .map((e) => '${e.toInternalField().name} = ${e.name};\n')
              .join(''),
        ),
    ));
  }

  Iterable<Parameter> _constructorParameters(
    MethodElement element,
  ) {
    final commandAnnotation = ConstantReader(element.annotation<Command>())
        .getAnnotationOfType<Command>();
    return [
      _buildEmitParameter(element),
      ...commandAnnotation.params.map(
        (e) => e.toRequiredNamedParameter(),
      ),
    ];
  }

  Parameter _buildEmitParameter(MethodElement element) {
    final typeArguments = TypeArgumentsOfAnnotation<GenerateCubitImpl>(
      element.enclosingElement,
    );
    final cubitState = '${typeArguments.first}';
    return Parameter(
      (builder) => builder
        ..named = true
        ..required = true
        ..name = 'emit'
        ..type = Reference('void Function($cubitState)'),
    );
  }

  void _buildCommandInternalFieldsWith(
    ListBuilder<Field> fields,
    MethodElement element,
  ) {
    fields.addAll([
      ..._constructorParameters(element).map((e) => e.toInternalField()),
    ]);
  }

  void _buildCommandMethodsWith(
    ListBuilder<Method> methods,
    MethodElement element,
  ) {
    methods.add(_buildCommandCallMethod(element));
    final operationAsMethodFactory = _methodFromAsyncOperationFactory(element);
    final commandAnnotation = ConstantReader(element.annotation<Command>())
        .getAnnotationOfType<Command>();

    for (final operation in commandAnnotation.operations) {
      final method = operationAsMethodFactory.createFrom(operation);
      if (!methods.containMethod(method)) methods.add(method);
    }
  }

  Method _buildCommandCallMethod(MethodElement element) {
    return Method(
      (builder) => builder
        ..name = 'call'
        ..modifier = MethodModifier.async
        ..returns = refer('${Future<void>}')
        ..annotations.add(refer('override'))
        ..body = _buildCommandCallMethodBody(element),
    );
  }

  Code _buildCommandCallMethodBody(MethodElement element) {
    final operationAsMethodFactory = _methodFromAsyncOperationFactory(element);
    final commandAnnotation = ConstantReader(element.annotation<Command>())
        .getAnnotationOfType<Command>();
    return Block(
      (builder) {
        final expressions = commandAnnotation.operations
            .map(operationAsMethodFactory.createFrom)
            .map((e) => e.invocation());
        expressions.forEach(builder.addExpression);
      },
    );
  }

  Factory<Method, AsyncOperation> _methodFromAsyncOperationFactory(
    MethodElement element,
  ) {
    final typeArguments = TypeArgumentsOfAnnotation<GenerateCubitImpl>(
      element.enclosingElement,
    );
    return MethodFromAsyncOperationFactory(
      emitCallbackName: _buildEmitParameter(element).toInternalField().name,
      cubitStateName: '${typeArguments.first}',
    );
  }
}

extension _ToInternalField on Parameter {
  Field toInternalField() {
    return Field(
      (builder) => builder
        ..late = true
        ..type = type
        ..name = name.toInternalFieldName()
        ..modifier = FieldModifier.final$,
    );
  }
}

extension _MethodsContainMethod on ListBuilder<Method> {
  bool containMethod(Method method) =>
      build().map((e) => e.name).contains(method.name);
}
