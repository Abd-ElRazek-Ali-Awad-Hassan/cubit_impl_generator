import 'package:code_builder/code_builder.dart';

typedef ArgByParamMapper = Expression Function(Parameter p);

Expression defaultArgByParamMapper(Parameter p) => refer(p.name);

final class ArgByParamMapping {
  const ArgByParamMapping({
    this.mapper = defaultArgByParamMapper,
  });

  final ArgByParamMapper mapper;

  Iterable<Expression> positionalArgs(
    Iterable<Parameter> params,
  ) =>
      params.map(mapper);

  Map<String, Expression> namedArgs(Iterable<Parameter> params) {
    return Map<String, Expression>.fromIterable(
      params,
      key: (p) => p.name,
      value: (p) => mapper(p),
    );
  }
}
