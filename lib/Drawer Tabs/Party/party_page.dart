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
  final apiService = PartyPageApis();

  @override
  void initState() {
    super.initState();
    partiesFuture = apiService.fetchPartiesAlreadyFormed();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery
        .of(context)
        .size
        .width;
    final h = MediaQuery
        .of(context)
        .size
        .height;
    final isMobile = w < 600;
    final isTablet = w >= 600 && w < 900;
    final isDesktop = w >= 900;

    final gridCount = isDesktop
        ? 6
        : isTablet
        ? 5
        : 3;
    return Scaffold(
      body: CustomScrollView(
       // physics: NeverScrollableScrollPhysics(),
          slivers: [
            ReusableSliverAppBar(

              title: "PARTY'S", automaticallyImplyLeading: true, height: h*0.07),
            SliverSections(
              child: Stack(
                children: [
                  Container(
                    height: h * 0.08,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: GradientColorsForBellowAppbar.gradientBelowAppbar,
                    ),
                  ),
                  Container(
                      // constraints: BoxConstraints(
                      //   minHeight: MediaQuery
                      //       .of(context)
                      //       .size
                      //       .height,
                      // ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25))
                      ),
                      child: FutureBuilder<List<dynamic>>(
                        future: partiesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorScheme.of(context).onSurface,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        snapshot.error.toString().contains(
                                            "has a status code of 530")
                                            ? "Please contact the owner"
                                            : snapshot.error.toString().contains(
                                            "The connection errored") ?
                                        "You are offline"
                                            : snapshot.error.toString()),
                                  )
                              );
                            });

                            return Center(
                              child: Text(
                                "Something went wrong", style: TextStyle(
                                  color: ColorScheme
                                      .of(context)
                                      .onSurface),),
                            );
                          }

                          final parties = snapshot.data ?? [];

                          return Padding(
                            padding:  EdgeInsets.only(
                                right: MediaQuery.of(context).size.width*0.025,
                                left: MediaQuery.of(context).size.width*0.025,
                                top: MediaQuery.of(context).size.height*0.025),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding:  EdgeInsets.all(MediaQuery.of(context).size.height*0.005),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridCount,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: parties.length,
                              itemBuilder: (context, index) {
                                final party = parties[index];
                                return InkWell(

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PartyFetchedData(
                                              partyData: party,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          // border: Border.all(
                                          //   //color: Color(0xFFD6D6D6),
                                          //   width: 1,
                                          // ),
                                        ),
                                        child: CircleAvatar(
                                          radius:  MediaQuery.of(context).size.width*0.11,
                                          backgroundColor: Colors.white,
                                          child: ClipOval(
                                            child: SizedBox.expand(
                                              child:  (party["partySymbolUrl"] != null &&
                                                  (party["partySymbolUrl"] as String)
                                                      .isNotEmpty)
                                                  ? buildImageWidget(
                                                party["partySymbolUrl"],
                                                fit: BoxFit.contain,
                                              )
                                                  : Icon(
                                                Icons.image,
                                                color: ColorScheme
                                                    .of(context)
                                                    .onSurface,
                                              ),
                                            ),
                                          )

                                        ),
                                      ),
                                      SizedBox(height: h*0.01),
                                      Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        party["name"] ?? "",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),

                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                  ),
                ],
              ),
            ),
      SliverToBoxAdapter(
        child: SizedBox(height: h*0.045,),
      )
          ]
      ),
    );
  }
}
