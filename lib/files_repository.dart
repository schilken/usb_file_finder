// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:usb_file_finder/cubit/device_cubit.dart';
import 'package:usb_file_finder/models/storage_info.dart';

typedef IntStringCallback = void Function(
  int fileCount,
  String volumePath,
);
typedef IntStringStringCallback = void Function(
  int fileCount,
  String volumePath,
  String folderPathPath,
);

class FilesRepository {
  List<FileSystemEntity> _entities = [];
  List<StorageDetails> _devices = [];
  List<String> _mountedVolumes = [];
  List<String> _skippedFolderNames = [];
  bool _includeHiddenFolders = false;

  var ignoredFolders = <String>[];

  set includeHiddenFolders(bool newValue) => _includeHiddenFolders = newValue;

  bool _ignoreFolder(String folderPath) {
    final folderName = p.basename(folderPath);
    if (_includeHiddenFolders == false && folderName.startsWith('.')) {
      _skippedFolderNames.add(folderPath);
      return true;
    }
    if (ignoredFolders.contains(folderName)) {
      _skippedFolderNames.add(folderPath);
      return true;
    }
    // ignore all symboliy links
    return FileSystemEntity.isLinkSync(folderPath);
  }

  Future<StreamSubscription<File>> scanVolume({
    required String volumePath,
    required IntStringStringCallback progressCallback,
    required IntStringCallback onScanDone,
  }) async {
    var dir = Directory(volumePath);
    final deviceName = p.basename(volumePath);
    await removeStorageData(deviceName);
    _skippedFolderNames.clear();
    Map<String, File> extensionMap = await buildExtensionMap(deviceName);
    Stream<File> scannedFiles = scanningFilesWithAsyncRecursive(dir);
    var fileCount = 0;
    String folderPath = '';
    final subscription = scannedFiles.listen((File file) async {
      final listfile = extensionMap[p.extension(file.path)];
      if (listfile != null) {
        listfile.writeAsStringSync('${file.path}\n', mode: FileMode.append);
        if (++fileCount % 1000 == 0) {
          final components = p.split(file.path);
          folderPath = components.length > 3 ? components[3] : '';
          progressCallback(fileCount, volumePath, folderPath);
        }
      }
    });
    subscription.onDone(
      () async {
        final dir = await deviceDataDirectory;
        final filePath = p.join(dir.path, deviceName, 'ignored-folders.txt');
        final File ignoredFoldersListFile = File(filePath);
        await ignoredFoldersListFile
            .writeAsString(_skippedFolderNames.join('\n'));
        onScanDone(fileCount, volumePath);
      },
    );

    return subscription;
  }

//async* + yield* for recursive functions
  Stream<File> scanningFilesWithAsyncRecursive(Directory dir) async* {
    //dirList is FileSystemEntity list for every directories/subdirectories
    //entities in this list might be file, directory or link
    try {
      var dirList = dir.list(followLinks: false);
      await for (final FileSystemEntity entity in dirList) {
        if (entity is File) {
          yield entity;
        } else if (entity is Directory && !_ignoreFolder(entity.path)) {
          yield* scanningFilesWithAsyncRecursive(Directory(entity.path));
        }
      }
    } on Exception catch (e) {
      print('exception: $e');
    }
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
      case StorageAction.showInfo:
      case StorageAction.rescan:
        break;
      case StorageAction.eject:
        await runEjectCommand(_devices[index].name);
        break;
      case StorageAction.removeData:
        await removeStorageData(_devices[index].name);
        break;
    }
    return readDeviceData();
  }

  Future<void> removeStorageData(String name) async {
    final dir = await deviceDataDirectory;
    final directoryPath = p.join(dir.path, name);
    final dataDirectory = Directory(directoryPath);
    try {
      if (await dataDirectory.exists()) {
        await dataDirectory.delete(recursive: true);
      }
    } catch (e) {
      print('StorageAction.removeData: $e');
    }
  }

  Future<void> runEjectCommand(String volumeName) async {
    var process = await Process.run('diskutil', ['eject', volumeName]);
    print('runEjectCommand: stdout:  ${process.stdout} err: ${process.stderr}');
  }

  String volumePathForIndex(int index) {
    return '/Volumes/${_devices[index].name}';
  }

  StorageDetails storageDetailsForIndex(int index) {
    return _devices[index];
  }

  Future<List<StorageInfo>> createFullStorageInfo() async {
    final allStorageInfos = <StorageInfo>[];
    for (final device in _devices) {
      final storageInfo = await createStorageInfoForDevice(device);
      allStorageInfos.add(storageInfo);
    }
    return allStorageInfos;
  }

  Future<int> _lineCountForFileType(
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
      return (await data.readAsLines()).length;
    } on Exception {
      return 0;
    }
  }

  final fileTypes = <String>[
    'text-files',
    'audio-files',
    'video-files',
    'misc-files',
    'zip-files',
    'image-files',
    'dart-files',
  ];

  Future<StorageInfo> createStorageInfoForDevice(StorageDetails device) async {
    final fileCountMap = <String, int>{};
    for (final fileType in fileTypes) {
      final fileCount = await _lineCountForFileType(device.name, fileType);
      fileCountMap[fileType] = fileCount;
    }
    final totalFileCount = fileCountMap.values.reduce((sum, b) => sum + b);
    final dateOfLastScan = DateTime.now();
    final storageInfo = StorageInfo(
      name: device.name,
      isMounted: device.isMounted,
      isSelected: device.isSelected,
      totalFileCount: totalFileCount,
      fileCountMap: fileCountMap,
      dateOfLastScan: dateOfLastScan,
      scanDuration: 0,
      scanSpeed: 0,
    );
    return storageInfo;
  }

  Future<Map<String, File>> buildExtensionMap(String deviceName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final outputFolder =
        p.join(appDocDir.path, 'UsbFileFinder-Data', deviceName);
//    print('outputFolder: $outputFolder');

    final Directory directory =
        await Directory(outputFolder).create(recursive: true);
    final File textListFile = File('${directory.path}/text-files.txt');
    final File audioListFile = File('${directory.path}/audio-files.txt');
    final File videoListFile = File('${directory.path}/video-files.txt');
    final File miscListFile = File('${directory.path}/misc-files.txt');
    final File zipListFile = File('${directory.path}/zip-files.txt');
    final File imageListFile = File('${directory.path}/image-files.txt');
    final File dartListFile = File('${directory.path}/dart-files.txt');

    return <String, File>{
      '.pdf': textListFile,
      '.txt': textListFile,
      '.epub': textListFile,
      '.doc': textListFile,
      '.odt': textListFile,
      '.mobi': textListFile,
      '.azw': textListFile,
      '.azw3': textListFile,
      '.md': textListFile,
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
      //
      '.dart': dartListFile,
      '.yaml': dartListFile,
    };
  }
}
