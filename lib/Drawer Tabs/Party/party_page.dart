import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_fetched_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../Reusable Functions/reusable_functions.dart';
class PartyPage extends StatefulWidget {
  const PartyPage({super.key});

  @override
  State<PartyPage> createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  late Future<List<dynamic>> partiesFuture;
final apiService=PartyPageApis();
  @override
  void initState() {
    super.initState();
    partiesFuture = apiService.fetchPartiesAlreadyFormed();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: GradientColorsForBellowAppbar.gradientBelowAppbar,
        ),
        child: CustomScrollView(
          slivers: [
            ReusableSliverAppBar(title: "PARTY'S",automaticallyImplyLeading: true,height: 60,),
            SliverSections(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight:Radius.circular(20) )
                ),
                child:   FutureBuilder<List<dynamic>>(
                    future: partiesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      }

                      final parties = snapshot.data ?? [];

                      return  GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: parties.length,
                        itemBuilder: (context, index) {
                          final party = parties[index];
                          print("Starts");
                          print(party);
                          print("Linkk-- ${party["partySymbolUrl"]}");
                          return  InkWell(

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PartyFetchedData(
                                    partyData: party,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: (party["partySymbolUrl"] != null &&
                                      (party["partySymbolUrl"] as String).isNotEmpty)
                                      ? NetworkImage(
                                    (party["partySymbolUrl"] as String).startsWith("/api/")
                                        ? "$api${party["partySymbolUrl"]}"
                                        : party["partySymbolUrl"],
                                  )
                                      : null,
                                  child: (party["partySymbolUrl"] == null ||
                                      (party["partySymbolUrl"] as String).isEmpty)
                                      ? const Icon(Icons.image,color: Colors.yellow,)
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  party["name"] ?? "",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
              ),
            ),
        ]
        ),
      ),
    );
  }
}
