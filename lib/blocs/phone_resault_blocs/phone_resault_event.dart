part of 'phone_resault_bloc.dart';

@immutable
abstract class PhoneResaultEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreatePhoneResaultEvent extends PhoneResaultEvent {
  final String apiKey;
  final String name;

  CreatePhoneResaultEvent({required this.apiKey, required this.name});

  @override
  List<Object?> get props => [apiKey, name];
}

class LoadAllPhoneResaultsEvent extends PhoneResaultEvent {
  final String apiKey;
  LoadAllPhoneResaultsEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class UpdatePhoneResaultEvent extends PhoneResaultEvent {
  final String apiKey;
  final SimpleDictionaryModel phoneResault;

  UpdatePhoneResaultEvent({required this.apiKey, required this.phoneResault});

  @override
  List<Object?> get props => [apiKey, phoneResault];
}
