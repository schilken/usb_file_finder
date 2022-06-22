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
  final String? webDetailUUID;
  Detail({
    this.title,
    this.projectName,
    this.previewText,
    this.imageUrl,
    this.webDetailUUID,
  });

  Detail copyWith({
    String? title,
    String? projectName,
    String? previewText,
    String? markdown,
    String? imageUrl,
    String? webDetailUUID,
  }) {
    return Detail(
      title: title ?? this.title,
      projectName: projectName ?? this.projectName,
      previewText: previewText ?? this.previewText,
      imageUrl: imageUrl ?? this.imageUrl,
      webDetailUUID: webDetailUUID ?? this.webDetailUUID,
    );
  }
}

class DetailsLoading extends AppState {}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<Detail> details;
  final String currentPathname;
  final String? message;

  DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentPathname,
    this.message,
    String? primaryWord,
    String? secondaryWord,
  }) : super(primaryWord: primaryWord, secondaryWord: secondaryWord);

  DetailsLoaded copyWith({
    String? fileType,
    List<Detail>? details,
    String? currentPathname,
    String? message,
  }) {
    return DetailsLoaded(
      fileType: fileType ?? this.fileType,
      details: details ?? this.details,
      currentPathname: currentPathname ?? this.currentPathname,
      message: message ?? this.message,
    );
  }
}
