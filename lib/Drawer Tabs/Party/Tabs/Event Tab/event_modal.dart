class EventModel {
  final int? id;
  final String?uuid;
  final String kind;
  final String title;
  final String? aboutEvent;
  final DateTime? eventFrom;
  final DateTime? eventTo;
  final DateTime?timeFrom;
  final DateTime? timeTo;
  final String? bgImage;
  final bool? displayJoinButton;
  final List<MediaModel>? medias;
  final List<Tagged>? tags;
  final DateTime? scheduledAt;
  final Address?address;
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
    this.scheduledAt,
    this.address,
    this.statusOfPublishment,
});
  factory EventModel.fromJson(Map<String, dynamic>json){
    return EventModel(
      id: json["id"],
      uuid: json["uuid"],
      kind: json["kind"],
      title: json["eventTitle"],
      aboutEvent: json["aboutEvent"],
      eventFrom: json["eventFrom"]!=null?
                 DateTime.parse(json["eventFrom"]):null,
      eventTo: json["eventTo"]!=null?
               DateTime.parse(json["eventTo"]):null,
      timeFrom: json["timeFrom"],
      timeTo: json["timeTo"],
      bgImage: json["bgImage"],
      displayJoinButton: json["displayJoinButton"],
    medias: json["media"]!=null?
    (json["media"] as List)
      .map((e)=>MediaModel.fromJson(e))
        .toList():null,
      tags: json["tags"]!=null?
      (json["tags"] as List)
      .map((e)=>Tagged.fromJson(e)).toList():null,
      //scheduledAt: json["scheduledAt"],
      address: json["address"]!=null?Address.fromJson(json["address"]):null,
      statusOfPublishment: json["status"],


    );
  }
  EventModel copyWith({
    int? id,
    String? uuid,
    String? kind,
    String? title,
    String? aboutEvent,
    DateTime? eventFrom,
    DateTime? eventTo,
    DateTime? timeFrom,
    DateTime? timeTo,
    String? bgImage,
    bool? displayJoinButton,
    List<MediaModel>? medias,
    List<Tagged>? tags,
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
      displayJoinButton: displayJoinButton ?? this.displayJoinButton,
      medias: medias ?? this.medias,
      tags: tags ?? this.tags,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      address: address ?? this.address,
      statusOfPublishment:
      statusOfPublishment ?? this.statusOfPublishment,
    );
  }
}
class Tagged{
  final String? type;
  final int? id;
  final String? name;
  final String? photoUrl;
  Tagged({
    this.type,
    this.id,
    this.name,
    this.photoUrl,
});
  factory Tagged.fromJson(Map<String, dynamic>json){
    return Tagged(
      type: json["kind"],
      id: json["id"],
      name: json["name"],
      photoUrl: json["photoUrl"],
    );
  }
}
class Address{
  final String? addressText;
  final String? addressLink;
Address({
    this.addressText,
  this.addressLink,
});
factory Address.fromJson(Map<String, dynamic>json){
  return Address(
    addressText:json["text"],
    addressLink: json["link"],
  );
}
}
class MediaModel{
  final int? id;
  final String?url;
  final String? mediaType;
  MediaModel({
   this.id,
   this.mediaType,
   this.url,
});
factory MediaModel.fromJson(Map<String, dynamic>json){
  return MediaModel(
    id: json["id"],
    url: json["url"],
    mediaType: json["mediaType"],
  );
}
}