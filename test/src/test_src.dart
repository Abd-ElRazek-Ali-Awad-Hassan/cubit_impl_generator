import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';
import 'package:failures/failures.dart';
import 'package:source_gen_test/annotations.dart';

final class SomeState {
  const SomeState();

  factory SomeState.loading() => SomeState();
}

abstract class Cubit<State> {
  Cubit(State initialState);
}

@ShouldThrow('Source must be a class')
void whenSourceIsAMethod() {}

@ShouldThrow('Cubit class must be annotated with @GenerateCubitImpl')
final class ACubitClassNotAnnotated extends Cubit<SomeState> {
  ACubitClassNotAnnotated() : super(SomeState());
}

@ShouldGenerate(
  'mixin _\$GenerateCubitMixinMixin on Cubit<SomeState> {\n'
  '  Future<void> __\$\$\$someMethod({\n'
  '    required Future<Either<Failure, int>> Function() fun,\n'
  '    required Future<void> Function(int) fun2,\n'
  '    required Future<void> Function(CacheFailure) fun3,\n'
  '  }) async {\n'
  '    await __\$\$\$SomeMethodCommand(\n'
  '      emit: emit,\n'
  '      fun: fun,\n'
  '      fun2: fun2,\n'
  '      fun3: fun3,\n'
  '    ).call();\n'
  '  }\n'
  '}\n'
  '\n'
  'abstract interface class _\$Command {\n'
  '  Future<void> call();\n'
  '}\n'
  '\n'
  'final class __\$\$\$SomeMethodCommand implements _\$Command {\n'
  '  __\$\$\$SomeMethodCommand({\n'
  '    required void Function(SomeState) emit,\n'
  '    required Future<Either<Failure, int>> Function() fun,\n'
  '    required Future<void> Function(int) fun2,\n'
  '    required Future<void> Function(CacheFailure) fun3,\n'
  '  }) {\n'
  '    _emit = emit;\n'
  '    _fun = fun;\n'
  '    _fun2 = fun2;\n'
  '    _fun3 = fun3;\n'
  '  }\n'
  '\n'
  '  late final void Function(SomeState) _emit;\n'
  '\n'
  '  late final Future<Either<Failure, int>> Function() _fun;\n'
  '\n'
  '  late final Future<void> Function(int) _fun2;\n'
  '\n'
  '  late final Future<void> Function(CacheFailure) _fun3;\n'
  '\n'
  '  @override\n'
  '  Future<void> call() async {\n'
  '    await _\$showLoading();\n'
  '    await _\$onResultOfFun();\n'
  '    await _\$showLoading();\n'
  '  }\n'
  '\n'
  '  Future<void> _\$showLoading() async {\n'
  '    _emit(SomeState.loading());\n'
  '  }\n'
  '\n'
  '  Future<void> _\$onResultOfFun() async {\n'
  '    await (await _fun()).fold<Future<void>>(\n'
  '      (failure) async => switch (failure) {\n'
  '        ServerFailure f => _emit(SomeState.serverError(f)),\n'
  '        NetworkFailure _ => _emit(SomeState.networkError()),\n'
  '        AuthorizedAccessFailure f => _emit(SomeState.unauthorizedAccess(f)),\n'
  '        CacheFailure failure => await _fun3(failure),\n'
  '        _ => () {},\n'
  '      },\n'
  '      (value) async {\n'
  '        _emit(SomeState.success(value));\n'
  '        await _fun2(value);\n'
  '      },\n'
  '    );\n'
  '  }\n'
  '}\n',
  contains: true,
)
@GenerateCubitImpl<SomeState>()
final class GenerateCubitMixin extends Cubit<SomeState> {
  GenerateCubitMixin() : super(SomeState());

  @Command([
    ShowLoading(),
    OnEither(
      onSuccess: [
        ShowSuccess(),
        OnSuccessDo<int>(name: 'fun2'),
      ],
      onFailure: [
        ReportServerFailure(),
        ReportNetworkFailure(),
        ReportAuthorizedAccessFailure(),
        OnFailureDo<CacheFailure>(name: 'fun3'),
      ],
      eitherCallback: EitherCallback<Failure, int>(
        name: 'fun',
      ),
    ),
    ShowLoading(),
  ])
  void $_$someMethod() {}
}
