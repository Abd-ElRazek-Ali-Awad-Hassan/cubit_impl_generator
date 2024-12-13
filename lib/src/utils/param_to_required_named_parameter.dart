import 'package:code_builder/code_builder.dart';
import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';

extension ParamToRequiredNamedParameter on Param {
  Parameter toRequiredNamedParameter() => Parameter(
        (builder) => builder
          ..named = true
          ..required = true
          ..name = name
          ..type = refer(paramTypeAsString),
      );
}
