import '../../party_page_modal.dart';

class PoliticianPartyModel {
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? partyInitial;

  const PoliticianPartyModel({
    this.id,
    this.name,
    this.imageUrl,
    this.partyInitial,
  });

  factory PoliticianPartyModel.fromJson(Map<String, dynamic> json) {
    return PoliticianPartyModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      imageUrl:
          (json['imageUrl'] ?? json['photoUrl'] ?? json['symbolUrl'])
              as String?,
      partyInitial: json['partyInitial'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'partyInitial': partyInitial,
    };
  }
}

class PoliticianModel {
  final int id;
  final String? photoUrl;
  final String? title;
  final String name;
  final String? middleName;
  final String? surname;
  final String? gender;
  final String? dateOfBirth;
  final String? birthPlace;
  final String? education;
  final String designation;
  final String? position;
  final String? region;
  final String? constituency;
  final String? state;
  final String? info;
  final String? address;
  final PoliticianPartyModel? party;
  final List<JourneyModel> journeys;
  final int? viewCount;
  final int? followerCount;
  final bool? isFollowing;
  final bool? isFavorite;

  const PoliticianModel({
    required this.id,
    this.photoUrl,
    this.title,
    this.name = '',
    this.middleName,
    this.surname,
    this.gender,
    this.dateOfBirth,
    this.birthPlace,
    this.education,
    this.designation = '',
    this.position,
    this.region,
    this.constituency,
    this.state,
    this.info,
    this.address,
    this.party,
    this.journeys = const [],
    this.viewCount,
    this.followerCount,
    this.isFollowing,
    this.isFavorite,
  });

  String get displayName {
    final List<String> parts = [];
    if (title != null && title!.trim().isNotEmpty) {
      parts.add(title!.trim());
    }
    if (name.trim().isNotEmpty) {
      parts.add(name.trim());
    }
    if (middleName != null &&
        middleName!.trim().isNotEmpty &&
        !name.toLowerCase().contains(middleName!.trim().toLowerCase())) {
      parts.add(middleName!.trim());
    }
    if (surname != null &&
        surname!.trim().isNotEmpty &&
        !name.toLowerCase().contains(surname!.trim().toLowerCase())) {
      parts.add(surname!.trim());
    }
    return parts.isNotEmpty ? parts.join(' ') : 'Politician Profile';
  }

  factory PoliticianModel.fromJson(Map<String, dynamic> json) {
    List<JourneyModel> journeyList = [];
    final rawJourneys = json['journeys'] ?? json['journey'];
    if (rawJourneys != null && rawJourneys is List) {
      journeyList = rawJourneys
          .map(
            (e) => JourneyModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }

    PoliticianPartyModel? partyModel;
    if (json['party'] != null && json['party'] is Map) {
      partyModel = PoliticianPartyModel.fromJson(
        Map<String, dynamic>.from(json['party'] as Map),
      );
    }

    return PoliticianModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      photoUrl: json['photoUrl'] as String?,
      title: json['title'] as String?,
      name: json['name'] as String? ?? '',
      middleName: json['middleName'] as String?,
      surname: json['surname'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth']?.toString(),
      birthPlace: json['birthPlace'] as String?,
      education: json['education'] as String?,
      designation: json['designation'] as String? ?? '',
      position: json['position'] as String?,
      region: json['region'] as String?,
      constituency: json['constituency'] as String?,
      state: json['state'] as String?,
      info: json['info'] as String?,
      address: json['address'] as String?,
      party: partyModel,
      journeys: journeyList,
      // Parse stats with fallbacks for different API response key names (reference from backend stats endpoints)
      viewCount: ((json['viewCount'] ?? json['views'] ?? json['view_count']) as num?)?.toInt(),
      followerCount: ((json['followerCount'] ?? json['followers'] ?? json['follower_count']) as num?)?.toInt(),
      isFollowing: json['isFollowing'] as bool?,
      isFavorite: json['isFavorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'title': title,
      'name': name,
      'middleName': middleName,
      'surname': surname,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'birthPlace': birthPlace,
      'education': education,
      'designation': designation,
      'position': position,
      'region': region,
      'constituency': constituency,
      'state': state,
      'info': info,
      'address': address,
      'party': party?.toJson(),
      'journeys': journeys
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'year': e.year,
              'body': e.description,
              'mediaUrl': e.imagePath,
            },
          )
          .toList(),
      'viewCount': viewCount,
      'followerCount': followerCount,
      'isFollowing': isFollowing,
      'isFavorite': isFavorite,
    };
  }

  PoliticianModel copyWith({
    int? id,
    String? photoUrl,
    String? title,
    String? name,
    String? middleName,
    String? surname,
    String? gender,
    String? dateOfBirth,
    String? birthPlace,
    String? education,
    String? designation,
    String? position,
    String? region,
    String? constituency,
    String? state,
    String? info,
    String? address,
    PoliticianPartyModel? party,
    List<JourneyModel>? journeys,
    int? viewCount,
    int? followerCount,
    bool? isFollowing,
    bool? isFavorite,
  }) {
    return PoliticianModel(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      title: title ?? this.title,
      name: name ?? this.name,
      middleName: middleName ?? this.middleName,
      surname: surname ?? this.surname,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      birthPlace: birthPlace ?? this.birthPlace,
      education: education ?? this.education,
      designation: designation ?? this.designation,
      position: position ?? this.position,
      region: region ?? this.region,
      constituency: constituency ?? this.constituency,
      state: state ?? this.state,
      info: info ?? this.info,
      address: address ?? this.address,
      party: party ?? this.party,
      journeys: journeys ?? this.journeys,
      viewCount: viewCount ?? this.viewCount,
      followerCount: followerCount ?? this.followerCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
