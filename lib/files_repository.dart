import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:usb_file_finder/cubit/device_cubit.dart';

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


  Future<List<String>> loadTotalFileList(String fileType) async {
    List<String> files = [];
    await for (StorageDetails device in Stream.fromIterable(_devices)) {
      if (device.isSelected) {
        files.addAll(await _loadFileList(device.name, fileType));
      }
    }
    return files;
  }

  Stream<String> allLinesAsStream(String fileType) async* {
    await for (StorageDetails device in Stream.fromIterable(_devices)) {
      if (device.isSelected) {
        yield* await _fileListStream(device.name, fileType);
      }
    }
  }

  Future<Stream<String>> _fileListStream(
    String storageName,
    String fileType,
  ) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final inputFilePath = p.join(
      appDocDir.path,
      'UsbFileFinder-Data',
      storageName,
      filenameFromType(fileType),
    );
//    print('_fileListStream inputFilePath: $inputFilePath');
    final file = File(inputFilePath);
    if (file.existsSync()) {
      return file
          .openRead()
          .transform(utf8.decoder) // Decode bytes to UTF-8.
          .transform(const LineSplitter());
    } else {
      return const Stream.empty();
    }
  }

  Future<List<String>> _loadFileList(
    String storageName,
    String fileType,
  ) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final inputFilePath = p.join(
      appDocDir.path,
      'UsbFileFinder-Data',
      storageName,
      filenameFromType(fileType),
    );
    print('inputFilePath: $inputFilePath');
    try {
      File data = File(inputFilePath);
      return await data.readAsLines();
    } on Exception {
      return [];
    }
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
    final Directory dir =
        await Directory(deviceDataFolder).create(recursive: true);
//    var dir = Directory(deviceDataFolder);
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

  toggleDevices(StorageAction action, int index) {
    switch (action) {
      case StorageAction.selectAll:
        _devices = _devices
            .map((device) => device.copyWith(isSelected: true))
            .toList();
        break;
      case StorageAction.selectAllOthers:
        _devices = _devices
            .map((device) => device.name == _devices[index].name
                ? device.copyWith(isSelected: false)
                : device.copyWith(isSelected: true))
            .toList();
        break;
      case StorageAction.unselectAllOthers:
        _devices = _devices
            .map((device) => device.name == _devices[index].name
                ? device.copyWith(isSelected: true)
                : device.copyWith(isSelected: false))
            .toList();
        break;
      case StorageAction.showDetails:
      case StorageAction.rescan:
        break;
    }
    return _devices;
  }
}
