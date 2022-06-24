// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:open_source_browser/files_repository.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(
    this.filesRepository,
  ) : super(StatisticsInitial());
  final FilesRepository filesRepository;

  Future<void> load() async {
    emit(StatisticsLoading());
    await Future.delayed(Duration(milliseconds: 2000));
    emit(StatisticsLoaded(
        currentPathname: filesRepository.currentFolderPath ?? 'no path'));
  }
}
