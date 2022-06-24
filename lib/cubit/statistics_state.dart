// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'statistics_cubit.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final String currentPathname;
  StatisticsLoaded({
    required this.currentPathname,
  });
}
