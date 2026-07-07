import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/journey_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import 'Tabs/info_tab.dart';
import 'Tabs/symbol_tab.dart';

class BannerSection extends StatefulWidget {
  final Map<String, dynamic> partyData;

  const BannerSection({super.key, required this.partyData});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List banners = widget.partyData["bannerImages"] as List? ?? [];

    return Stack(
      children: [
        /// Banner Images
        SizedBox(
          height: 350,
          width: double.infinity,
          child: banners.isEmpty
              ? Container(
                  //color: Colors.red,
                  child: const Center(
                    child: Icon(Icons.image, size: 60, color: Colors.grey),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      banners[index].startsWith("/api/")
                          ? "$api${banners[index]}"
                          : banners[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.white,
                          child: const Center(
                            child: Icon(Icons.broken_image),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),

        if (banners.length > 1)
          Positioned(
            top: 320,
            left: 170,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (index) {
                final bool isSelected = currentIndex == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? GradientColors.primaryGradient
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                );
              }),
            ),
          ),

        /// Party Symbol
      ],
    );
  }
}

class PartyDetailsSection extends StatefulWidget {
  final Map<String, dynamic> partyData;

  const PartyDetailsSection({super.key, required this.partyData});

  @override
  State<PartyDetailsSection> createState() => _PartyDetailsSectionState();
}

class _PartyDetailsSectionState extends State<PartyDetailsSection> {
  bool following=false;
  bool favorite=false;
  @override
  Widget build(BuildContext context) {
print("First");
    return Container(
      padding: const EdgeInsets.only(
        top: 20, // Space for floating symbol
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: (widget.partyData["partySymbolUrl"] != null &&
                      (widget.partyData["partySymbolUrl"] as String).isNotEmpty)
                      ? DecorationImage(
                    image: NetworkImage(
                      (widget.partyData["partySymbolUrl"] as String).startsWith("/api/")
                          ? "$api${widget.partyData["partySymbolUrl"]}"
                          : widget.partyData["partySymbolUrl"],
                    ),
                    fit: BoxFit.contain, // or BoxFit.contain
                  )
                      : null,
                  color: Colors.grey.shade200,
                ),
                child: (widget.partyData["partySymbolUrl"] == null ||
                    (widget.partyData["partySymbolUrl"] as String).isEmpty)
                    ? const Icon(
                  Icons.image,
                  color: Colors.yellow,
                  size: 35,
                )
                    : null,
              ),

              SizedBox(width: MediaQuery.of(context).size.width * 0.06),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.partyData["name"] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.25,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Headquarters - ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.25,
                            color: Color(0xFF666666),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.partyData["headquarters"] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.25,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PartyPageData.view,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        letterSpacing: 0.22,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Text(
                      "250M",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.3,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PartyPageData.followers,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        letterSpacing: 0.22,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Text(
                      "19M",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.3,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                InkWell(
                  onTap: () {
                    following=!following;
                    setState(() {});
                  },
                  child: Container(
                    constraints: BoxConstraints(minHeight: 37, minWidth: 127),
                    decoration: BoxDecoration(
                      color: following?null:Color(0xFF666666),
                      gradient:following? GradientColors.primaryGradient:null,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: Center(
                      child: Text(
                        PartyPageData.following,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.37,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
              Padding(

                padding: EdgeInsetsGeometry.only(top: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      favorite = !favorite;
                    });
                  },
                  child: SvgPicture.asset(
                    PartyPageData.favoriteIcon,
                    color: favorite ? null : const Color(0xFF666666),
                  ),
                ),
              )
              ],
            ),
          ),

        ],
      ),
    );
  }


}
// Widget statTile({required String title, required String value}) {
//   return Column(
//     children: [
//       Text(
//         value,
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       const SizedBox(height: 4),
//       Text(
//         title,
//         style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//       ),
//     ],
//   );
// }
Widget detailCard({required String title, required String value}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    color: Colors.grey.shade100,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(value),
        ],
      ),
    ),
  );
}
class PartyDetailsSectionByFields extends StatelessWidget {
  final Map<String, dynamic> partyData;
  final Map<String, dynamic> symbolData;
  final Map<String, dynamic> journeyData;

  const PartyDetailsSectionByFields({
    super.key,
    required this.partyData,
    required this.symbolData,
    required this.journeyData,
  });

  @override
  Widget build(BuildContext context) {
    print("Second");
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600, // Selected
              letterSpacing: 0.25,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400, // Unselected
              letterSpacing: 0.25,
            ),
            labelColor: const Color(0xFF000000),
            unselectedLabelColor: const Color(0xFF666666),
            indicatorColor: Colors.red,
            dividerColor: ColorScheme.of(context).onSurface.withOpacity(0.2),
            tabs:  [
            //  Tab(child: Text (PartyPageData.info,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,letterSpacing: 0.25,color: Color(0xFF666666)),)),
             Tab(text: PartyPageData.info,),
              Tab(text:PartyPageData.symbol),
              Tab(text: PartyPageData.journey),
              Tab(text: PartyPageData.leadership),
              // Tab(text: PartyPageData.feed),
              // Tab(text: PartyPageData.event),
              // Tab(text: PartyPageData.manifesto),
            ],
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              children: [
                InfoTab( partyData: partyData,),
                SymbolTab(symbolData: symbolData),

                JourneyTab(journeyData: journeyData),
                _leadershipTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leadershipTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (partyData["founder"] != null)
            detailCard(
              title: "Founder",
              value: partyData["founder"],
            ),

          if (partyData["president"] != null)
            detailCard(
              title: "President",
              value: partyData["president"]["name"] ?? "-",
            ),

          if (partyData["generalSecretary"] != null)
            detailCard(
              title: "General Secretary",
              value: partyData["generalSecretary"],
            ),
        ],
      ),
    );
  }
}