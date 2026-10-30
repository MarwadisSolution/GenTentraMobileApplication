class PartyProfileModel {
  final int? id;
  final String partyName;
  final String? generalSecretary;
  final String? president;
  final String? founded;
  final String? partyInitials;
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
  final bool? isHidden;
  final int? viewCount;
  const PartyProfileModel({
    this.id,
    this.partyName = '',
    this.generalSecretary = '',
    this.president = '',
    this.founded = '',
    this.partyInitials='',
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
    this.isHidden,
    this.viewCount,
  });

  PartyProfileModel copyWith({
    int? id,
    String? partyName,
    String? generalSecretary,
    String? president,
    String? founded,
    String?partyInitials,
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
    int? viewCount,
  }) {
    return PartyProfileModel(
      id: id ?? this.id,
      partyName: partyName ?? this.partyName,
      generalSecretary: generalSecretary ?? this.generalSecretary,
      president: president ?? this.president,
      founded: founded ?? this.founded,
      partyInitials: partyInitials??this.partyInitials,
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
      viewCount: viewCount??this.viewCount,
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
      partyInitials: json['partyInitial']??'',
      partySymbol: (json['partySymbolUrl'] ?? json['symbolUrl'] ?? json['partySymbol'] ?? json['symbol'] ?? json['imageUrl'] ?? json['photoUrl'] ?? '').toString(),
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
      viewCount: json["viewCount"]??0///------------------Baki hai
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
    List<String> logos = [];
    if (json['urls'] != null && json['urls'] is List) {
      logos = (json['urls'] as List).map((e) => e.toString()).toList();
    } else if (json['partyLogo'] != null && json['partyLogo'] is List) {
      logos = (json['partyLogo'] as List).map((e) => e.toString()).toList();
    } else if (json['images'] != null && json['images'] is List) {
      logos = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['symbolUrl'] != null && json['symbolUrl'].toString().isNotEmpty) {
      logos = [json['symbolUrl'].toString()];
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      logos = [json['imageUrl'].toString()];
    }

    return SymbolModel(
      id: json['id'],
      ownerType: json['ownerType'] ?? '',
      ownerId: json['ownerId'] ?? 0,
      partyLogo: logos,
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

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id'],
      ownerType: json['ownerType'],
      ownerId: json['ownerId'],
      title: json['title']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      description: (json['body'] ?? json['description'] ?? '').toString(),
      imagePath: (json['mediaUrl'] ?? json['imagePath'] ?? json['imageUrl'] ?? json['photoUrl'] ?? json['photo'] ?? json['image'] ?? '').toString(),
    );
  }


}

class LeaderModel{
  final int? id;
  final int politicianId;
  final String? imagePath;
  final String name;
  final String? surname;
  final String designation;

  const LeaderModel({
    this.id,
    required this.politicianId,
    this.imagePath,
    required this.name,
    this.surname,
    required this.designation,
  });
  factory LeaderModel.fromJson(Map<String, dynamic> json){
    final rawImg = json["photoUrl"] ?? json["imageUrl"] ?? json["imagePath"] ?? json["mediaUrl"] ?? json["photo"] ?? json["image"];
    return LeaderModel(
      id: json['id'] ?? json['json'],
      politicianId: (json["politicianId"] ?? json["id"] ?? 0 as num).toInt(),
      imagePath: rawImg?.toString(),
      name: json["name"] ?? "",
      surname: (json["surname"] ?? json["lastName"])?.toString(),
      designation: json["designation"] ?? "",
    );
  }
  LeaderModel copyWith({
    int? politicianId,
    Object? imagePath = _noChange,
    String? name,
    String? surname,
    String? designation,
  }) {
    return LeaderModel(
      politicianId: politicianId ?? this.politicianId,
      imagePath: imagePath == _noChange
          ? this.imagePath
          : imagePath as String?,
      name: name ?? this.name,
      surname: surname ?? this.surname,
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
      leaders: (((json["members"] ?? json["leaders"])) as List<dynamic>? ?? [])
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
  final String? surname;
  final String designation;
  final String region;
  final String? state;
  final int? partyId;
  final DateTime lastUpdated;
  final String status;

  const MemberDirectoryModel({
    required this.politicianId,
    required this.uniqueId,
    required this.imagePath,
    required this.personName,
    this.surname,
    required this.designation,
    required this.region,
    this.state,
    this.partyId,
    required this.lastUpdated,
    required this.status,
  });
  factory MemberDirectoryModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultState,
  }) {
    final stateVal = (json["state"] ?? json["stateName"] ?? defaultState)?.toString();
    final rawImg = json["photoUrl"] ?? json["imageUrl"] ?? json["imagePath"] ?? json["mediaUrl"] ?? json["photo"] ?? json["image"];
    DateTime parsedDate;
    try {
      parsedDate = json["lastUpdated"] != null
          ? (DateTime.tryParse(json["lastUpdated"].toString()) ?? DateTime.now())
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return MemberDirectoryModel(
      politicianId: (json["id"] ?? json["politicianId"] ?? 0 as num).toInt(),
      uniqueId: (json["uniqueId"] ?? "").toString(),
      imagePath: (rawImg ?? "").toString(),
      personName: (json["name"] ?? json["personName"] ?? "").toString(),
      surname: (json["surname"] ?? json["lastName"])?.toString(),
      designation: (json["designation"] ?? "").toString(),
      region: (json["region"] ?? "").toString(),
      state: stateVal,
      partyId: json["partyId"] != null ? (json["partyId"] as num).toInt() : null,
      lastUpdated: parsedDate,
      status: (json["status"] ?? "").toString(),
    );
  }

  MemberDirectoryModel copyWith({
    int? politicianId,
    String? uniqueId,
    String? imagePath,
    String? personName,
    String? surname,
    String? designation,
    String? region,
    String? state,
    int?partyId,
    DateTime? lastUpdated,
    String? status,
  }) {
    return MemberDirectoryModel(
      politicianId: politicianId ?? this.politicianId,
      uniqueId: uniqueId ?? this.uniqueId,
      imagePath: imagePath ?? this.imagePath,
      personName: personName ?? this.personName,
      surname: surname ?? this.surname,
      designation: designation ?? this.designation,
      region: region ?? this.region,
      state: state ?? this.state,
      partyId: partyId??this.partyId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
    );
  }
}

