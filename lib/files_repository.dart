import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageDetails extends Equatable {

  const StorageDetails({
    required this.name,
    required this.fileCount,
    required this.isSelected,
  });

  final String name;
  final int fileCount;
  final bool isSelected;

  StorageDetails copyWith({
    String? name,
    int? fileCount,
    bool? isSelected,
  }) {
    return StorageDetails(
      name: name ?? this.name,
      fileCount: fileCount ?? this.fileCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [name, fileCount, isSelected];

}

class FilesRepository {
  List<FileSystemEntity> _entities = [];
  List<StorageDetails> _devices = [];

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

  Future<List<StorageDetails>> readDeviceData() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final deviceDataFolder = p.join(
      appDocDir.path,
      'UsbFileFinder-Data',
    );
    var dir = Directory(deviceDataFolder);
    _entities = await dir.list().toList();
    _devices = _entities.whereType<Directory>().map((entity) {
      return StorageDetails(
        name: p.basename(entity.path),
        fileCount: 0,
        isSelected: false,
      );
    }).toList();
    return _devices;
  }

  List<StorageDetails> toggleDevice(int index, bool? value) {
    _devices = _devices
        .map((device) => device.name == _devices[index].name
            ? device.copyWith(isSelected: value)
            : device)
        .toList();
    return _devices;
  }
}
