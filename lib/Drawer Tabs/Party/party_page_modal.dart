import 'dart:convert';

class PartyProfileModel {
  final int? id;
  final String partyName;
  final String? generalSecretary;
  final String? president;
  final String? founded;
  final String? partySymbol;
  final String? partySymbolName;
  final String? founder;
  final String? state;
  final String? country;
  final String? uniqueCode;
  final String? headquarters;
  final String? officialWebsite;
  final String? info;
  final String? partyIdeologies;
  final String? visionMission;
  final List? bannerImages;
  final bool isHidden;
  const PartyProfileModel({
    this.id,
    this.partyName = '',
    this.generalSecretary = '',
    this.president = '',
    this.founded = '',
    this.partySymbol = '',
    this.partySymbolName = '',
    this.founder = '',
    this.state = '',
    this.country = '',
    this.uniqueCode = '',
    this.headquarters = '',
    this.officialWebsite = '',
    this.info = '',
    this.partyIdeologies = '',
    this.visionMission = '',
    this.bannerImages,
    this.isHidden=false,

  });

  PartyProfileModel copyWith({
    int? id,
    String? partyName,
    String? generalSecretary,
    String? president,
    String? founded,
    String? partySymbol,
    String? partySymbolName,
    String? founder,
    String? state,
    String? country,
    String? uniqueCode,
    String? headquarters,
    String? officialWebsite,
    String? info,
    String? partyIdeologies,
    String? visionMission,
    List? bannerImages,
    bool? isHidden,
  }) {
    return PartyProfileModel(
      id: id ?? this.id,
      partyName: partyName ?? this.partyName,
      generalSecretary: generalSecretary ?? this.generalSecretary,
      president: president ?? this.president,
      founded: founded ?? this.founded,
      partySymbol: partySymbol ?? this.partySymbol,
      partySymbolName: partySymbolName ?? this.partySymbolName,
      founder: founder ?? this.founder,
      state: state ?? this.state,
      country: country ?? this.country,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      headquarters: headquarters ?? this.headquarters,
      officialWebsite: officialWebsite ?? this.officialWebsite,
      info: info ?? this.info,
      partyIdeologies: partyIdeologies ?? this.partyIdeologies,
      visionMission: visionMission ?? this.visionMission,
      bannerImages: bannerImages ?? this.bannerImages,
      isHidden: isHidden??this.isHidden,
    );
  }

  factory PartyProfileModel.fromJson(Map<String, dynamic> json){
    return PartyProfileModel(
      id: json['id'] ?? 0,
      partyName: json['name'] ?? '',
      generalSecretary: json['generalSecretary'] ?? '',
      president: json['president'] != null
          ? json['president']['name'] as String?
          : '',
      founded: json['foundedOn'] ?? '',
      partySymbol: json['partySymbolUrl'] ?? '',
      partySymbolName: json['symbolName'] ?? '',
      founder: json['founder'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      uniqueCode: json['uniqueCode'] ?? '',
      headquarters: json['headquarters'] ?? '',
      officialWebsite: json['website'] ?? '',
      info: json['info'] ?? '',
      partyIdeologies: json['ideologies'] ?? '',
      visionMission: json['visionMission'] ?? '',
      bannerImages: json['bannerImages'] != null
          ? List<dynamic>.from(json['bannerImages'])
          : [],
      isHidden: json["hidden"]??false,
    );
  }

}

class SymbolModel {
  final String? ownerType;
  final int? ownerId;
  final List<String> partyLogo;
  final String? logoDescription;
  final bool? downloadEnabled;
  final int? id;

  const SymbolModel({
    this.ownerType,
    this.ownerId,
    this.partyLogo = const [],
    this.logoDescription,
    this.downloadEnabled=false,
    this.id,
  });

  SymbolModel copyWith({
    String? ownerType,
    int? ownerId,
    List<String>? partyLogo,
    String? logoDescription,
    bool? downloadEnabled,
  }) {
    return SymbolModel(
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      partyLogo: partyLogo ?? this.partyLogo,
      logoDescription: logoDescription ?? this.logoDescription,
      downloadEnabled: downloadEnabled ?? this.downloadEnabled,
    );
  }

  factory SymbolModel.fromJson(Map<String, dynamic> json){
    return SymbolModel(
      id: json['id'],
      ownerType: json['ownerType'] ?? '',
      ownerId: json['ownerId'] ?? 0,
      partyLogo: json['urls'] != null
          ? List<String>.from(json['urls'])
          : [],
      logoDescription: json['label'] ?? '',

      downloadEnabled: json['downloadable'] ?? false,
    );
  }

}

class JourneyModel {
  final int? id;
  final String? ownerType;
  final int? ownerId;
  final String title;
  final String year;
  final String description;
  final String? imagePath;

  const JourneyModel({
    this.id,
    this.ownerType,
    this.ownerId,
    required this.title,
    required this.year,
    required this.description,
    this.imagePath,
  });

  JourneyModel copyWith({
    int? id,
    String? ownerType,
    int? ownerId,
    String? title,
    String? year,
    String? description,
    Object? imagePath = _noChange,
  }) {
    return JourneyModel(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      year: year ?? this.year,
      description: description ?? this.description,
      imagePath: imagePath == _noChange
          ? this.imagePath
          : imagePath as String?,
    );
  }

