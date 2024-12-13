final class ErrorMessageBuilder {
  const ErrorMessageBuilder();

  String messageForSourceMustBeClass() => 'Source must be a class';

  String messageForNonAnnotatedCubitClass() =>
      'Cubit class must be annotated with @GenerateCubitImpl';
}
