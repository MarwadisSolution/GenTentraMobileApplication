
import 'package:dio/dio.dart';

import '../../Login Page/Refresh Token/refresh_token.dart';
import '../../Reusable Functions/reusable_functions.dart';

class PartyPageApis{
  final Dio _dio = apiClient;
  Future<List<dynamic>> fetchPartiesAlreadyFormed() async {
    // final items= [
    //   {
    //     "id": 11,
    //     "uuid": "606585ce-7004-499e-b0ab-7e56026b8eeb",
    //     "name": "Bharatiya Janata Party",
    //     "slug": "bjp",
    //     "foundedOn": "1980-04-06",
    //     "countryId": null,
    //     "stateId": null,
    //     "logoUrl": null,
    //     "coverUrl": null,
    //     "partySymbolUrl": "https://share.google/uNt9n2VWwBKSMqc8a",
    //     "manifesto": null,
    //     "website": "https://www.bjp.org",
    //     "generalSecretary": "B. L. Santhosh",
    //     "founder": "Atal Bihari Vajpayee, L. K. Advani",
    //     "uniqueCode": "BJP-IN-001",
    //     "headquarters": "6A, Deen Dayal Upadhyaya Marg, New Delhi",
    //     "info": "National political party of India.",
    //     "ideologies": "Integral humanism, conservatism, Hindu nationalism",
    //     "visionMission": "Sabka Saath, Sabka Vikas, Sabka Vishwas",
    //     "isVerified": false,
    //     "president": null,
    //     "bannerImages": [
    //       "https://picsum.photos/800/400",
    //       "https://picsum.photos/801/400",
    //     ],
    //     "createdAt": "2026-06-18T15:25:09.925896Z"
    //   },
    //   {
    //     "id": 9,
    //     "uuid": "c40b50e1-9317-4722-8aa0-c76270d864f0",
    //     "name": "Nationalist Party",
    //     "slug": "nationalist-party",
    //     "foundedOn": "2026-06-17",
    //     "countryId": null,
    //     "stateId": null,
    //     "logoUrl": null,
    //     "coverUrl": null,
    //     "partySymbolUrl": null,
    //     "manifesto": "Bharat Mata Ki Jai",
    //     "website": "https://asdf.org",
    //     "generalSecretary": null,
    //     "founder": null,
    //     "uniqueCode": null,
    //     "headquarters": null,
    //     "info": null,
    //     "ideologies": null,
    //     "visionMission": null,
    //     "isVerified": false,
    //     "president": null,
    //     "bannerImages": [],
    //     "createdAt": "2026-06-17T15:09:47.579006Z"
    //   },
    //   {
    //     "id": 8,
    //     "uuid": "22e0923d-801f-45b7-8d2b-cd72b4b6703b",
    //     "name": "Riddesh",
    //     "slug": "riddesh",
    //     "foundedOn": "2024-01-15",
    //     "countryId": null,
    //     "stateId": null,
    //     "logoUrl": null,
    //     "coverUrl": null,
    //     "partySymbolUrl": null,
    //     "manifesto": "this is thaliva",
    //     "website": "https://civicfront.org",
    //     "generalSecretary": null,
    //     "founder": null,
    //     "uniqueCode": null,
    //     "headquarters": null,
    //     "info": null,
    //     "ideologies": null,
    //     "visionMission": null,
    //     "isVerified": false,
    //     "president": null,
    //     "bannerImages": [],
    //     "createdAt": "2026-06-15T18:41:07.736705Z"
    //   }
    // ];
    // return items
    //     // .map((e) => PartyProfileModel.fromJson(e))
    //     .toList();


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
  Future<List<dynamic>>fetchSymbolDetails(int partyId)async{

    try {
      final response = await _dio.get(
        "$api/api/v1/civic/symbols",
        queryParameters: {
          "ownerType": "PARTY",
          "ownerId": partyId,
          "kind": "ELECTION",
        },

      );
      if (response.statusCode == 200) {
        print("Data");
        print(response.data);
        print(response.data["data"]);
        print(response.data["data"].runtimeType);
        // final items =
        // response.data['data'] as List;

throw Exception("sdad");
       // return items.toList();
      }
      print(response.data);
     // print(response.data.runtimeType);
      //print(response.data['data'].runtimeType);
      throw Exception(
        "Error : ${response.statusCode}",
      );
    } on DioException catch (e) {
      throw Exception("Error: ${e.message}");
    }
  }
  Future<List<dynamic>>fetchTheJourney( int ownerId)async{

    try{
      final response=await _dio.get("$api/api/v1/profile/journey?ownerType=PARTY&ownerId=$ownerId",

      );
      if(response.statusCode==200 || response.statusCode==201){
        final items=response.data['data']['items'] as List;
        return items.toList();
      }
      throw Exception(
        "Error : ${response.statusCode}",
      );
    }
    on DioException catch(e){
      throw Exception("$e");
    }
  }
}