import 'package:flutter/cupertino.dart';

class TaggingPersonModel {
  final int? id;
  final int politicianId;
  final String? imagePath;
  final String name;
  final String? surname;
  final String designation;
  final String? region;
  const TaggingPersonModel({
    this.id,
    required this.politicianId,
    this.imagePath,
    required this.name,
    this.surname,
    required this.designation,
     this.region,
  });

  factory TaggingPersonModel.fromJson(Map<String, dynamic> json) {
    debugPrint("TAGGING PERSON JSON: $json");
    debugPrint("REGION VALUE: ${json['region']}");

    final rawImg = json["photoUrl"] ??
        json["imageUrl"] ??
        json["imagePath"] ??
        json["mediaUrl"] ??
        json["photo"] ??
        json["image"];

    return TaggingPersonModel(
      id: json['id'] as int?,
      politicianId: (json["politicianId"] ?? json["id"] ?? 0) as int,
      imagePath: rawImg?.toString(),
      name: json["fullName"]?.toString() ??
          json["name"]?.toString() ?? "",
      surname: json["surname"]?.toString(),
      designation: json["designation"]?.toString() ?? "",
      region: json["region"]?.toString(),
    );
  }

  String get fullName {
    if (surname == null || surname!.trim().isEmpty) {
      return name;
    }

    return '$name ${surname!}';
  }
}

class SelectedTaggingPersonModel {
  final int politicianId;
  final String type;
  final String name;
  final String? imagePath;
  final String? designation;

  const SelectedTaggingPersonModel({
    required this.politicianId,
    this.type = 'POLITICIAN',
    required this.name,
    this.imagePath,
    this.designation,
  });

  factory SelectedTaggingPersonModel.fromPerson(
      TaggingPersonModel person,
      ) {
    return SelectedTaggingPersonModel(
      politicianId: person.politicianId,
      type: 'POLITICIAN',
      name: person.fullName,
      imagePath: person.imagePath,
      designation: person.designation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'politicianId': politicianId,
      'name': name,
      'imagePath': imagePath,
      'designation': designation,
    };
  }
}