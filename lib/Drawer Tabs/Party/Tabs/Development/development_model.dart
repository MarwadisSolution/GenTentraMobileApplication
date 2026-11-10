
import '../Feed Tab/feed_model.dart' show Tagged;

class DevelopmentModel {
  final int id;
  final DevelopmentAuthor? author;
  final int? authorUserId;
  final int? authorPartyId;
  final String? title;
  final String? description;
  final String? from;
  final String? to;
  final List<DevelopmentMedia> media;
  final List<Tagged> taggedPoliticians;
  final List<Tagged> taggedParties;
  final List<int> taggedPoliticianIds;
  final List<int> taggedPartyIds;
  final DateTime?timeStamp;
  final String? updatedAt;

  DevelopmentModel({
   required this.id,
    this.author,
    this.authorUserId,
    this.authorPartyId,
    this.title,
    this.description,
    this.from,
    this.to,
    this.media=const [],
    this.taggedPoliticians = const [],
    this.taggedParties = const [],
    this.taggedPoliticianIds = const [],
    this.taggedPartyIds = const [],
    this.timeStamp,
    this.updatedAt,
});
  factory DevelopmentModel.fromJson(Map<String, dynamic> json){
    return DevelopmentModel(
      id: json['id']??0,
      author: json['author']!=null?
          DevelopmentAuthor.fromJson(json['author']):null,
      authorUserId: json['authorUserId'],
      authorPartyId: json['authorPartyId'],
      title: json['title'],
      description: json['description'],
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      media: (json['media'] as List? ??[])
        .map((e)=>DevelopmentMedia.fromJson(e)).toList(),
      taggedPoliticians: (json['taggedPoliticians'] as List? ?? [])
          .map((e) => Tagged.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList(),

      taggedParties: (json['taggedParties'] as List? ?? [])
          .map((e) => Tagged.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList(),

      taggedPoliticianIds:
      (json['taggedPoliticianIds'] as List? ?? [])
          .map((e) => e as int)
          .toList(),

      taggedPartyIds: (json['taggedPartyIds'] as List? ?? [])
          .map((e) => e as int)
          .toList(),

      timeStamp: json["timestamp"] != null
          ? DateTime.parse(json["timestamp"])
          : null,
      updatedAt: json['updatedAt'],
    );
  }
  Map<String, dynamic> toJson(){
    return {
      'title':title,
      'description':description,
      'authorPartyId':authorPartyId,
      'from':from,
      'to':to,
      'media': media.map((e) => e.toJson()).toList(),
      'taggedPoliticianIds': taggedPoliticianIds,
      'taggedPartyIds': taggedPartyIds,
    };
  }
}

class DevelopmentAuthor{
  final String? type;
  final int? id;
  final int? partyId;
  final String? name;
  final String? region;
  final String? designation;
  final String? photoUrl;
  final String? state;
  final String? country;
  DevelopmentAuthor({
    this.type,
    this.id,
    this.partyId,
    this.name,
    this.region,
    this.designation,
    this.photoUrl,
    this.state,
    this.country,
});
  factory DevelopmentAuthor.fromJson(Map<String, dynamic> json){
    return DevelopmentAuthor(
      type: json['type'],
      id: json['id'],
      partyId: json['partyId'],
      name: json['name'],
      region: json['region'],
      designation: json['designation'],
      photoUrl: json['photoUrl'],
      state: json['state'],
      country: json['country'],
    );
  }
}

class DevelopmentMedia{
  final int id;
  final String? mediaType;
  final String? url;
  DevelopmentMedia({
    required this.id,
    this.mediaType,
    this.url,
});
  factory DevelopmentMedia.fromJson(Map<String, dynamic> json){
    return DevelopmentMedia(id: json['id']??0,
    mediaType: json['mediaType'],
      url: json['url'],
    );
  }
  Map<String, dynamic> toJson(){
    return {
      'url':url,
    };
  }
}