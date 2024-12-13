import 'package:code_builder/code_builder.dart';

import 'arg_by_param_mapping.dart';

extension CommandClassInvocation on Class {
  Expression invokeCommand([
    ArgByParamMapping argByParam = const ArgByParamMapping(),
  ]) {
    final constructor = constructors.single;
    return refer(name)
        .newInstance(
          argByParam.positionalArgs(constructor.requiredParameters),
          argByParam.namedArgs(constructor.optionalParameters),
          types.toList(),
        )
        .property('call')
        .call([]).awaited;
  }
}
