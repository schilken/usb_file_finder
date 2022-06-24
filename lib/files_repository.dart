import 'dart:io';

class FilesRepository {
  String? _currentFolderPath;
  String? _fileType;
  List<String> _allFilePaths = [];

  set folderPath(String path) {
    _currentFolderPath = path;
  }

  String? get currentFolderPath => _currentFolderPath;

  Future<int> runFindCommand(String fileType) async {
    _fileType = fileType;
    print('scanFolder: $_currentFolderPath for $fileType');
    if (_currentFolderPath == null || _fileType == null) {
      _allFilePaths = [];
      return 0;
    }
    _allFilePaths = (await _runFindCommand(_currentFolderPath!, _fileType!))
        .where((path) => path.isNotEmpty)
        .toList();
    return _allFilePaths.length;
  }

  List<String> get allFilePaths => _allFilePaths;

  Future<List<String>> _runFindCommand(
      String workingDir, String extension) async {
    var process = await Process.run(
        'find', [workingDir, '-name', '*$extension', '-type', 'f']);
    return process.stdout.split('\n');
  }
}
