import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/journey_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/leadership_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import '../../Favourite/favourite_api.dart';
import 'Tabs/Feed Tab/apis.dart';
import 'Tabs/Feed Tab/feed_bloc.dart';
import 'Tabs/info_tab.dart';
import 'Tabs/symbol_tab.dart';
import 'following_party_caching.dart';
///-----------Delete cancle pop up message
Widget popUpMessageForDeleteOrCancel(
    BuildContext context,
    String icon,
    String title,
    String text,
    VoidCallback onPressed,
    ) {
  final h = MediaQuery.of(context).size.height;
  final w = MediaQuery.of(context).size.width;

  return Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.06,
        vertical: h * 0.055,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            height: w * 0.09,
            width: w * 0.09,
          ),

          SizedBox(height: h * 0.025),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: (w * 0.055).clamp(18.0, 24.0),
              color: const Color(0xFF121212),
            ),
          ),

          SizedBox(height: h * 0.01),

          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: (w * 0.038).clamp(13.0, 17.0),
              color: ColorScheme.of(context)
                  .onSurface
                  .withOpacity(0.6),
            ),
          ),

          SizedBox(height: h * 0.025),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CANCEL
              Expanded(
                child: SizedBox(
                  height: h * 0.05,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color(0xFFFF2164),
                        ),
                      ),
                    ),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                        fontSize: (w * 0.032).clamp(12.0, 15.0),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF2164),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: w * 0.03),

              // DELETE
              Expanded(
                child: SizedBox(
                  height: h * 0.05,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      onPressed();
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: GradientColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "DELETE",
                        style: TextStyle(
                          fontSize: (w * 0.032).clamp(12.0, 15.0),
                          fontWeight: FontWeight.w500,
                          color: ColorScheme.of(context).surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
class BannerSection extends StatefulWidget {
  final Map<String, dynamic> partyData;

  const BannerSection({super.key, required this.partyData});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  final apiService=PartyPageApis();
  @override
  Widget build(BuildContext context) {
    final List banners = widget.partyData["bannerImages"] as List? ?? [];
    print("Banners:- ");
    print(banners);
    return Stack(
      children: [
        ///Banner Images

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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.06,   // Hit area
                height: MediaQuery.of(context).size.height*0.048,  // Hit area
                child: Center(
                  child: Transform.rotate(
                    angle: 3.14,
                    child: SvgPicture.asset(
                      "Assets/arrow.svg",
                      color: Colors.black,
                      height: MediaQuery.of(context).size.height * 0.02,
                      width: MediaQuery.of(context).size.width * 0.01,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        if (banners.length > 1)
          Positioned(
            top: MediaQuery.of(context).size.height*0.68,
            left: MediaQuery.of(context).size.width*0.6,
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
  final apiServiceFav=FavouriteApi();
  bool following=false;
  bool favorite=false;
  String viewCount="0";
  int followCount=0;
  bool isLoading=false;

  //final FavouritePageCaching favouritePageCaching=FavouritePageCaching();
  final FollowingPartyCaching followingPartyCaching = FollowingPartyCaching();

  Future<void> loadFavouriteStatus() async {
    final id = widget.partyData["id"];
    if (id == null) return;

    final favouriteIds = await apiServiceFav.getFavouritePartyIds();

    favorite = favouriteIds.contains(id);

    if (mounted) {
      setState(() {});
    }
  }
  String formatFollowCount(int count) {
    if (count > 9999999) {
      return "${count.toString().substring(0, 1)}C";
    } else if (count > 99999) {
      return "${count.toString().substring(0, 1)}L";
    } else if (count > 1000) {
      return "${count.toString().substring(0, 1)}K";
    }

    return count.toString();
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
  Future<int> getFollowCount() async {
    return await apiService.getFollowCount(
      "PARTY",
      widget.partyData["id"],
    );
  }

  @override
  void initState() {
    super.initState();

    _initializeData();
  }
  Future<void> _initializeData() async {
    await Future.wait([
      syncFollowingCache(),
      loadFavouriteStatus(),
      _initializeView(),
      _initializeFollow(),
    ]);
  }
  Future<void> _initializeView() async {
    final count = await viewCountFunction();

    if (!mounted) return;

    setState(() {
      viewCount = count;
    });
  }
  Future<void> _initializeFollow() async {
    final count = await getFollowCount();

    if (!mounted) return;

    setState(() {
      followCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
final h=MediaQuery.of(context).size.height;
final w=MediaQuery.of(context).size.width;
    return Container(
      padding:  EdgeInsets.only(
        top: h*0.01,
        left: w*0.053,
        right: w*0.04,
        bottom: h*0.015,
      ),
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(

        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height:MediaQuery.of(context).size.height*0.008,
              width: MediaQuery.of(context).size.width*0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorScheme.of(context).onSurface.withOpacity(0.16),
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width*0.005, top: MediaQuery.of(context).size.height*0.003),
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
                        radius:  MediaQuery.of(context).size.width*0.085,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: SizedBox.expand(
                            child:       (widget.partyData["partySymbolUrl"] != null &&
                                    (widget.partyData["partySymbolUrl"] as String).isNotEmpty)
                                    ? buildImageWidget(
                                  widget.partyData["partySymbolUrl"],
                                  fit: BoxFit.contain,
                                )
                                    : const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 35,
                                ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.partyData["name"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.004),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
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
                SizedBox(height: MediaQuery.of(context).size.height*0.015),

                Row(
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
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
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
                          formatFollowCount(followCount),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            letterSpacing: 0.3,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                     Spacer(),
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.1),
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
                            followCount++;
                            setState(() {

                            });
                          } else {
                            await apiService.deleteFollowing(
                              "PARTY",
                              widget.partyData["id"],
                            );

                            await followingPartyCaching.removeFollowing(
                              widget.partyData["id"],
                            );

                            following = false;
                            if (followCount > 0) {
                              followCount--;
                              setState(() {
                              });
                            }
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*0.008),
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.05,
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05,
                          ),

                          decoration: BoxDecoration(
                            color: following?null:Color(0xFF666666),
                            gradient:following? GradientColors.primaryGradient:null,
                            borderRadius: BorderRadius.all(Radius.circular(30))
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
                    ),
                    //SizedBox(width: MediaQuery.of(context).size.width * 0.04),

                  Padding(

                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02, left:MediaQuery.of(context).size.width * 0.06,

                    ),
                    child: InkWell(
                      onTap: () async {
                        final id = widget.partyData["id"];
                        if (id == null) return;


                        try {
                          if (favorite) {
                            await apiServiceFav.deleteFavourite(id);
                          } else {
                            await apiServiceFav.postFavourite(id);
                          }

                          if (mounted) {
                            setState(() {
                              favorite = !favorite;
                            });
                          }
                        } catch (e) {
                          print(e);
                        } finally {
                          if (mounted) {
                            // setState(() {
                            //   isLoading = false;
                            // });
                          }
                        }
                      },
                      child: SvgPicture.asset(
                        PartyPageData.favoriteIcon,
                        height: MediaQuery.of(context).size.height*0.027,
                        color: favorite ? null : const Color(0xFF666666),
                      ),
                    ),
                  )
                  ],
                ),

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
///----------------------------Info, vision text
class ExpandableQuillContent extends StatefulWidget {
  final String content;

  const ExpandableQuillContent({super.key, required this.content});

  @override
  State<ExpandableQuillContent> createState() => _ExpandableQuillContentState();
}

class _ExpandableQuillContentState extends State<ExpandableQuillContent> {
  bool isExpanded = false;
  late QuillController controller;

  @override
  void initState() {
    super.initState();

    controller = QuillController(
      document: _buildDocument(widget.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Document _buildDocument(String content) {
    if (content.isEmpty) {
      return Document();
    }

    try {
      return Document.fromJson(jsonDecode(content));
    } catch (_) {
      return Document()..insert(0, content);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRect(
          child: ConstrainedBox(
            constraints: isExpanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 75),
            child: QuillEditor.basic(

              controller: controller,
              config: QuillEditorConfig(
                showCursor: false,
                scrollable: false,
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                     TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.w400,
                     color: Colors.black,
                      letterSpacing: 0.81,
                       height: 1.25
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                )
              ),

            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.008),
        if (widget.content.isNotEmpty && widget.content.length>500 )
          GestureDetector(
            onTap: () {

              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? "Read Less" : "Read More",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFFE3A31),
              ),
            ),
          ),
      ],
    );
  }
}