import 'package:flutter/material.dart';

class EventModel {
  final int? id;
  final String? uuid;

  final String kind;
  final String title;
  final String? aboutEvent;

  final DateTime? eventFrom;
  final DateTime? eventTo;

  final TimeOfDay? timeFrom;
  final TimeOfDay? timeTo;

  final String? bgImage;
  final bool? displayJoinButton;

  final List<MediaModel>? medias;
  final List<Tagged>? tags;

  final String? schedule;
  final DateTime? scheduledAt;

  final Address? address;

  final String? statusOfPublishment;

  EventModel({
    this.id,
    this.uuid,
    required this.kind,
    required this.title,
    this.aboutEvent,
    this.eventFrom,
    this.eventTo,
    this.timeFrom,
    this.timeTo,
    this.bgImage,
    this.displayJoinButton,
    this.medias,
    this.tags,
    this.schedule,
    this.scheduledAt,
    this.address,
    this.statusOfPublishment,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json["id"],
      uuid: json["uuid"],

      kind: json["kind"] ?? "",
      title: json["eventTitle"] ?? "",

      aboutEvent: json["aboutEvent"],

      eventFrom: json["eventFrom"] != null
          ? DateTime.parse(json["eventFrom"])
          : null,

      eventTo: json["eventTo"] != null
          ? DateTime.parse(json["eventTo"])
          : null,

      timeFrom: _parseTime(json["timeFrom"]),
      timeTo: _parseTime(json["timeTo"]),

      bgImage: json["bgImage"],

      displayJoinButton: json["displayJoinButton"],

      medias: json["media"] != null
          ? (json["media"] as List)
          .map(
            (e) => MediaModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList()
          : null,

      tags: json["tags"] != null
          ? (json["tags"] as List)
          .map(
            (e) => Tagged.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList()
          : null,

      schedule: json["schedule"],

      scheduledAt: json["scheduledAt"] != null
          ? DateTime.parse(json["scheduledAt"])
          : null,

      address: json["address"] != null
          ? Address.fromJson(json["address"])
          : null,

      statusOfPublishment: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "kind": kind,
      "eventTitle": title,
      "aboutEvent": aboutEvent,

      "eventFrom": eventFrom != null
          ? _formatDate(eventFrom!)
          : null,

      "eventTo": eventTo != null
          ? _formatDate(eventTo!)
          : null,

      "timeFrom": timeFrom != null
          ? _formatTime(timeFrom!)
          : null,

      "timeTo": timeTo != null
          ? _formatTime(timeTo!)
          : null,

      "displayJoinButton": displayJoinButton,

      "schedule": schedule,

      "address": address?.toJson(),

      "scheduledAt": scheduledAt?.toUtc().toIso8601String(),

      "tags": tags
          ?.map((tag) => tag.toJson())
          .toList(),
    };
  }

  EventModel copyWith({
    int? id,
    String? uuid,
    String? kind,
    String? title,
    String? aboutEvent,
    DateTime? eventFrom,
    DateTime? eventTo,
    TimeOfDay? timeFrom,
    TimeOfDay? timeTo,
    String? bgImage,
    bool? displayJoinButton,
    List<MediaModel>? medias,
    List<Tagged>? tags,
    String? schedule,
    DateTime? scheduledAt,
    Address? address,
    String? statusOfPublishment,
  }) {
    return EventModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      aboutEvent: aboutEvent ?? this.aboutEvent,
      eventFrom: eventFrom ?? this.eventFrom,
      eventTo: eventTo ?? this.eventTo,
      timeFrom: timeFrom ?? this.timeFrom,
      timeTo: timeTo ?? this.timeTo,
      bgImage: bgImage ?? this.bgImage,
      displayJoinButton:
      displayJoinButton ?? this.displayJoinButton,
      medias: medias ?? this.medias,
      tags: tags ?? this.tags,
      schedule: schedule ?? this.schedule,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      address: address ?? this.address,
      statusOfPublishment:
      statusOfPublishment ?? this.statusOfPublishment,
    );
  }

  // -------------------------
  // Date helpers
  // -------------------------

  static String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  // -------------------------
  // Time helpers
  // -------------------------

  static TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final parts = value.split(":");

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  static String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:00";
  }
}


// ============================================================
// TAGGED
// ============================================================

class Tagged {
  final String? type;
  final int? id;

  // These are available from response's "ref"
  final String? name;
  final String? photoUrl;
  final String? partyInitial;

  Tagged({
    this.type,
    this.id,
    this.name,
    this.photoUrl,
    this.partyInitial,
  });

  factory Tagged.fromJson(Map<String, dynamic> json) {
    final ref = json["ref"];

    return Tagged(
      type: json["kind"],
      id: json["id"],

      name: ref != null ? ref["name"] : null,
      photoUrl: ref != null ? ref["imageUrl"] : null,
      partyInitial: ref != null ? ref["partyInitial"] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "kind": type,
      "id": id,
    };
  }
}


// ============================================================
// ADDRESS
// ============================================================

class Address {
  final String? addressText;
  final String? addressLink;

  Address({
    this.addressText,
    this.addressLink,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressText: json["text"],
      addressLink: json["link"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "text": addressText,
      "link": addressLink,
    };
  }
}


// ============================================================
// MEDIA
// ============================================================

class MediaModel {
  final int? id;
  final String? url;
  final String? mediaType;

  MediaModel({
    this.id,
    this.mediaType,
    this.url,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json["id"],
      url: json["url"],
      mediaType: json["mediaType"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "url": url,
      "mediaType": mediaType,
    };
  }
}