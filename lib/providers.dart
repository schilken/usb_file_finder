import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usb_file_finder/files_repository.dart';

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return FilesRepository();
});
