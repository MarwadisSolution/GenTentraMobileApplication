import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/reusable_functions.dart';
class PartyFetchedData extends StatefulWidget {
  final Map<String, dynamic> partyData;
  const PartyFetchedData({super.key,required this.partyData,});

  @override
  State<PartyFetchedData> createState() => _PartyFetchedDataState();
}

class _PartyFetchedDataState extends State<PartyFetchedData> {
  final apiService=PartyPageApis();
  late Future<List<dynamic>> symbolFuture;
late Future<List<dynamic>>journeyFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    symbolFuture=apiService.fetchSymbolDetails(widget.partyData["id"]);
    journeyFuture=apiService.fetchTheJourney(widget.partyData['id']);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFebebeb),
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: BannerSection(
                partyData: widget.partyData,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(24),
                            topRight:Radius.circular(24) )
                    ),
                    child: PartyDetailsSection(partyData: widget.partyData,)),
             SizedBox(height: 6,),
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,

                    ),
                    child:FutureBuilder<List<Object?>>(
                      future: Future.wait([
                        symbolFuture,
                        journeyFuture,
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }

                        final symbolList = snapshot.data![0] as List<dynamic>;
                        final journeyList = snapshot.data![1] as List<dynamic>;

                        return PartyDetailsSectionByFields(
                          partyData: widget.partyData,
                          symbolData: symbolList.isNotEmpty ? symbolList.first : {},
                          journeyData: {
                            "items": journeyList,
                          },
                        );
                      },
                    ),
                ),
              ],
            ),
          ),

      ],
      ),
    );
  }
}
