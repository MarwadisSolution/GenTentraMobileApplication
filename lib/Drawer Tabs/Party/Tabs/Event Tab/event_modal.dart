import 'package:flutter/material.dart';

class EventModel {
  final int? id;
  final String? uuid;
  final Author? author;
  final int? authorUserId;
  final int? authorPartyId;
  final String? authorType;
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
  final bool? isRequestorAttending;

  final List<AttendeePreview>? attendeesPreview;
  final int? attendeeCount;
  EventModel({
    this.id,
    this.uuid,
     this.author,
    this.authorUserId,
    this.authorPartyId,
    this.authorType,

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
    this.isRequestorAttending,
    this.attendeesPreview,
    this.attendeeCount,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(

      id: json["id"],
      uuid: json["uuid"],

      authorUserId: json["authorUserId"],
      authorPartyId: json["authorPartyId"],
      authorType: json["authorType"],

      author: json["author"] != null
          ? Author.fromJson(
        json["author"] as Map<String, dynamic>,
      )
          : null,

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
        isRequestorAttending:json["isRequestorAttending"],
      attendeesPreview: json["attendeesPreview"] != null
          ? (json["attendeesPreview"] as List)
          .map(
            (e) => AttendeePreview.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList()
          : null,

      attendeeCount: json["attendeeCount"],
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
    Author? author,
    int? authorUserId,
    int? authorPartyId,
    String? authorType,
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
    bool?isRequestorAttending,
    List<AttendeePreview>? attendeesPreview,
    int? attendeeCount,
  }) {
    return EventModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,

      author: author ?? this.author,
      authorUserId: authorUserId ?? this.authorUserId,
      authorPartyId: authorPartyId ?? this.authorPartyId,
      authorType: authorType ?? this.authorType,

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
        isRequestorAttending: isRequestorAttending??this.isRequestorAttending,
      attendeesPreview:
      attendeesPreview ?? this.attendeesPreview,

      attendeeCount:
      attendeeCount ?? this.attendeeCount,
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
//-----------Author
class Author {
  final String? kind;
  final int? id;
  final String? name;
  final String? photoUrl;
  final String? partyInitial;

  Author({
    this.kind,
    this.id,
    this.name,
    this.photoUrl,
    this.partyInitial,

  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      kind: json["kind"],
      id: json["id"],
      name: json["name"],
      photoUrl: json["imageUrl"],
      partyInitial: json["partyInitial"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    };
}

///-----------------Attendence
class AttendeePreview {
  final int? eventId;
  final int? userId;
  final String? rsvpStatus;
  final String? createdAt;
  final AttendeeUser? user;

  AttendeePreview({
    this.eventId,
    this.userId,
    this.rsvpStatus,
    this.createdAt,
    this.user,
  });

  factory AttendeePreview.fromJson(Map<String, dynamic> json) {
    return AttendeePreview(
      eventId: json["eventId"],
      userId: json["userId"],
      rsvpStatus: json["rsvpStatus"],
      createdAt: json["createdAt"],
      user: json["user"] != null
          ? AttendeeUser.fromJson(
        json["user"] as Map<String, dynamic>,
      )
          : null,
    );
  }
}

class AttendeeUser {
  final String? kind;
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? partyInitial;

  AttendeeUser({
    this.kind,
    this.id,
    this.name,
    this.imageUrl,
    this.partyInitial,
  });

  factory AttendeeUser.fromJson(Map<String, dynamic> json) {
    return AttendeeUser(
      kind: json["kind"],
      id: json["id"],
      name: json["name"],
      imageUrl: json["imageUrl"],
      partyInitial: json["partyInitial"],
    );
  }
}
// ============================================================
// ATTENDEE PAGINATION RESPONSE
// ============================================================

class AttendeePaginationResponse {
  final List<AttendeePreview> items;

  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool hasNext;

  final int goingCount;
  final int interestedCount;
  final int declinedCount;

  AttendeePaginationResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.goingCount,
    required this.interestedCount,
    required this.declinedCount,
  });
}