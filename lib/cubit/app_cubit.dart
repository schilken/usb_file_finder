import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:usb_file_finder/cubit/settings_cubit.dart';
import 'package:usb_file_finder/files_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(
    SettingsCubit settingsCubit,
    this.filesRepository,
  )   : _settingsCubit = settingsCubit,
        super(AppInitial()) {
    print('create AppCubit');
    if (settingsCubit.state is SettingsLoaded) {
      _applyFilters(_settingsCubit.state as SettingsLoaded);
    }
    _settingsCubit.stream.listen((settings) {
      if (settings is SettingsLoaded) {
        _applyFilters(settings);
      }
    });
  }
  final FilesRepository filesRepository;
  String? _primaryWord;
  String? _secondaryWord;
  final String _currentPathname = "no file selected";
  String? _fileType;
  int _fileCount = 0;
  int _primaryHitCount = 0;
  String? _folderPath;
  final SettingsCubit _settingsCubit;
  String _selectedFileType = '';
  StreamSubscription<File>? _subscription;

  List<String> _allFilePaths = [];
  List<String> _filteredFilePaths = [];

  // pathname → loist of 10 lines following hit
  final sectionsMap = <String, List<String>>{};

  void setPrimarySearchWord(String? word) {
    print('setPrimarySearchWord: $word');
    _primaryWord = word;
    if (_primaryWord != null && (_primaryWord ?? '').isEmpty) {
      _primaryWord = null;
    }
  }

  void setSecondarySearchWord(String? word) {
    print('setSecondarySearchWord: $word');
    _secondaryWord = word;
    if (_secondaryWord != null && (_secondaryWord ?? '').isEmpty) {
      _secondaryWord = null;
    }
  }

  Future<void> search() async {
    const storageName = '128GB';
    emit(DetailsLoading());
    print('search: $_primaryWord $_secondaryWord');
    if (_primaryWord == null || (_primaryWord ?? '').length < 3) {
      emit(
        DetailsLoaded(
            currentPathname: _currentPathname,
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: 0,
            details: const [],
          message: 'Primary Search Word must be at least 3 characters',
          isScanRunning: false,
        ),
      );
      return;
    }
    _allFilePaths = await filesRepository.loadTotalFileList(_selectedFileType);
    _fileCount = _allFilePaths.length;
    _filteredFilePaths = _allFilePaths;
    final primaryResult = <Detail>[];
    for (final path in _filteredFilePaths) {
      if (path.contains(_primaryWord!)) {
        _primaryHitCount++;
        var shortPath = path;
        if (_folderPath != null) {
          shortPath = path.replaceFirst('${_folderPath!}/', '');
        }
        primaryResult.add(Detail(
          title: path,
          filePathName: path,
          previewText: p.basename(shortPath),
          projectName: storageName,
          projectPathName: '/Volumes/$storageName',
        ));
      }
    }
    emit(
      DetailsLoaded(
        currentPathname: _currentPathname,
        fileType: _selectedFileType,
        fileCount: _filteredFilePaths.length,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: 0,
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
    print('outputFolder: $outputFolder');

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

final ignoredFolders = <String>{
    'Backups.backupdb',
    '.Spotlight-V100',
    '.Trashes',
    'Contents',
  };

//async* + yield* for recursive functions
  Stream<File> scanningFilesWithAsyncRecursive(Directory dir) async* {
    //dirList is FileSystemEntity list for every directories/subdirectories
    //entities in this list might be file, directory or link
    try {
      var dirList = dir.list();
      await for (final FileSystemEntity entity in dirList) {
        if (entity is File) {
          yield entity;
        } else if (entity is Directory &&
            !ignoredFolders.contains(p.basename(entity.path))) {
          yield* scanningFilesWithAsyncRecursive(Directory(entity.path));
        }
      }
    } on Exception catch (e) {
      print('exception: $e');
    }
  }

  Future<void> scanFolder({required String folderPath}) async {
    var dir = Directory(folderPath);
    final deviceName = p.basename(folderPath);
    Map<String, File> extensionMap = await buildExtensionMap(deviceName);

    Stream<File> scannedFiles = scanningFilesWithAsyncRecursive(dir);

    _fileCount = 0;
    _subscription = scannedFiles.listen((File file) async {
      final listfile = extensionMap[p.extension(file.path)];
      if (listfile != null) {
        listfile.writeAsStringSync('${file.path}\n', mode: FileMode.append);
        if (++_fileCount % 100 == 0) {
          print('files: $_fileCount');
          emit(DetailsLoaded(
            currentPathname: folderPath,
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
            currentPathname: folderPath,
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: 0,
            isScanRunning: false,
            details: const [],
          ),
        );
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
        currentPathname: '',
      fileType: _fileType,
        fileCount: _fileCount,
      primaryHitCount: _primaryHitCount,
      secondaryHitCount: 0,
        isScanRunning: false,
        details: const [],
      ),
    );
  }

  void _applyFilters(SettingsLoaded settings) {
    print('_applyFilters: $settings');
    _selectedFileType = settings.fileTypeFilter;
//    search();
  }

  void openEditor(String? filePathName) {
    Process.run('code', [filePathName!]);
  }
}
