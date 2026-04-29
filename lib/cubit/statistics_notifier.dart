import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usb_file_finder/files_repository.dart';
import 'package:usb_file_finder/providers.dart';
import 'package:yaml/yaml.dart';

class Frequency {
  final String name;
  final int count;
  Frequency({required this.name, required this.count});
}

abstract class StatisticsState {
  const StatisticsState();
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final String currentPathname;
  final int fileCount;
  final List<Frequency> frequencies;
  const StatisticsLoaded({
    required this.currentPathname,
    required this.fileCount,
    required this.frequencies,
  });
}

class StatisticsNotifier extends Notifier<StatisticsState> {
  late FilesRepository _filesRepository;

  @override
  StatisticsState build() {
    _filesRepository = ref.read(filesRepositoryProvider);
    return const StatisticsInitial();
  }

  Future<void> load() async {
    state = const StatisticsLoading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = const StatisticsLoaded(
      currentPathname: 'no path',
      fileCount: -1,
      frequencies: [],
    );
  }

  Future<YamlMap> _loadYamlFile(String path) async {
    final yamlAsString = await File(path).readAsString();
    return loadYaml(yamlAsString);
  }

  Future<List<Frequency>> buildStatistics(List<String> allFilePaths) async {
    final dependencyCountsMap = <String, int>{};
    for (final path in allFilePaths) {
      final yamlAsMap = await _loadYamlFile(path);
      final dependenciesMap = yamlAsMap['dependencies'];
      if (dependenciesMap == null) continue;
      for (final key in dependenciesMap.keys) {
        dependencyCountsMap.update(key, (v) => ++v, ifAbsent: () => 1);
      }
    }
    final mapAsList = dependencyCountsMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value));
    return mapAsList
        .map((e) => Frequency(name: e.key, count: e.value))
        .toList();
  }
}

final statisticsProvider =
    NotifierProvider<StatisticsNotifier, StatisticsState>(
        StatisticsNotifier.new);
