import 'dart:convert';

import 'package:equatable/equatable.dart';

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

class StorageInfo extends Equatable {
  const StorageInfo({
    required this.name,
    required this.totalFileCount,
    required this.fileCountMap,
    required this.isSelected,
    required this.isMounted,
    this.dateOfLastScan,
    this.scanDuration,
    this.scanSpeed,
  });

  final String name;
  final int totalFileCount;
  final Map<String, int> fileCountMap;
  final DateTime? dateOfLastScan;
  final int? scanDuration;
  final int? scanSpeed;
  final bool isSelected;
  final bool isMounted;

  // StorageDetails copyWith({
  //   String? name,
  //   int? fileCount,
  //   bool? isSelected,
  //   bool? isMounted,
  // }) {
  //   return StorageDetails(
  //     name: name ?? this.name,
  //     fileCount: fileCount ?? this.fileCount,
  //     isSelected: isSelected ?? this.isSelected,
  //     isMounted: isMounted ?? this.isMounted,
  //   );
  // }

  @override
  List<Object?> get props => [
        name,
        totalFileCount,
        isSelected,
        isMounted,
        fileCountMap,
        dateOfLastScan,
        scanDuration,
        scanSpeed
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'totalFileCount': totalFileCount,
      'fileCountMap': fileCountMap,
      'dateOfLastScan': dateOfLastScan?.millisecondsSinceEpoch,
      'scanDuration': scanDuration,
      'scanSpeed': scanSpeed,
      'isSelected': isSelected,
      'isMounted': isMounted,
    };
  }

  factory StorageInfo.fromMap(Map<String, dynamic> map) {
    final fileCountMap = <String, int>{};
    final inputMap = map['fileCountMap'];
    inputMap.forEach((k, v) => fileCountMap[k] = v as int);
    return StorageInfo(
      name: map['name'] as String,
      totalFileCount: map['totalFileCount'] as int,
      fileCountMap: fileCountMap,
      dateOfLastScan: map['dateOfLastScan'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfLastScan'] as int)
          : null,
      scanDuration:
          map['scanDuration'] != null ? map['scanDuration'] as int : null,
      scanSpeed: map['scanSpeed'] != null ? map['scanSpeed'] as int : null,
      isSelected: map['isSelected'] as bool,
      isMounted: map['isMounted'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory StorageInfo.fromJson(String source) =>
      StorageInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
