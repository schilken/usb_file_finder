// ignore_for_file: public_member_api_docs, sort_constructors_first

abstract class AppState {
  final String? primaryWord;
  final String? secondaryWord;
  final bool caseSensitive;
  const AppState({
    this.primaryWord,
    this.secondaryWord,
    this.caseSensitive = false,
  });
}

class AppInitial extends AppState {
  const AppInitial();
}

class AppInitialWithCase extends AppState {
  const AppInitialWithCase({required bool caseSensitive})
      : super(caseSensitive: caseSensitive);
}

class Detail {
  final String? folderPath;
  final String? storageName;
  final String? filePath;
  final String? imageUrl;
  final int? lineNumber;
  final String? filePathName;
  final String? projectPathName;

  Detail({
    this.folderPath,
    this.storageName,
    this.filePath,
    this.imageUrl,
    this.lineNumber,
    this.filePathName,
    this.projectPathName,
  });
}

class DetailsLoading extends AppState {
  const DetailsLoading();
}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<Detail> details;
  final String currentSearchParameters;
  final int fileCount;
  final int primaryHitCount;
  final int secondaryHitCount;
  final String? message;
  final int? displayLineCount;
  final bool isScanRunning;

  const DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentSearchParameters,
    required this.fileCount,
    required this.primaryHitCount,
    required this.secondaryHitCount,
    required this.isScanRunning,
    this.message,
    super.primaryWord,
    super.secondaryWord,
    super.caseSensitive,
    this.displayLineCount,
  });

  DetailsLoaded copyWith({
    String? fileType,
    List<Detail>? details,
    String? currentSearchParameters,
    int? fileCount,
    int? primaryHitCount,
    int? secondaryHitCount,
    String? message,
    int? displayLineCount,
    bool? isScanRunning,
    bool? caseSensitive,
  }) {
    return DetailsLoaded(
      fileType: fileType ?? this.fileType,
      details: details ?? this.details,
      currentSearchParameters:
          currentSearchParameters ?? this.currentSearchParameters,
      fileCount: fileCount ?? this.fileCount,
      primaryHitCount: primaryHitCount ?? this.primaryHitCount,
      secondaryHitCount: secondaryHitCount ?? this.secondaryHitCount,
      message: message ?? this.message,
      displayLineCount: displayLineCount ?? this.displayLineCount,
      isScanRunning: isScanRunning ?? this.isScanRunning,
      caseSensitive: caseSensitive ?? this.caseSensitive,
    );
  }
}
