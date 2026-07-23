import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Favourite/favourite_page_caching.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Favourite/favourite_page_modal.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/journey_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/leadership_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import 'Tabs/info_tab.dart';
import 'Tabs/symbol_tab.dart';
import 'following_party_caching.dart';

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
          height: MediaQuery.of(context).size.height*0.8,
          width: double.infinity,
          child: banners.isEmpty
              ?  const Center(
                    child: Icon(Icons.image, size: 60, color: Colors.grey),
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
                            child: Icon(Icons.image),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        Positioned(
            top: 45,
            left: 30,
            child: InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Transform.rotate(
                    angle: 3.14,
                    child: SvgPicture.asset("Assets/arrow.svg",color: Colors.black,
                    height: MediaQuery.of(context).size.height*0.02,
                      width:MediaQuery.of(context).size.width*0.01 ,
                    )))),

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
  final apiService=PartyPageApis();
  bool following=false;
  bool favorite=false;
  String viewCount="0";
  String followCount="0";
  bool isLoading=false;
  final FavouritePageCaching favouritePageCaching=FavouritePageCaching();
  final FollowingPartyCaching followingPartyCaching = FollowingPartyCaching();

 Future<void>loadFavouriteStatus()async{
   final id=widget.partyData["id"];
   if(id==null) return;
   favorite=await favouritePageCaching.isFavourite(id);
   if(mounted){
     setState(() {

     });
   }
 }
  Future<void> loadFollowingStatus() async {
    final id = widget.partyData["id"];
    if (id == null) return;

    following = await followingPartyCaching.isFollowing(id);

    if (mounted) {
      setState(() {});
    }
  }
  Future<void> syncFollowingCache() async {
    final data = await apiService.iFollowParty();

    if (data.isEmpty || data.first == "Error") return;

    final ids = data
        .where((e) => e["followeeType"] == "PARTY")
        .map<int>((e) => e["followeeId"] as int)
        .toList();

    await followingPartyCaching.saveFollowingIds(ids);

    await loadFollowingStatus();
  }
  Future<String> viewCountFunction()async{
String viewValue;
    int view=await apiService.getViewCount("PARTY", widget.partyData["id"]);
if(view>9999999){
  viewValue= "${view.toString().substring(0, 1)}C";
}
else if(view>99999){
  viewValue= "${view.toString().substring(0, 1)}L";
}
    else if(view>1000){
      viewValue= "${view.toString().substring(0, 1)}K";
    }

    else viewValue=view.toString();
    return viewValue;
}
///---------Follow
  Future<String> viewFollowFunction()async{
    String followValue;
    int follow=await apiService.getFollowCount("PARTY", widget.partyData["id"]);
    if(follow>9999999){
      followValue= "${follow.toString().substring(0, 1)}C";
    }
    else if(follow>99999){
      followValue= "${follow.toString().substring(0, 1)}L";
    }
    else if(follow>1000){
      followValue= "${follow.toString().substring(0, 1)}K";
    }

    else followValue=follow.toString();
    return followValue;
  }

 @override
 void initState() {
   super.initState();
   syncFollowingCache();
   loadFavouriteStatus();
   _initializeView();
   _initializeFollow();
 }

  Future<void> _initializeView() async {
    final count = await viewCountFunction();

    if (!mounted) return;

    setState(() {
      viewCount = count;
    });
  }
  Future<void> _initializeFollow() async {
    final count = await viewFollowFunction();

    if (!mounted) return;

    setState(() {
      followCount = count;
    });
  }
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD6D6D6),
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40, // 80x80 container = radius 40
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10), // Space between border and image
                    child: (widget.partyData["partySymbolUrl"] != null &&
                        (widget.partyData["partySymbolUrl"] as String).isNotEmpty)
                        ? buildImageWidget(
                      widget.partyData["partySymbolUrl"],
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    )
                        : const Icon(
                      Icons.image,
                      color: Colors.yellow,
                      size: 35,
                    ),
                  ),
                ),
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
                            widget.partyData["state"] ?? "",
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
                      viewCount,
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
                      followCount,
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
                  onTap: () async {
                    if (isLoading) return;

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      if (!following) {
                        await apiService.followParty(
                          "PARTY",
                          widget.partyData["id"],
                        );

                        await followingPartyCaching.addFollowing(
                          widget.partyData["id"],
                        );

                        following = true;
                      } else {
                        await apiService.deleteFollowing(
                          "PARTY",
                          widget.partyData["id"],
                        );

                        await followingPartyCaching.removeFollowing(
                          widget.partyData["id"],
                        );

                        following = false;
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: Container(
                    constraints: BoxConstraints(minHeight: 37, minWidth: 127),
                    decoration: BoxDecoration(
                      color: following?null:Color(0xFF666666),
                      gradient:following? GradientColors.primaryGradient:null,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        following
                            ? PartyPageData.following
                            : "Follow",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.37,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
              Padding(

                padding: EdgeInsetsGeometry.only(top: 10),
                child: InkWell(
                  onTap: () async {
                    final id = widget.partyData["id"];

                    if (id == null) return;

                    if (favorite) {
                      await favouritePageCaching.removeFavourite(id);
                    } else {
                      await favouritePageCaching.addFavourite(
                        FavouritePageModal(
                          id: id,
                          name: widget.partyData["name"] ?? "",
                          partySymbolUrl: widget.partyData["partySymbolUrl"] ?? "",
                        ),
                      );
                    }

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
  final PartyProfileModel party;
  final SymbolModel symbol;
  final List<JourneyModel> journeys;
  final List<LeaderGroupModel>leaders;
  final ScrollController scrollController;

  const PartyDetailsSectionByFields({
    super.key,
    required this.party,
    required this.symbol,
    required this.journeys,
    required this.leaders,
    required this.scrollController,
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
            height: MediaQuery.of(context).size.height * 0.65,
            child: TabBarView(
              children: [
                InfoTab(
                  party: party,
                  scrollController: scrollController,
                ),
                SymbolTab(
                  symbol: symbol,
                ),
                JourneyTab(
                  journeys: journeys,
                ),
                LeadershipTab(leaders: leaders,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}