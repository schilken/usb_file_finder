import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
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
    emit(
      DetailsLoaded(
        currentSearchParameters: _searchParameters,
        fileType: _selectedFileType,
        fileCount: _filteredFilePaths.length,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: _secondaryHitCount,
        details: primaryResult,
        primaryWord: _primaryWord,
        secondaryWord: _secondaryWord,
        isScanRunning: false,
      ),
    );
  }

  Future<Map<String, File>> buildExtensionMap(String deviceName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final outputFolder =
        p.join(appDocDir.path, 'UsbFileFinder-Data', deviceName);
//    print('outputFolder: $outputFolder');

    final Directory directory =
        await Directory(outputFolder).create(recursive: true);
    final File textListFile = File('${directory.path}/text-files.txt');
    final File audioListFile = File('${directory.path}/audio-files.txt');
    final File videoListFile = File('${directory.path}/video-files.txt');
    final File miscListFile = File('${directory.path}/misc-files.txt');
    final File zipListFile = File('${directory.path}/zip-files.txt');
    final File imageListFile = File('${directory.path}/image-files.txt');

    return <String, File>{
      '.pdf': textListFile,
      '.txt': textListFile,
      '.epub': textListFile,
      '.doc': textListFile,
      '.odt': textListFile,
      '.mobi': textListFile,
      '.azw': textListFile,
      '.azw3': textListFile,
      '.md': textListFile,
      //
      '.mp3': audioListFile,
      '.m4a': audioListFile,
      '.m4b': audioListFile,
      '.wav': audioListFile,
      '.ogg': audioListFile,
      //
      '.mp4': videoListFile,
      '.avi': videoListFile,
      '.mpg': videoListFile,
      '.mpeg': videoListFile,
      '.mwv': videoListFile,
      '.mkv': videoListFile,
      //
      '.jpg': imageListFile,
      '.png': imageListFile,
      '.tiff': imageListFile,
      '.svg': imageListFile,
      '.ai': imageListFile,
      '.psd': imageListFile,
      //
      '.zip': zipListFile,
      '.rar': zipListFile,
      '.gz': zipListFile,
      '.bz': zipListFile,
      '.bz2': zipListFile,
      '.7z': zipListFile,
      '.tar': zipListFile,
      //
      '.iso': miscListFile,
      '.bin': miscListFile,
      '.dmg': miscListFile,
      '.pkg': miscListFile,
      '.app': miscListFile,
    };
  }

  final _ignoredFolders = <String>{
    'Backups.backupdb',
    'Contents',
    'BACKUP-ELLENS_MAC',
  };

  bool ignoreFolder(String folderPath) {
    final folderName = p.basename(folderPath);
    if (folderName.startsWith('.')) {
      return true;
    }
    if (_ignoredFolders.contains(folderName)) {
      return true;
    }
    return false;
  }

//async* + yield* for recursive functions
  Stream<File> scanningFilesWithAsyncRecursive(Directory dir) async* {
    //dirList is FileSystemEntity list for every directories/subdirectories
    //entities in this list might be file, directory or link
    try {
      var dirList = dir.list();
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
    var dir = Directory(volumePath);
    final deviceName = p.basename(volumePath);
    Map<String, File> extensionMap = await buildExtensionMap(deviceName);

    Stream<File> scannedFiles = scanningFilesWithAsyncRecursive(dir);

    _fileCount = 0;
    _subscription = scannedFiles.listen((File file) async {
      final listfile = extensionMap[p.extension(file.path)];
      if (listfile != null) {
        listfile.writeAsStringSync('${file.path}\n', mode: FileMode.append);
        if (++_fileCount % 100 == 0) {
//          print('files: $_fileCount');
          final components = p.split(file.path);
          _folderPath = components.length > 3 ? components[3] : '';
          emit(DetailsLoaded(
            currentSearchParameters: '$volumePath - $_folderPath',
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: 0,
            isScanRunning: true,
            details: const [],
          ));
        }
      }
    });
    _subscription?.onDone(
      () {
        emit(
          DetailsLoaded(
            currentSearchParameters: volumePath,
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: 0,
            isScanRunning: false,
            details: const [],
          ),
        );
        eventBus.fire(const DevicesChanged());
      },
    );
    _subscription?.onError((Object error) {
      print('error: $error');
    });
  }

  Future<void> cancelScan() async {
    await _subscription?.cancel();
    emit(
      DetailsLoaded(
        currentSearchParameters: '',
        fileType: _fileType,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: 0,
        isScanRunning: false,
        details: const [],
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
}
