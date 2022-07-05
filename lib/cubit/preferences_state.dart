part of 'preferences_cubit.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object> get props => [];
}

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesLoaded extends PreferencesState {}
