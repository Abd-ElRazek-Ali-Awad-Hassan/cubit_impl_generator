import 'package:cubit_impl_annotation/cubit_impl_annotation.dart';
import 'package:generic_reader/generic_reader.dart';
import 'package:source_gen/source_gen.dart';

extension ConstantReaderExtensions on ConstantReader {
  T getAnnotationOfType<T>() {
    GenericReader.addDecoder<Command>(_commandDecoder);
    GenericReader.addDecoder<AsyncOperation>(_asyncOperationDecoder);

    return get<T>();
  }

  Command _commandDecoder(ConstantReader reader) {
    return Command(
      reader.read('operations').getList<AsyncOperation>(),
    );
  }

  AsyncOperation _asyncOperationDecoder(ConstantReader reader) {
    if (reader._isInstanceOf<OnEither>()) return _onEitherDecoder(reader);
    if (reader._isInstanceOf<ShowLoading>()) return _showLoadingDecoder();
    throw UnimplementedError();
  }

  ShowLoading _showLoadingDecoder() => ShowLoading();

  OnEither _onEitherDecoder(ConstantReader reader) {
    return OnEither(
      eitherCallback: _eitherCallbackDecoder(
        reader.read('eitherCallback'),
      ),
      onSuccess: reader
          .read('onSuccess')
          .listValue
          .map((e) => _onSuccessActionDecoder(ConstantReader(e)))
          .toList(),
      onFailure: reader
          .read('onFailure')
          .listValue
          .map((e) => _onFailureActionDecoder(ConstantReader(e)))
          .toList(),
    );
  }

  CallbackCanBeParam _eitherCallbackDecoder(ConstantReader reader) {
    final [failureTypeAsString, successTypeAsString] = reader.dartTypeArgs
        .map((e) => e.getDisplayString(withNullability: true))
        .toList();
    return _EitherCallback(
      name: reader.read('name').stringValue,
      successTypeAsString: successTypeAsString,
      failureTypeAsString: failureTypeAsString,
    );
  }

  OnFailureAction _onFailureActionDecoder(ConstantReader reader) {
    if (reader._isInstanceOf<ReportServerFailure>()) {
      return ReportServerFailure();
    }
    if (reader._isInstanceOf<ReportNetworkFailure>()) {
      return ReportNetworkFailure();
    }
    if (reader._isInstanceOf<ReportAuthorizedAccessFailure>()) {
      return ReportAuthorizedAccessFailure();
    }
    if (reader._isInstanceOf<OnFailureDo>()) {
      return _OnFailureDo(
        name: reader.read('name').stringValue,
        failureTypeAsString: reader.dartTypeArgs.first.getDisplayString(
          withNullability: true,
        ),
      );
    }
    throw UnimplementedError();
  }

  OnSuccessAction _onSuccessActionDecoder(ConstantReader reader) {
    if (reader._isInstanceOf<ShowSuccess>()) return ShowSuccess();
    if (reader._isInstanceOf<OnSuccessDo>()) {
      return _OnSuccessDo(
        name: reader.read('name').stringValue,
        successTypeAsString: reader.dartTypeArgs.first.getDisplayString(
          withNullability: true,
        ),
      );
    }
    throw UnimplementedError();
  }

  bool _isInstanceOf<T>() {
    return instanceOf(TypeChecker.fromRuntime(T));
  }
}

final class _EitherCallback extends EitherCallbackTemplate {
  _EitherCallback({
    required this.name,
    required this.successTypeAsString,
    required this.failureTypeAsString,
  });

  @override
  final String name;

  @override
  final String successTypeAsString;

  @override
  final String failureTypeAsString;
}

final class _OnSuccessDo extends OnSuccessDoTemplate {
  _OnSuccessDo({
    required this.name,
    required String successTypeAsString,
  }) : successTypeAsString = successTypeAsString;

  @override
  final String name;

  @override
  final String successTypeAsString;
}

final class _OnFailureDo extends OnFailureDoTemplate {
  _OnFailureDo({
    required this.name,
    required String failureTypeAsString,
  }) : failureTypeAsString = failureTypeAsString;

  @override
  final String name;

  @override
  final String failureTypeAsString;
}
