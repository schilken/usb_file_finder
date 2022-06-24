import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:open_source_browser/cubit/settings_cubit.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(SettingsCubit settingsCubit)
      : _settingsCubit = settingsCubit,
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
  String? _primaryWord;
  String? _secondaryWord;
  String _currentPathname = "no file selected";
  String? _fileType;
  int _fileCount = 0;
  int _primaryHitCount = 0;
  int _secondaryHitCount = 0;
  String? _folderPath;
  int _maxLinesToBuffer = 10;
  final SettingsCubit _settingsCubit;
  bool _onlyExampleFiles = false;
  bool _removeExampleFiles = false;
  bool _onlyTestFiles = false;
  bool _removeTestFiles = false;
  int? _displayLineCount;

  List<String>? _allFilePaths;
  List<String>? _filteredFilePaths;

  // pathname → loist of 10 lines following hit
  final sectionsMap = <String, List<String>>{};

  Future<void> loadFileList() async {
    emit(DetailsLoading());
    FilePickerResult? selected = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'txt',
      ],
    );
    
    if (selected?.paths.first != null) {
      _currentPathname = selected!.paths.first!;
      File data = File(_currentPathname);
      _allFilePaths = await data.readAsLines();
      _fileCount = _allFilePaths?.length ?? 0;
    } else {
      _currentPathname = "no file selected";
      _fileCount = 0;
    }
    _fileType = null;
    _maxLinesToBuffer = 10;
    emit(DetailsLoaded(
      currentPathname: _currentPathname,
      fileCount: _fileCount,
      primaryHitCount: _primaryHitCount,
      secondaryHitCount: _secondaryHitCount,
      details: [
        Detail(title: 'nothing...'),
      ],
    ));
  }

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
    emit(DetailsLoading());
    print('search: $_primaryWord $_secondaryWord');
    if (_currentPathname == "no filelist selected") {
      emit(
        DetailsLoaded(
            currentPathname: _currentPathname,
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: _secondaryHitCount,
            details: [],
            message: 'No filelist loaded'),
      );
      return;
    }
    if (_primaryWord == null || (_primaryWord ?? '').length < 3) {
      emit(
        DetailsLoaded(
            currentPathname: _currentPathname,
            fileType: _fileType,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: _secondaryHitCount,
            details: [],
            message: 'Primary Search Word must be at least 3 characters'),
      );
      return;
    }
    _filteredFilePaths = _allFilePaths;
    if (_onlyExampleFiles) {
      _filteredFilePaths = _filteredFilePaths!
          .where((path) => path.contains('/example/'))
          .toList();
    }
    if (_removeExampleFiles) {
      _filteredFilePaths = _filteredFilePaths!
          .where((path) => !path.contains('/example/'))
          .toList();
    }
    if (_onlyTestFiles) {
      _filteredFilePaths =
          _filteredFilePaths!.where((path) => path.contains('_test')).toList();
    }
    if (_removeTestFiles) {
      _filteredFilePaths =
          _filteredFilePaths!.where((path) => !path.contains('_test')).toList();
    }
    print('_filteredFilePaths.length: ${_filteredFilePaths!.length}');

    if (_fileType == 'svg') {
      await searchInFilename();
    } else {
      await searchForText();
    }
  }

  Future<void> searchInFilename() async {
    final primaryResult = <Detail>[];
    for (final path in _allFilePaths!) {
      if (path.contains(_primaryWord!)) {
        _primaryHitCount++;
        var shortPath = path;
        if (_folderPath != null) {
          shortPath = path.replaceFirst('${_folderPath!}/', '');
        }
        primaryResult.add(Detail(
          title: shortPath.split('/assets').last,
          projectName: shortPath.split('/assets').first,
          imageUrl: path,
        ));
      }
    }
    emit(
      DetailsLoaded(
        currentPathname: _currentPathname,
        fileType: _fileType,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: _secondaryHitCount,
        details: primaryResult,
        primaryWord: _primaryWord,
        secondaryWord: _secondaryWord,
        displayLineCount: _displayLineCount,
      ),
    );
  }

  Future<void> searchForText() async {
    sectionsMap.clear();
    await processAllFilesIn(_primaryWord!);
//    await Future.delayed(Duration(milliseconds: 1000));
    final primaryResult = sectionsMap.keys
            .map((key) => Detail(
              projectName: key.split(RegExp('/lib|/test')).first,
              title: key.split(RegExp('/lib|/test')).last,
                  previewText: sectionsMap[key]!.join('\n'),
              filePathName: '${_folderPath!}/$key',
              projectPathName:
                  '${_folderPath!}/${key.split(RegExp('/lib|/test')).first}',
                ))
        .toList();
    var secondaryResult = primaryResult;
    if (_secondaryWord != null && (_secondaryWord ?? '').length > 2) {
      secondaryResult = primaryResult
          .where((detail) => secondaryMatch(detail, _secondaryWord!))
          .toList();
    }
    _primaryHitCount = primaryResult.length;
    _secondaryHitCount = secondaryResult.length;
    if (_displayLineCount != null) {
      secondaryResult = secondaryResult.map((detail) {
        return detail.copyWith(previewText: _reduceLines(detail.previewText!));
      }).toList();
    }
    emit(
      DetailsLoaded(
        currentPathname: _currentPathname,
        fileType: _fileType,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: _secondaryHitCount,
        details: secondaryResult,
        primaryWord: _primaryWord,
        secondaryWord: _secondaryWord,
        displayLineCount: _displayLineCount,
      ),
    );
  }

  String _reduceLines(String previewText) {
    var lines = previewText.split('\n');
    if (_displayLineCount == 1) {
      lines = [lines.first];
    } else if (lines.length > 1) {
      lines = [lines.first, lines[1]];
    }
    return lines.join('\n');
  }


  Future<void> processAllFilesIn(String primarySearchWord) async {
    var fileNumber = 0;
    var hitCount = 0;
    var hitFileCount = 0;
    for (final path in _filteredFilePaths!) {
//    print('searching in file number $fileNumber: $path: ');
      final hitsInFile = await searchFile(path, primarySearchWord);
      if (hitsInFile.isNotEmpty) {
        hitFileCount++;
        hitCount += hitsInFile.length;
        if (_folderPath != null) {
        sectionsMap[path.replaceFirst(
            '${_folderPath!}/', '')] = hitsInFile;
        }
      }
      fileNumber++;
    }
    print('hitCount: $hitCount in $hitFileCount files');
  }

  Future<List<String>> searchFile(String path, String word) async {
    var lineNumber = 1;
    var followingLines = <String>[];
    try {
      final lines = await File(path).readAsLines();
      var linesToSave = 0;
      for (final line in lines) {
        if (line.contains(word)) {
//          print('$path: $lineNumber');
          linesToSave = _maxLinesToBuffer;
        }
        lineNumber++;
        if (linesToSave > 0) {
          followingLines.add(line);
          linesToSave--;
        }
      }
    } on Exception catch (e) {
      print('exception: $e');
    }
    return followingLines;
  }
  
  bool secondaryMatch(Detail item, String secondaryWord) {
    return item.previewText?.contains(secondaryWord) ?? false;
  }
  
  Future<void> scanFolder(
      {required String type, required String folderPath}) async {
    print('scanFolder: $folderPath for $type');
    _folderPath = folderPath;
    _fileType = type;
    if (_fileType == 'pubspec.yaml') {
      _maxLinesToBuffer = 50;
    } else {
      _maxLinesToBuffer = 10;
    }
    _allFilePaths = (await runFindCommand(folderPath, type))
        .where((path) => path.isNotEmpty)
        .toList();
    if (folderPath != null) {
      _currentPathname = folderPath;
      File data = File(_currentPathname);
      _fileCount = _allFilePaths?.length ?? 0;
    } else {
      _currentPathname = "no file selected";
      _fileCount = 0;
    }
    emit(DetailsLoaded(
      currentPathname: _currentPathname,
      fileType: _fileType,
      fileCount: _fileCount,
      primaryHitCount: _primaryHitCount,
      secondaryHitCount: _secondaryHitCount,
      details: [
        Detail(title: 'nothing...'),
      ],
    ));
  }

  Future<List<String>> runFindCommand(
      String workingDir, String extension) async {
    var process = await Process.run(
        'find', [workingDir, '-name', '*$extension', '-type', 'f']);
    return process.stdout.split('\n');
  }

  void saveFileList() {}
  
  void _applyFilters(SettingsLoaded settings) {
    print('_applyFilters: $settings');

    _onlyExampleFiles = settings.exampleFileFilter.startsWith('Only');
    _removeExampleFiles = settings.exampleFileFilter.startsWith('Without');
    _onlyTestFiles = settings.testFileFilter.startsWith('Only');
    _removeTestFiles = settings.testFileFilter.startsWith('Without');
    if (settings.lineFilter.startsWith('All')) {
      _displayLineCount = null;
    } else if (settings.lineFilter.startsWith('Only')) {
      _displayLineCount = 1;
    } else if (settings.lineFilter.startsWith('First')) {
      _displayLineCount = 2;
    }
    search();
  }

  void openEditor(String? filePathName) {
    Process.run('code', [filePathName!]);
  }

}
