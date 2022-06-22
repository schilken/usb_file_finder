// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

@immutable
abstract class AppState {
  final String? primaryWord;
  final String? secondaryWord;
  AppState({
    this.primaryWord,
    this.secondaryWord,
  });
}

class AppInitial extends AppState {}

class Detail {
  final String? title;
  final String? projectName;
  final String? previewText;
  final String? imageUrl;
  final int? lineNumber;
  Detail({
    this.title,
    this.projectName,
    this.previewText,
    this.imageUrl,
    this.lineNumber,
  });

  Detail copyWith({
    String? title,
    String? projectName,
    String? previewText,
    String? imageUrl,
    int? lineNumber,
  }) {
    return Detail(
      title: title ?? this.title,
      projectName: projectName ?? this.projectName,
      previewText: previewText ?? this.previewText,
      imageUrl: imageUrl ?? this.imageUrl,
      lineNumber: lineNumber ?? this.lineNumber,
    );
  }
}

class DetailsLoading extends AppState {}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<Detail> details;
  final String currentPathname;
  final int fileCount;
  final int primaryHitCount;
  final int secondaryHitCount;
  final String? message;

  DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentPathname,
    required this.fileCount,
    required this.primaryHitCount,
    required this.secondaryHitCount,
    this.message,
    String? primaryWord,
    String? secondaryWord,
  }) : super(primaryWord: primaryWord, secondaryWord: secondaryWord);

  DetailsLoaded copyWith({
    String? fileType,
    List<Detail>? details,
    String? currentPathname,
    int? fileCount,
    int? primaryHitCount,
    int? secondaryHitCount,
    String? message,
  }) {
    return DetailsLoaded(
      fileType: fileType ?? this.fileType,
      details: details ?? this.details,
      currentPathname: currentPathname ?? this.currentPathname,
      message: message ?? this.message,
      fileCount: fileCount ?? this.fileCount,
      primaryHitCount: primaryHitCount ?? this.primaryHitCount,
      secondaryHitCount: secondaryHitCount ?? this.secondaryHitCount,
    );
  }
}
