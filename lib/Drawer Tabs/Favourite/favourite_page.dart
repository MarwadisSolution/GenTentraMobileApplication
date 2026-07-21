import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_fetched_data.dart' show PartyFetchedData;
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart' show PartyPageApis;
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../Reusable Functions/reusable_functions.dart';
import 'favourite_page_caching.dart';
import 'favourite_page_modal.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final FavouritePageCaching cache = FavouritePageCaching();

  late Future<List<FavouritePageModal>> favouriteFuture;
  final apiService = PartyPageApis();
  @override
  void initState() {
    super.initState();
    favouriteFuture = cache.getFavourites();
  }

  Future<void> refreshFavourite() async {
    setState(() {
      favouriteFuture = cache.getFavourites();
    });
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
            ReusableSliverAppBar(
              title: "My Favourite",
              automaticallyImplyLeading: true,
              height: 60,
            ),
            SliverSections(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    right: MediaQuery.of(context).size.width * 0.04,
                    left: MediaQuery.of(context).size.width * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Favorite Party’s",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.textScalerOf(context).scale(15),
                        ),
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      FutureBuilder<List<FavouritePageModal>>(
                        future: favouriteFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: ColorScheme
                                    .of(context)
                                    .onSurface,
                              ),
                            );
                          }
                          final favourites = snapshot.data ?? [];
                          if (favourites.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text("No favourite parties found."),
                              ),
                            );
                          }
                          return GridView.builder(
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: favourites.length,
                              itemBuilder: (context, index) {
                                final party = favourites[index];
                                return InkWell(
                                  onTap: () async {
                                    try {
                                      final partyData = await apiService.fetchPartySingleWithId(
                                        party.id,
                                      );

                                      if (!mounted) return;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PartyFetchedData(
                                            partyData: partyData,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Failed to load party details"),
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFD6D6D6),
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.white,
                                          child: party.partySymbolUrl.isNotEmpty
                                              ? buildImageWidget(
                                            party.partySymbolUrl,
                                            width: 45,
                                            height: 45,
                                            fit: BoxFit.cover,
                                          )
                                              : Icon(
                                            Icons.image,
                                            color: ColorScheme
                                                .of(context)
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        party.name,
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
