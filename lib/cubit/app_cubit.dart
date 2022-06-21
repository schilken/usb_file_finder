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
    await Future.delayed(Duration(milliseconds: 1000));
    emit(DetailsLoaded(currentPathname: currentPathname, details: [
      Detail(title: 'the first title'),
      Detail(title: 'the second title'),
    ]));
  }
}
