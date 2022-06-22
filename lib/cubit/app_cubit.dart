import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());
  String? primaryWord;
  String? secondaryWord;
  String currentPathname = "no file selected";
  // pathname → loist of 10 lines following hit
  final sectionsMap = <String, List<String>>{};

  Future<void> loadFileList() async {
    debugPrint("Opening...");
    FilePickerResult? selected = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'txt',
      ],
    );
    currentPathname = selected?.paths.first ?? "no file selected";

    emit(DetailsLoading());
    await Future.delayed(Duration(milliseconds: 1000));
    emit(DetailsLoaded(currentPathname: currentPathname, details: [
      Detail(title: 'the first title'),
      Detail(title: 'the second title'),
    ]));
  }

  void setPrimarySearchWord(word) {
    print('setPrimarySearchWord: $word');
    primaryWord = word;
  }

  void setSecondarySearchWord(word) {
    print('setSecondarySearchWord: $word');
    secondaryWord = word;
  }

  Future<void> search() async {
    emit(DetailsLoading());
    print('search: $primaryWord $secondaryWord');
    if (currentPathname == "no file selected") {
      emit(
        DetailsLoaded(
            currentPathname: currentPathname,
            details: [],
            message: 'No filelist loaded'),
      );
      return;
    }
    if (primaryWord == null || (primaryWord ?? '').length < 5) {
      emit(
        DetailsLoaded(
            currentPathname: currentPathname,
            details: [],
            message: 'Primary Search Word must be at least 5 characters'),
      );
      return;
    }
    processAllFilesIn(currentPathname, primaryWord!);
    await Future.delayed(Duration(milliseconds: 1000));
    final primaryResult = sectionsMap.keys
            .map((key) => Detail(
                  projectName: key.split('/lib').first,
                  title: key.split('/lib').last,
                  previewText: sectionsMap[key]!.join('\n'),
                ))
        .toList();
    var secondaryResult = primaryResult;
    if (secondaryWord != null && (secondaryWord ?? '').length > 2) {
      secondaryResult = primaryResult
          .where((detail) => secondaryMatch(detail, secondaryWord!))
          .toList();
    }
    emit(
      DetailsLoaded(
        currentPathname: currentPathname,
        details: secondaryResult,
        primaryWord: primaryWord,
        secondaryWord: secondaryWord,
      ),
    );
  }

  void processAllFilesIn(String path, String primarySearchWord) async {
    File data = File(path);
    final lines = await data.readAsLines();
    var fileNumber = 0;
    var hitCount = 0;
    var hitFileCount = 0;
    for (final path in lines) {
//    print('searching in file number $fileNumber: $path: ');
      final hitsInFile = await searchFile(path, primarySearchWord);
      if (hitsInFile.isNotEmpty) {
        hitFileCount++;
        hitCount += hitsInFile.length;
        sectionsMap[path.replaceFirst(
            '/Users/aschilken/flutterdev/examples/', '')] = hitsInFile;
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
          print('$path: $lineNumber');
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
  
  Detail addMarkdown(Detail detail) {
    var markdowned =
        detail.previewText!.replaceAll(primaryWord!, '**$primaryWord**');
    return detail.copyWith(markdown: markdowned);
  }
}
