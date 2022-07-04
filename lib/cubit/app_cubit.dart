import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:usb_file_finder/cubit/settings_cubit.dart';
import 'package:usb_file_finder/event_bus.dart';
import 'package:usb_file_finder/files_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(
    SettingsCubit settingsCubit,
    this.filesRepository,
  )   : _settingsCubit = settingsCubit,
        super(AppInitial()) {
    print('create AppCubit');
    eventBus.fire(SettingsTrigger());
    eventBus.on<SettingsChanged>().listen((event) async {
      _applyFilters(event.fileTypeFilter);
    });
    eventBus.on<RescanDevice>().listen((event) async {
      print('AppCubit event: $event');
      final volumePath = filesRepository.volumePathForIndex(event.index);
      scanVolume(volumePath: volumePath);
    });

  }
  final FilesRepository filesRepository;
  String? _primaryWord;
  String? _secondaryWord;
  final List<String> _exclusionWords = [];
  String? _fileType;
  int _fileCount = 0;
  int _primaryHitCount = 0;
  int _secondaryHitCount = 0;
  final SettingsCubit _settingsCubit;
  String _selectedFileType = '';
  StreamSubscription<File>? _subscription;
  bool _searchCaseSensitiv = false;
  String _folderPath = '';
  var _searchResult = <Detail>[];

  List<String> _filteredFilePaths = [];

  // pathname → loist of 10 lines following hit
  final sectionsMap = <String, List<String>>{};

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
    if (_exclusionWords.isEmpty) {
      return false;
    }
    final result = _exclusionWords.any((word) => path.contains(word));
    return result;
  }

  Future<void> search() async {
    emit(DetailsLoading());
    final linesAsStream = filesRepository
        .allLinesAsStream(_selectedFileType)
        .map((path) => _searchCaseSensitiv ? path : path.toLowerCase())
        .where((path) => !path.contains('XXX'))
        .where((path) => !containsAnyExclusionWord(path));

    _filteredFilePaths = await linesAsStream.toList();
//    _allFilePaths = await filesRepository.loadTotalFileList(_selectedFileType);
    _fileCount = _filteredFilePaths.length;
    _primaryHitCount = 0;
    _secondaryHitCount = 0;
    _searchResult = <Detail>[];
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
          _searchResult.add(Detail(
            filePath: filename,
            storageName: storageName,
            folderPath: folderPath,
            filePathName: path,
            projectPathName: '/Volumes/$storageName',
          ));
        }
      }
    }
    emitDetailsLoaded(
      currentSearchParameters: _searchParameters,
      details: _searchResult,
    );
  }

  Future<void> scanVolume({required String volumePath}) async {
    var dir = Directory(volumePath);
    final deviceName = p.basename(volumePath);
    Map<String, File> extensionMap =
        await filesRepository.buildExtensionMap(deviceName);

    Stream<File> scannedFiles =
        filesRepository.scanningFilesWithAsyncRecursive(dir);

    _fileCount = 0;
    _subscription = scannedFiles.listen((File file) async {
      final listfile = extensionMap[p.extension(file.path)];
      if (listfile != null) {
        listfile.writeAsStringSync('${file.path}\n', mode: FileMode.append);
        if (++_fileCount % 100 == 0) {
          final components = p.split(file.path);
          _folderPath = components.length > 3 ? components[3] : '';
          emitDetailsLoaded(
              currentSearchParameters: '$volumePath - $_folderPath');
        }
      }
    });
    _subscription?.onDone(
      () {
        emitDetailsLoaded(currentSearchParameters: volumePath);
        eventBus.fire(const DevicesChanged());
      },
    );
    _subscription?.onError((Object error) {
      print('error: $error');
    });
  }

  Future<void> cancelScan() async {
    await _subscription?.cancel();
    emitDetailsLoaded();
  }

  void emitDetailsLoaded({
    bool isScanRunning = false,
    List<Detail> details = const [],
    String currentSearchParameters = '',
  }) {
    emit(
      DetailsLoaded(
        currentSearchParameters: currentSearchParameters,
        fileType: _fileType,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: _secondaryHitCount,
        details: details,
        isScanRunning: isScanRunning,
      ),
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

  addExclusionWord(String exclusionWord) {
    print('addExclusionWord: $exclusionWord');
    _exclusionWords.add(exclusionWord);
    search();
  }

  clearExcludes() {
    _exclusionWords.clear();
    search();
  }

  void addToIgnoreFolderList() {
//    _skipFolderPath = _folderPath;
  }

  showInFinder(String filePath) {
    Process.run('open', ['-R', filePath]);
  }
}
