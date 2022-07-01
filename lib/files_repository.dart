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
    required this.isMounted,
  });

  final String name;
  final int fileCount;
  final bool isSelected;
  final bool isMounted;

  StorageDetails copyWith({
    String? name,
    int? fileCount,
    bool? isSelected,
    bool? isMounted,
  }) {
    return StorageDetails(
      name: name ?? this.name,
      fileCount: fileCount ?? this.fileCount,
      isSelected: isSelected ?? this.isSelected,
      isMounted: isMounted ?? this.isMounted,
    );
  }

  @override
  List<Object?> get props => [name, fileCount, isSelected, isMounted];
}

class FilesRepository {
  List<FileSystemEntity> _entities = [];
  List<StorageDetails> _devices = [];
  List<String> _mountedVolumes = [];

  // Future<List<String>> loadTotalFileList(String fileType) async {
  //   List<String> files = [];
  //   await for (StorageDetails device in Stream.fromIterable(_devices)) {
  //     if (device.isSelected) {
  //       files.addAll(await _loadFileList(device.name, fileType));
  //     }
  //   }
  //   return files;
  // }

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

  // Future<List<String>> _loadFileList(
  //   String storageName,
  //   String fileType,
  // ) async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   final inputFilePath = p.join(
  //     appDocDir.path,
  //     'UsbFileFinder-Data',
  //     storageName,
  //     filenameFromType(fileType),
  //   );
  //   print('inputFilePath: $inputFilePath');
  //   try {
  //     File data = File(inputFilePath);
  //     return await data.readAsLines();
  //   } on Exception {
  //     return [];
  //   }
  // }

  String filenameFromType(String type) {
    final replaced = type.toLowerCase().replaceAll(' ', '-');
    return '$replaced.txt';
  }

  bool isMounted(String name) {
    return _mountedVolumes.contains(name);
  }

  Future<void> readMountedDevices() async {
    final Directory dir = Directory('/Volumes');
    _mountedVolumes =
        await dir.list().map((entitiy) => p.basename(entitiy.path)).toList();
  }

  Future<Directory> get deviceDataDirectory async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDocDir.path, 'UsbFileFinder-Data'))
      ..create(recursive: true);
  }

  Future<List<StorageDetails>> readDeviceData() async {
    await readMountedDevices();
    final dir = await deviceDataDirectory;
    _entities = await dir.list().toList();
    _devices = _entities.whereType<Directory>().map((entity) {
      final storageName = p.basename(entity.path);
      return StorageDetails(
        name: storageName,
        fileCount: 0,
        isSelected: false,
        isMounted: isMounted(storageName),
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

  Future<List<StorageDetails>> executeStorageAction(
      StorageAction action, int index) async {
    switch (action) {
      case StorageAction.selectAll:
        _devices = _devices
            .map((device) => device.copyWith(isSelected: true))
            .toList();
        return _devices;
      case StorageAction.selectAllOthers:
        _devices = _devices
            .map((device) => device.name == _devices[index].name
                ? device.copyWith(isSelected: false)
                : device.copyWith(isSelected: true))
            .toList();
        return _devices;
      case StorageAction.unselectAllOthers:
        _devices = _devices
            .map((device) => device.name == _devices[index].name
                ? device.copyWith(isSelected: true)
                : device.copyWith(isSelected: false))
            .toList();
        return _devices;
      case StorageAction.showDetails:
      case StorageAction.rescan:
        break;
      case StorageAction.eject:
        await runEjectCommand(_devices[index].name);
        break;
      case StorageAction.removeData:
        final dir = await deviceDataDirectory;
        final directoryPath = p.join(dir.path, _devices[index].name);
        final dataDirectory = Directory(directoryPath);
        try {
          if (await dataDirectory.exists()) {
            await dataDirectory.delete(recursive: true);
          }
        } catch (e) {
          print('StorageAction.removeData: $e');
        }
        break;
    }
    return readDeviceData();
  }

  Future<void> runEjectCommand(String volumeName) async {
    var process = await Process.run('diskutil', ['eject', volumeName]);
    print('runEjectCommand: stdout:  ${process.stdout} err: ${process.stderr}');
  }

  String volumePathForIndex(int index) {
    return '/Volumes/${_devices[index].name}';
  }


}
