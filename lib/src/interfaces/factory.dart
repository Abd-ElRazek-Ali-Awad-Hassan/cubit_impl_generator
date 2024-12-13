abstract interface class Factory<ReturnType, InputType> {
  ReturnType createFrom(InputType input);
}
