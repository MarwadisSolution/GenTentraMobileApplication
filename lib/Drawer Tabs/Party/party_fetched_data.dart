import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/reusable_functions.dart';
class PartyFetchedData extends StatefulWidget {
  final Map<String, dynamic> partyData;
  const PartyFetchedData({super.key,required this.partyData,});

  @override
  State<PartyFetchedData> createState() => _PartyFetchedDataState();
}

class _PartyFetchedDataState extends State<PartyFetchedData> {
  final apiService=PartyPageApis();
  late Future<Map<String, dynamic>> partyFullFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    partyFullFuture = apiService.fetchPartySingleWithIdFull(
      widget.partyData["id"],

    );

  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Color(0xFFebebeb),
        body: Stack(
          children: [
            BannerSection(
              partyData: widget.partyData,
            ),


            DraggableScrollableSheet(
              initialChildSize: 0.25,
              minChildSize: 0.25,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child:ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      PartyDetailsSection(
                        partyData: widget.partyData,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -10), // move 8 pixels upward
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.01,
                          color: const Color(0xFF000000).withOpacity(0.08),
                        ),
                      ),
                       SizedBox(height: 0),

                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: partyFullFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: CircularProgressIndicator(
                                      color: ColorScheme.of(context).onSurface,
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(snapshot.error.toString()),
                                );
                              }

                              final fullData = snapshot.data!;

                              final PartyProfileModel party =
                              fullData['party'] as PartyProfileModel;

                              final SymbolModel symbol =
                              fullData['symbol'] as SymbolModel;

                              final List<JourneyModel> journey =
                              fullData['journey'] as List<JourneyModel>;

                              final List<LeaderGroupModel> leaders =
                              fullData['leaderGroup'] as List<LeaderGroupModel>;
                              final List<MemberDirectoryModel> members =
                              fullData['members'] as List<MemberDirectoryModel>;

                              final Map<String, List<MemberDirectoryModel>> membersByRegion =
                              fullData['membersByRegion'] as Map<String, List<MemberDirectoryModel>>;
                              return PartyDetailsSectionByFields(

                                party: party,
                                symbol: symbol,
                                journeys: journey, leaders: leaders,
                                members: members,
                                membersByRegion: membersByRegion,
                                scrollController: scrollController,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
