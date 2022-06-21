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
  final String? url;
  final String? previewText;
  final String? imageUrl;
  final String? webDetailUUID;
  Detail({
    this.title,
    this.url,
    this.previewText,
    this.imageUrl,
    this.webDetailUUID,
  });
}

class DetailsLoading extends AppState {}

class DetailsLoaded extends AppState {
  final String? fileType;
  final List<Detail> details;
  final String currentPathname;

  DetailsLoaded({
    this.fileType,
    required this.details,
    required this.currentPathname,
  });

  DetailsLoaded copyWith({
    String? fileType,
    List<Detail>? details,
    String? currentPathname,
  }) {
    return DetailsLoaded(
      fileType: fileType ?? this.fileType,
      details: details ?? this.details,
      currentPathname: currentPathname ?? this.currentPathname,
    );
  }
}