  static const _noChange = Object();

  factory JourneyModel.fromJson(Map<String, dynamic>json){
    return JourneyModel(
      id: json['id'],
      ownerType: json['ownerType'],
      ownerId: json['ownerId'],
      title: json['title'] ?? '',
      year: json['year'].toString() ?? '',
      description: json['body'] ?? '',
      imagePath: json['mediaUrl'] ?? '',
    );
  }


}

class LeaderModel{
  final int? id;
  final int politicianId;
  final String? imagePath;
  final String name;
  final String designation;

  const LeaderModel({
    this.id,
    required this.politicianId,
    this.imagePath,
    required this.name,
    required this.designation,
  });
  factory LeaderModel.fromJson(Map<String, dynamic> json){
    return LeaderModel(
      id: json['json'],
      politicianId: json["politicianId"] ?? 0,
      imagePath: json["photoUrl"],
      name: json["name"] ?? "",
      designation: json["designation"] ?? "",
    );
  }
  LeaderModel copyWith({
    int? politicianId,
    Object? imagePath = _noChange,
    String? name,
    String? designation,
  }) {
    return LeaderModel(
      politicianId: politicianId ?? this.politicianId,
      imagePath: imagePath == _noChange
          ? this.imagePath
          : imagePath as String?,
      name: name ?? this.name,
      designation: designation ?? this.designation,
    );
  }

  static const _noChange = Object();
}

class LeaderGroupModel {
  final int? id;
  final String title;
  final List<LeaderModel> leaders;
  final double cropWidth;
  final double cropHeight;

  const LeaderGroupModel({
    this.id,
    required this.title,
    required this.leaders,
    required this.cropWidth,
    required this.cropHeight,
  });
  factory LeaderGroupModel.fromJson(Map<String, dynamic>json){
    return LeaderGroupModel(
      id: json['id'],
      title: json["title"] ?? "",
      leaders: (json["members"] as List<dynamic>? ?? [])
          .map(
            (e) => LeaderModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
      cropWidth: (json["cropWidth"] as num?)?.toDouble() ?? 0,
      cropHeight: (json["cropHeight"] as num?)?.toDouble() ?? 0,
    );
  }
  LeaderGroupModel copyWith({
    String? title,
    List<LeaderModel>? leaders,
    double? cropWidth,
    double? cropHeight,

  }) {
    return LeaderGroupModel(
      title: title ?? this.title,
      leaders: leaders ?? this.leaders,
      cropWidth: cropWidth ?? this.cropWidth,
      cropHeight: cropHeight ?? this.cropHeight,
    );
  }
}
class LeadershipGroupRequest{
  final String title;
  final double cropWidth;
  final double cropHeight;
  final List<int>politicianIds;
  LeadershipGroupRequest({
    required this.title,
    required this.cropWidth,
    required this.cropHeight,
    required this.politicianIds,
  });
  Map<String, dynamic>toJson(){
    return{
      "title":title,
      "cropWidth":cropWidth,
      "cropHeight": cropHeight,
      "politicianIds": politicianIds,
    };
  }
}
class LeadershipBatchRequest{
  final List<LeadershipGroupRequest>groups;
  LeadershipBatchRequest({
    required this.groups,
  });
  Map<String, dynamic> toJson(){
    return{
      "groups":groups.map((e)=>e.toJson()).toList(),
    };
  }
}
///--------------Added politicianId
class MemberDirectoryModel {
  final int politicianId;
  final String uniqueId;
  final String imagePath;
  final String personName;
  final String designation;
  final String region;
  final int? partyId;
  final DateTime lastUpdated;
  final String status;

  const MemberDirectoryModel({
    required this.politicianId,
    required this.uniqueId,
    required this.imagePath,
    required this.personName,
    required this.designation,
    required this.region,
    this.partyId,
    required this.lastUpdated,
    required this.status,
  });

  factory MemberDirectoryModel.fromJson(Map<String, dynamic>json){
    return MemberDirectoryModel(
      politicianId: json["id"]?? 0,
      uniqueId: json["uniqueId"] ?? "",
      imagePath: json["photoUrl"] ?? "",
      personName: json["name"] ?? "",
      designation:  json["designation"] ?? "",
      region:  json["region"] ?? "",
      partyId: json["partyId"],
      lastUpdated: DateTime.parse(json["lastUpdated"]),
      status:  json["status"] ?? "",
    );
  }

  MemberDirectoryModel copyWith({
    int? politicianId,
    String? uniqueId,
    String? imagePath,
    String? personName,
    String? designation,
    String? region,
    int?partyId,
    DateTime? lastUpdated,
    String? status,
  }) {
    return MemberDirectoryModel(
      politicianId: politicianId ?? this.politicianId,
      uniqueId: uniqueId ?? this.uniqueId,
      imagePath: imagePath ?? this.imagePath,
      personName: personName ?? this.personName,
      designation: designation ?? this.designation,
      region: region ?? this.region,
      partyId: partyId??this.partyId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
    );
  }
}

