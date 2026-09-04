part of 'phone_resault_bloc.dart';

@immutable
abstract class PhoneResaultState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhoneResaultInitial extends PhoneResaultState {}

class PhoneResaultLoading extends PhoneResaultState {}

class PhoneResaultCreated extends PhoneResaultState {
  final SimpleDictionaryModel phoneResault;
  PhoneResaultCreated(this.phoneResault);

  @override
  List<Object?> get props => [phoneResault];
}

class PhoneResaultsLoaded extends PhoneResaultState {
  final List<SimpleDictionaryModel> phoneResaults;
  PhoneResaultsLoaded(this.phoneResaults);

  @override
  List<Object?> get props => [phoneResaults];
}

class PhoneResaultUpdated extends PhoneResaultState {
  final SimpleDictionaryModel phoneResault;
  PhoneResaultUpdated(this.phoneResault);

  @override
  List<Object?> get props => [phoneResault];
}

class PhoneResaultError extends PhoneResaultState {
  final String message;
  PhoneResaultError(this.message);

  @override
  List<Object?> get props => [message];
}
