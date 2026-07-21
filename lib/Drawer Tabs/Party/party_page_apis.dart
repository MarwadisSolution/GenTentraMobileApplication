
import 'package:dio/dio.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';

import '../../Login Page/Refresh Token/refresh_token.dart';
import '../../Reusable Functions/reusable_functions.dart';

class PartyPageApis{
  final Dio _dio = apiClient;
  Future<List<dynamic>> fetchPartiesAlreadyFormed() async {

    try {
      final response = await _dio.get(
        "$api/api/v1/profile/parties",
      );
      if (response.statusCode == 200) {
        final items = response.data['data']['items'] as List;

        return items.toList();
      }

      throw Exception(
        "Error : ${response.statusCode}",
      );
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<Map<String,dynamic>> fetchPartySingleWithIdFull(int id) async {
    try {
      print(id);
      final response = await _dio.get(
        "$api/api/v1/profile/parties/$id/full",
      );

      print(response);

      if (response.statusCode == 200|| response.statusCode==201) {

        final fullParty = response.data['data'];
        final partyDetails = PartyProfileModel.fromJson(fullParty['party']);
        SymbolModel symbol = SymbolModel();
        List<JourneyModel> journey = [];
        List<LeaderGroupModel> leaderGroup = [];
        List<MemberDirectoryModel> memberDirectory = [];
        if(fullParty['symbols'].isNotEmpty){
          symbol = SymbolModel.fromJson(fullParty['symbols'][0]);
        }

        if(fullParty['journeys'].isNotEmpty){
          journey = (fullParty['journeys'] as List? ?? []).map(
                (e) => JourneyModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
              .toList();
        }

        if(fullParty['leadershipGroups'].isNotEmpty){
          leaderGroup = (fullParty['leadershipGroups'] as List? ?? []).map(
                (e) => LeaderGroupModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
              .toList();
        }

        if(fullParty['politicians'].isNotEmpty){
          memberDirectory = (fullParty['politicians'] as List? ?? []).map(
                (e) => MemberDirectoryModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
              .toList();
        }
        print('Leadership:- ${fullParty['leadershipGroups']}');
        return {
          'party':partyDetails,
          'symbol':symbol,
          'journey':journey,
          'leaderGroup':leaderGroup,
          'members':memberDirectory
        };
      }

      throw Exception(
        "Error : ${response.statusCode}",
      );
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
  ///-------------Of after doing caching
  Future<Map<String, dynamic>> fetchPartySingleWithId(int id) async {
    try {
      final response = await _dio.get(
        "$api/api/v1/profile/parties/$id",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data["data"]);
      }

      throw Exception("Error : ${response.statusCode}");
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
  
  
  ///-------------------View Apis
  Future<void>viewCountIncreament(String type,int partyId)async{
    try{
      final response=await _dio.post("$api/api/v1/stats/views/$type/$partyId");
      print("View");
print(response);
    }
    catch(e){
      print("Error in viewing:- $e");
    }
  }
  Future<int>getViewCount(String type,int partyId)async{
    try{
      final response=await _dio.get("$api/api/v1/stats/views/$type/$partyId");
      if(response.statusCode==200 || response.statusCode==201){
        return response.data["data"]["viewCount"];
      }
      else{
        return 100;
      }
    }
    catch(e){
      return 100;
    }
  }
  ///----------------Follow
  Future<int>getFollowCount(String type,int partyId)async{
    try{
      final response=await _dio.get("$api/api/v1/social/counts/$type/$partyId");
      if(response.statusCode==200 || response.statusCode==201){
        return response.data["data"]["followers"];
      }
      else{
        return 100;
      }
    }
    catch(e){
      return 100;
    }
  }
  Future<bool>followParty(String type, int partyId)async{
    try{
      final response=await _dio.post("$api/api/v1/social/follow",
      data: {
        "followeeType": "$type",
        "followeeId":partyId,
      },
      );
      if(response.statusCode==200 || response.statusCode==201){
        return true;
      }
      return false;
    }
        catch(e){
      print(e);
      return false;

        }
  }
  Future<bool>deleteFollowing(String type, int partyId)async{
    try{
      final response=await _dio.delete("$api/api/v1/social/follow/$type/$partyId");
      if(response.statusCode==200 || response.statusCode==201){
        return true;
      }
      else return false;
    }
        catch(e){
      print(e);
      return false;
        }
  }
  Future<List<dynamic>>iFollowParty()async{
    try{
      final response=await _dio.get("$api/api/v1/social/following",);
      if(response.statusCode==200 || response.statusCode==201){
        print(response.data["data"].runtimeType);
        return response.data["data"];
      }
      else return ["Error"];
    }
        catch(e){
      print("Follower Error- $e");
      return ["Error"];

        }
  }

}