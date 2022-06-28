import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FilesRepository {

  Future<List<String>> loadFileList(
    String storageName,
    String fileType,
  ) async {
    print('loadFileList: $storageName for $fileType');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final inputFilePath = p.join(
      appDocDir.path,
      'UsbFileFinder-Data',
      storageName,
      filenameFromType(fileType),
    );
    print('inputFilePath: $inputFilePath');
    File data = File(inputFilePath);
    final allFilePaths = await data.readAsLines();
    return allFilePaths;
  }


  String filenameFromType(String type) {
    final replaced = type.toLowerCase().replaceAll(' ', '-');
    return '$replaced.txt'; 
  }

}
