import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageDetails {
  final String name;
  final int fileCount;
  final bool isSelected;

  StorageDetails({
    required this.name,
    required this.fileCount,
    required this.isSelected,
  });
}

class FilesRepository {
  List<FileSystemEntity> _entities = [];
  List<StorageDetails> devices = [];

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

  Future<void> readDeviceData() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final deviceDataFolder = p.join(
      appDocDir.path,
      'UsbFileFinder-Data',
    );
    var dir = Directory(deviceDataFolder);
    _entities = await dir.list().toList();
    devices = _entities.whereType<Directory>().map((entity) {
      return StorageDetails(
        name: p.basename(entity.path),
        fileCount: 0,
        isSelected: false,
      );
    }).toList();
  }
}
