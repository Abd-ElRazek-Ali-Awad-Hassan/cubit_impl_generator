import 'package:code_builder/code_builder.dart';
import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';
import 'package:failures/failures.dart';

import '../interfaces/factory.dart';
import '../utils/capitalize_first_letter.dart';
import '../utils/to_internal_field_name.dart';

final class MethodFromAsyncOperationFactory
    implements Factory<Method, AsyncOperation> {
  MethodFromAsyncOperationFactory({
    required String cubitStateName,
    required String emitCallbackName,
  })  : _cubitStateName = cubitStateName,
        _emitCallbackName = emitCallbackName;

  final String _cubitStateName;
  final String _emitCallbackName;

  Method createFrom(AsyncOperation operation) {
    return switch (operation) {
      OnEither op => _onEitherMethod(op),
      ShowLoading _ => _showLoadingMethod(),
    };
  }

  Method _showLoadingMethod() {
    return Method(
      (builder) => builder
        ..name = '_\$showLoading'
        ..modifier = MethodModifier.async
        ..returns = Reference('\n${Future<void>}')
        ..body = Code('${_emitCallbackName}($_cubitStateName.loading());\n'),
    );
  }

  Method _onEitherMethod(OnEither op) {
    final eitherCallback = op.eitherCallback;
    return Method(
      (builder) => builder
        ..name = '_\$onResultOf${eitherCallback.name.capitalizeFirstLetter()}'
        ..modifier = MethodModifier.async
        ..returns = refer('\n${Future<void>}')
        ..body = _onEitherMethodBody(op),
    );
  }

  Code _onEitherMethodBody(OnEither op) {
    final eitherCallbackField = op.eitherCallback.name.toInternalFieldName();
    return Code(
      'await (await ${eitherCallbackField}()).fold<${Future<void>}>(\n'
      '  ${_codeForFailureBlock(op)},\n'
      '  ${_codeForSuccessBlock(op)},\n'
      ');\n',
    );
  }

  String _codeForSuccessBlock(OnEither op) {
    final successArgName = 'value';
    final visitor = _OnSuccessActionVisitor(
      successArgName: successArgName,
      cubitStateName: _cubitStateName,
      emitCallbackName: _emitCallbackName,
    );
    final buffer = StringBuffer('($successArgName) async {\n')
      ..writeAll(op.onSuccess.map((e) => e.accept(visitor)), '\n')
      ..writeln('}');
    return buffer.toString();
  }

  String _codeForFailureBlock(OnEither op) {
    final visitor = _OnFailureActionVisitor(
      cubitStateName: _cubitStateName,
      emitCallbackName: _emitCallbackName,
    );
    final buffer = StringBuffer('(failure) async => switch (failure) {\n')
      ..writeAll(op.onFailure.map((e) => e.accept(visitor)), '\n')
      ..writeln('_ => () {},')
      ..writeln('}');
    return buffer.toString();
  }
}

final class _OnSuccessActionVisitor implements OnSuccessActionVisitor<String> {
  final String _cubitStateName;
  final String _successArgName;
  final String _emitCallbackName;

  _OnSuccessActionVisitor({
    required String successArgName,
    required String cubitStateName,
    required String emitCallbackName,
  })  : _cubitStateName = cubitStateName,
        _successArgName = successArgName,
        _emitCallbackName = emitCallbackName;

  @override
  String visitOnSuccess(OnSuccess action) {
    return 'await ${action.name.toInternalFieldName()}($_successArgName);';
  }

  @override
  String visitShowSuccess(ShowSuccess action) {
    return '${_emitCallbackName}($_cubitStateName.success($_successArgName));';
  }
}

final class _OnFailureActionVisitor implements OnFailureActionVisitor<String> {
  final String _cubitStateName;
  final String _emitCallbackName;

  _OnFailureActionVisitor({
    required String cubitStateName,
    required String emitCallbackName,
  })  : _cubitStateName = cubitStateName,
        _emitCallbackName = emitCallbackName;

  @override
  String visitOnFailure(OnFailure action) {
    final params = action.params;
    final matchingCase =
        params.map((e) => '${e.paramTypeAsString} ${e.name}').join(', ');
    final argsAsString = params.map((e) => e.name).join(', ');
    return '$matchingCase => await ${action.name.toInternalFieldName()}($argsAsString),';
  }

  @override
  String visitReportAuthorizedAccessFailure(
    ReportAuthorizedAccessFailure action,
  ) {
    final matchingCase = '$AuthorizedAccessFailure f';
    final unauthorizedAccessReporting =
        '${_emitCallbackName}($_cubitStateName.unauthorizedAccess(f))';
    return '$matchingCase => $unauthorizedAccessReporting,';
  }

  @override
  String visitReportNetworkFailure(ReportNetworkFailure action) {
    return '$NetworkFailure _ => ${_emitCallbackName}($_cubitStateName.networkError()),';
  }

  @override
  String visitReportServerFailure(ReportServerFailure action) {
    return '$ServerFailure f => ${_emitCallbackName}($_cubitStateName.serverError(f)),';
  }
}
