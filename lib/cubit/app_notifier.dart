import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:usb_file_finder/cubit/app_state_models.dart';
import 'package:usb_file_finder/cubit/settings_notifier.dart';
import 'package:usb_file_finder/event_bus.dart';
import 'package:usb_file_finder/files_repository.dart';
import 'package:usb_file_finder/providers.dart';

export 'package:usb_file_finder/cubit/app_state_models.dart';

class AppNotifier extends Notifier<AppState> {
  late FilesRepository _filesRepository;
  String? _primaryWord;
  String? _secondaryWord;
  final List<String> _exclusionWords = [];
  String? _fileType;
  int _fileCount = 0;
  int _primaryHitCount = 0;
  int _secondaryHitCount = 0;
  String _selectedFileType = '';
  StreamSubscription<File>? _subscription;
  bool _searchCaseSensitiv = false;
  String _folderPath = '';
  List<String> _filteredFilePaths = [];

  @override
  AppState build() {
    _filesRepository = ref.read(filesRepositoryProvider);
    eventBus.on<SettingsChanged>().listen((event) {
      _applyFilters(event.fileTypeFilter);
    });
    eventBus.on<RescanDevice>().listen((event) async {
      print('AppNotifier event: $event');
      final volumePath = _filesRepository.volumePathForIndex(event.index);
      scanVolume(volumePath: volumePath);
    });
    return const AppInitial();
  }

  String get _searchParameters {
    final parameters = <String>[];
    parameters.add(_searchCaseSensitiv ? 'Case Sensitiv' : 'ignore Case');
    if (_exclusionWords.isNotEmpty) {
      parameters.add('excluded: ${_exclusionWords.join(' ')}');
    }
    return parameters.join(' - ');
  }

  void setPrimarySearchWord(String? word) {
    _primaryWord = _searchCaseSensitiv ? word : word?.toLowerCase();
    if (_primaryWord != null && (_primaryWord ?? '').isEmpty) {
      _primaryWord = null;
    }
  }

  void setSecondarySearchWord(String? word) {
    _secondaryWord = _searchCaseSensitiv ? word : word?.toLowerCase();
    if (_secondaryWord != null && (_secondaryWord ?? '').isEmpty) {
      _secondaryWord = null;
    }
  }

  bool containsAnyExclusionWord(String path) {
    if (_exclusionWords.isEmpty) return false;
    return _exclusionWords.any((word) => path.contains(word));
  }

  Future<void> search() async {
    state = const DetailsLoading();
    final linesAsStream = _filesRepository
        .allLinesAsStream(_selectedFileType)
        .map((path) => _searchCaseSensitiv ? path : path.toLowerCase())
        .where((path) => !path.contains('XXX'))
        .where((path) => !containsAnyExclusionWord(path));

    _filteredFilePaths = await linesAsStream.toList();
    _fileCount = _filteredFilePaths.length;
    _primaryHitCount = 0;
    _secondaryHitCount = 0;
    final primaryResult = <Detail>[];
    for (final path in _filteredFilePaths) {
      if (path.contains(_primaryWord ?? '')) {
        _primaryHitCount++;
        if (_secondaryWord == null || path.contains(_secondaryWord!)) {
          _secondaryHitCount++;
          final components = p.split(path);
          final storageName = components[2];
          final filename = p.basename(path);
          var folderPath = path;
          folderPath =
              components.sublist(3).join('/').replaceFirst(filename, '');
          primaryResult.add(Detail(
            filePath: filename,
            storageName: storageName,
            folderPath: folderPath,
            filePathName: path,
            projectPathName: '/Volumes/$storageName',
          ));
        }
      }
    }
    state = DetailsLoaded(
      currentSearchParameters: _searchParameters,
      fileType: _selectedFileType,
      fileCount: _filteredFilePaths.length,
      primaryHitCount: _primaryHitCount,
      secondaryHitCount: _secondaryHitCount,
      details: primaryResult,
      primaryWord: _primaryWord,
      secondaryWord: _secondaryWord,
      isScanRunning: false,
    );
  }

  final _ignoredFolders = <String>{
    'Backups.backupdb',
    'Contents',
    'BACKUP-ELLENS_MAC',
  };

  bool ignoreFolder(String folderPath) {
    final folderName = p.basename(folderPath);
    if (folderName.startsWith('.')) return true;
    if (_ignoredFolders.contains(folderName)) return true;
    return false;
  }

  Stream<File> scanningFilesWithAsyncRecursive(Directory dir) async* {
    try {
      final dirList = dir.list();
      await for (final FileSystemEntity entity in dirList) {
        if (entity is File) {
          yield entity;
        } else if (entity is Directory && !ignoreFolder(entity.path)) {
          yield* scanningFilesWithAsyncRecursive(Directory(entity.path));
        }
      }
    } on Exception catch (e) {
      print('exception: $e');
    }
  }

  Future<void> scanVolume({required String volumePath}) async {
    final dir = Directory(volumePath);
    final deviceName = p.basename(volumePath);
    final Map<String, File> extensionMap =
        await _filesRepository.buildExtensionMap(deviceName);

    final Stream<File> scannedFiles = scanningFilesWithAsyncRecursive(dir);

    _fileCount = 0;
    _subscription = scannedFiles.listen((File file) async {
      final listfile = extensionMap[p.extension(file.path)];
      if (listfile != null) {
        listfile.writeAsStringSync('${file.path}\n', mode: FileMode.append);
        if (++_fileCount % 100 == 0) {
          final components = p.split(file.path);
          _folderPath = components.length > 3 ? components[3] : '';
          state = DetailsLoaded(
            currentSearchParameters: '$volumePath - $_folderPath',
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: 0,
            isScanRunning: true,
            details: const [],
          );
        }
      }
    });
    _subscription?.onDone(() {
      state = DetailsLoaded(
        currentSearchParameters: volumePath,
        fileType: _fileType,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: 0,
        isScanRunning: false,
        details: const [],
      );
      eventBus.fire(const DevicesChanged());
    });
    _subscription?.onError((Object error) {
      print('error: $error');
    });
  }

  Future<void> cancelScan() async {
    await _subscription?.cancel();
    state = DetailsLoaded(
      currentSearchParameters: '',
      fileType: _fileType,
      fileCount: _fileCount,
      primaryHitCount: _primaryHitCount,
      secondaryHitCount: 0,
      isScanRunning: false,
      details: const [],
    );
  }

  void _applyFilters(String fileTypeFilter) {
    print('_applyFilters: $fileTypeFilter');
    _selectedFileType = fileTypeFilter;
    search();
  }

  void openEditor(String? filePathName) {
    Process.run('code', [filePathName!]);
  }

  void setCaseSentitiv(bool caseSensitiv) {
    _searchCaseSensitiv = caseSensitiv;
  }

  Future<void> addExclusionWord(String exclusionWord) async {
    print('addExclusionWord: $exclusionWord');
    _exclusionWords.add(exclusionWord);
    await search();
  }

  Future<void> clearExcludes() async {
    _exclusionWords.clear();
    await search();
  }

  void addToIgnoreFolderList() {}

  void showInFinder(String filePath) {
    Process.run('open', ['-R', filePath]);
  }
}

final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);
