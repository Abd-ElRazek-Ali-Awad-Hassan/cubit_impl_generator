import 'package:code_builder/code_builder.dart';

import 'arg_by_param_mapping.dart';

extension MethodInvocation on Method {
  Expression invocation([
    ArgByParamMapping argByParam = const ArgByParamMapping(),
  ]) {
    final invocationExpression = refer(name!).call(
      argByParam.positionalArgs(requiredParameters),
      argByParam.namedArgs(optionalParameters),
      types.toList(),
    );
    if (isAsync) return invocationExpression.awaited;
    return invocationExpression;
  }
}

extension _IsAsync on Method {
  bool get isAsync {
    final futureOrFutureOrRegex = RegExp(r'^Future(Or){0,1}(<.+>){0,1}$');
    return switch (modifier) {
      MethodModifier.async => true,
      _ => futureOrFutureOrRegex.hasMatch(returnTypeAsString()),
    };
  }

  String returnTypeAsString() {
    final emitter = DartEmitter(useNullSafetySyntax: true);
    return returns?.accept(emitter).toString() ?? '';
  }
}
