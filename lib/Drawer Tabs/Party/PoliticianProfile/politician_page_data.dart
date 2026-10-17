import 'package:flutter/material.dart';
import 'politician_profile_screen.dart';

// Barrel exports so other files can import just this file to access the whole module
export 'politician_model.dart';
export 'politician_profile_bloc.dart';
export 'politician_profile_repository.dart';
export 'politician_profile_screen.dart';

class PoliticianPageData {
  // Routes & Navigation
  static const String routeName = '/politician-profile';

  static Future<T?> navigateTo<T>(
    BuildContext context, {
    required int politicianId,
    String? photoUrl,
    String? name,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => PoliticianProfileScreen(
          politicianId: politicianId,
          photoUrl: photoUrl,
          name: name,
        ),
      ),
    );
  }

  // Header & Stats
  static final view = "VIEWS";
  static final followers = "FOLLOWERS";
  static final following = "FOLLOWING";
  static final follow = "Follow";
  static final designationPrefix = "Designation - ";

  // Tabs
  static final info = "INFO";
  static final journey = "JOURNEY";
  static final feed = "FEED";
  static final development = "DEVELOPMENT";

  // Info Tab Field Labels
  static final gender = "GENDER";
  static final dobAge = "DOB / AGE";
  static final birthPlace = "BIRTH PLACE";
  static final politicalParty = "POLITICAL PARTY";
  static final constituency = "CONSTITUENCY";
  static final address = "ADDRESS";

  // SVG Icons
  static final arrow = "Assets/arrow.svg";
  static final favoriteIcon = "Assets/PartyPage/favourite.svg";
  static final genderIcon = "Assets/LeadershipPage/Info/Gender.svg";
  static final dobIcon = "Assets/LeadershipPage/Info/DoB.svg";
  static final birthPlaceIcon = "Assets/LeadershipPage/Info/BirthPlace.svg";
  static final politicalPartyIcon = "Assets/LeadershipPage/Info/PoliticalParty.svg";
  static final constituencyIcon = "Assets/LeadershipPage/Info/Constituency.svg";
  static final addressIcon = "Assets/LeadershipPage/Info/Address.svg";
  static final educationIcon = "Assets/LeadershipPage/Info/Education.svg";
}
