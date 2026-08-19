class FeedModel {
final int? id;
final String?uuid;
final Author? author;

final int? authorUserId;
final int? authorPartyId;
final String? kind;
final String? title;
final String? body;
final Map<String, dynamic>? quote;
final int? repostPostId; ///----Ye check karna hai
final String? status;
final bool? hidden;
final DateTime? scheduledAt;
final DateTime? timestamp;
final DateTime? updatedAt;
final List<FeedMedia>? media;
final List<Tagged>?tagged;
final int? viewCount;
final int?likeCount;
final int?commentCount;
final bool? reacted;

FeedModel({
  this.id,
  this.uuid,
  this.author,
  this.authorUserId,
  this.authorPartyId,
  this.kind,

  this.title,
  this.body,
  this.quote,
  this.repostPostId,

  this.status,
  this.hidden,
  this.scheduledAt,
  this.timestamp,
  this.updatedAt,
  this.media,
  this.tagged,
  this.viewCount,
  this.likeCount,
  this.commentCount,
  this.reacted,
});
factory FeedModel.fromJson(Map<String, dynamic>json){
  return FeedModel(
    id: json["id"],
    uuid: json["uuid"],
    author: json["author"]!=null?
        Author.fromJson(json["author"]):null,
    authorUserId: json["authorUserId"],
    authorPartyId: json["authorPartyId"],

    kind: json["kind"],
    title: json["title"],
    body: json["postText"] ?? json["body"],
    quote: json["quote"],
    repostPostId: json["repostPostId"],
    status: json["status"],
    hidden: json["hidden"],
    scheduledAt: json["scheduledAt"] != null
        ? DateTime.parse(json["scheduledAt"])
        : null,
    timestamp: json["timestamp"] != null
        ? DateTime.parse(json["timestamp"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : null,
    media: json["media"] != null
        ? (json["media"] as List)
        .map((e) => FeedMedia.fromJson(e))
        .toList()
        : [],
    tagged: json["tagged"]!=null?
    (json["tagged"] as List)
        .map((e)=>Tagged.fromJson(e)).toList():[],
    viewCount: json["viewCount"],
    likeCount: json["likeCount"],
    commentCount: json["commentCount"],
    reacted: json["reactedByMe"],
  );
}
Map<String, dynamic>toJson(){
  return {
    "title": title,
    "body":body,
    "quote": quote,
    "kind":kind,

    "authorPartyId": authorPartyId,
    "tagged":tagged?.map((e)=>e.toPostJson()).toList(),
    "scheduledAt": scheduledAt?.toIso8601String(),
  };
}
}
///----------------------Author
class Author {
  final String? type;
  final int? id;
  final String? name;
  final String? region;
  final String? designation;
  final String? photoUrl;
  final String? state;
  final String? country;
  Author({
    this.type,
    this.id,
    this.name,
    this.region,
    this.designation,
    this.photoUrl,
    this.state,
    this.country,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      type: json["type"],
      id: json["id"],
      name: json["name"],
      region: json["region"],
      designation: json["designation"],
      photoUrl: json["photoUrl"],
      state: json["state"],
        country:json["country"],
    );
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "id": id,
    "name": name,
    "region": region,
    "designation": designation,
    "photoUrl": photoUrl,
    "state":state,
    "country":country,
  };
}
///-------------Feed Media
class FeedMedia {
  final int? id;
  final String? mediaType;
  final String? url;

  FeedMedia({
    this.id,
    this.mediaType,
    this.url,
  });

  factory FeedMedia.fromJson(Map<String, dynamic> json) {
    return FeedMedia(
      id: json["id"],
      mediaType: json["mediaType"],
      url: json["url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "mediaType": mediaType,
    "url": url,
  };
}
///-------Tagged
class Tagged {
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

  factory Tagged.fromJson(Map<String, dynamic> json) {
    return Tagged(
      type: json["type"],
      id: json["id"],
      name: json["name"],
      photoUrl: json["photoUrl"],
    );
  }

  /// Used while POST API
  Map<String, dynamic> toPostJson() => {
    "type": type,
    "id": id,
  };

  /// Optional full JSON
  Map<String, dynamic> toJson() => {
    "type": type,
    "id": id,
    "name": name,
    "photoUrl": photoUrl,
  };
}
///-------------------Of Search of politicians
class LeaderModel {
  final int id;
  final String name;
  final String designation;
  final String uniqueId;
  final String? image;
  final String? partyName;
  final int? partyId;
  final String status;
  final String region;

  LeaderModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.uniqueId,
    this.image,
    this.partyName,
    required this.partyId, required this.status, required this.region,
  });

  factory LeaderModel.fromJson(Map<String, dynamic> json) {
    return LeaderModel(
      id: json["politicianId"] ?? json["id"],
      name: json["name"],
      designation: json["designation"] ?? "",
      uniqueId: json["uniqueId"] ?? "",
      image: json["photoUrl"] ?? "",
      partyName: json['partyName'] ?? "",
      partyId: json['partyId'] ,
      region: json['region'] ?? "",
      status: json['status'] ?? "",
    );
  }

  LeaderModel copyWith({
    int? id,
    Object? image = _noChange,
    String? name,
    String? designation,
    String? uniqueId,
    int? partyId,
    String? region,
    String? status,
  }) {
    return LeaderModel(
      id: id ?? this.id,
      image: image == _noChange
          ? this.image
          : image as String?,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      uniqueId: uniqueId ?? this.uniqueId, partyId: partyId ?? this.partyId,
      region: region ?? this.region,
      status: status ?? this.status,
    );
  }

  static const _noChange = Object();

}
