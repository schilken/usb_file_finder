import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());
  String? _primaryWord;
  String? _secondaryWord;
  String _currentPathname = "no file selected";
  int _fileCount = 0;
  int _primaryHitCount = 0;
  int _secondaryHitCount = 0;
  String? _folderPath;

  List<String>? _allFilePaths;

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
    if (_currentPathname == "no file selected") {
      emit(
        DetailsLoaded(
            currentPathname: _currentPathname,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: _secondaryHitCount,
            details: [],
            message: 'No filelist loaded'),
      );
      return;
    }
    if (_primaryWord == null || (_primaryWord ?? '').length < 4) {
      emit(
        DetailsLoaded(
            currentPathname: _currentPathname,
            fileCount: _fileCount,
            primaryHitCount: _primaryHitCount,
            secondaryHitCount: _secondaryHitCount,
            details: [],
            message: 'Primary Search Word must be at least 4 characters'),
      );
      return;
    }
    sectionsMap.clear();
    await processAllFilesIn(_primaryWord!);
//    await Future.delayed(Duration(milliseconds: 1000));
    final primaryResult = sectionsMap.keys
            .map((key) => Detail(
                  projectName: key.split('/lib').first,
                  title: key.split('/lib').last,
                  previewText: sectionsMap[key]!.join('\n'),
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
    emit(
      DetailsLoaded(
        currentPathname: _currentPathname,
        fileCount: _fileCount,
        primaryHitCount: _primaryHitCount,
        secondaryHitCount: _secondaryHitCount,
        details: secondaryResult,
        primaryWord: _primaryWord,
        secondaryWord: _secondaryWord,
      ),
    );
  }

  Future<void> processAllFilesIn(String primarySearchWord) async {
    var fileNumber = 0;
    var hitCount = 0;
    var hitFileCount = 0;
    for (final path in _allFilePaths!) {
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
          linesToSave = 10;
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
}
