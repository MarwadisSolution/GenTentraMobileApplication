import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/add_event.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/adding_feed.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/adding_quote.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Menifesto/manifesto_tab.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/reusable_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Reusable Functions/reusable_functions.dart';
import 'Tabs/Feed Tab/apis.dart';
import 'Tabs/Feed Tab/feed_bloc.dart';
import 'Tabs/Feed Tab/feed_tab.dart';
import 'Tabs/Menifesto/manifesto_apis.dart';
import 'Tabs/Menifesto/manifesto_bloc.dart' show ManifestoBloc;
import 'Tabs/info_tab.dart';
import 'Tabs/journey_tab.dart';
import 'Tabs/leadership_tab.dart';
import 'Tabs/symbol_tab.dart';

class PartyFetchedData extends StatefulWidget {
  final Map<String, dynamic> partyData;

  const PartyFetchedData({super.key, required this.partyData});

  @override
  State<PartyFetchedData> createState() => _PartyFetchedDataState();
}

class _PartyFetchedDataState extends State<PartyFetchedData>
    with SingleTickerProviderStateMixin {
  final apiService = PartyPageApis();
  late Future<Map<String, dynamic>> partyFullFuture;
  late TabController _tabController;
  bool showPartyDetails = true;
  Timer? _showDetailsTimer;
  double _scrollDelta = 0.0;
  static const double _hideThreshold = 0.025;
  static const double _showThreshold = 0.015;
  double? _previousSheetExtent;
  bool? isAdmin;

  Future<void> isAdminChecking() async {
    final prefs = await SharedPreferences.getInstance();

    final String? adminPartyId = prefs.getString("AdminOfParty");

    final String currentPartyId = widget.partyData["id"].toString();

    final bool admin = adminPartyId == currentPartyId;

    print("AdminOfParty from SharedPreferences: $adminPartyId");
    print("Current party ID: $currentPartyId");
    print("isAdmin: $admin");

    if (!mounted) return;

    setState(() {
      isAdmin = admin;
    });
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 7,
      vsync: this,
    );

    isAdminChecking();

    _tabController.addListener(() {
      if (!mounted) return;

      setState(() {});
    });

    partyFullFuture = apiService.fetchPartySingleWithIdFull(
      widget.partyData["id"],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildActiveTabContent({
    required PartyProfileModel party,
    required SymbolModel symbol,
    required List<JourneyModel> journey,
    required List<LeaderGroupModel> leaders,
    required List<MemberDirectoryModel> members,
    required Map<String, List<MemberDirectoryModel>> membersByRegion,
    required ScrollController scrollController,
  }) {
    switch (_tabController.index) {
      case 0:
        return InfoTab(party: party);
      case 1:
        return SymbolTab(symbol: symbol);
      case 2:
        return JourneyTab(journeys: journey);
      case 3:
        return LeadershipTab(
          leaders: leaders,
          members: members,
          membersByRegion: membersByRegion,
        );
      case 4:
        return FeedTab(
          partyId: widget.partyData["id"],
          scrollController: scrollController,
        );
      case 5:
        return EventTab(partyId: widget.partyData["id"],
            scrollController: scrollController,);
      case 6:
        return ManifestoTab(partyId: widget.partyData["id"], scrollController: scrollController,);
      default:
        return const SizedBox.shrink();
    }
  }

  final ValueNotifier<bool> isAddSelected = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    print(screenHeight);
    final double defaultSheetRatio = (screenHeight < 500)
        ? 0.45
        : (screenHeight < 800)
        ? 0.28
        : (screenHeight < 900)
        ? 0.247
        : (218.0 / screenHeight).clamp(0.1, 0.85);

    return MultiBlocProvider(
      providers: [
        BlocProvider<FeedBloc>(
          create: (_)=>FeedBloc(FeedApis()),
        ),
        BlocProvider<EventsBloc>(
          create: (_)=>EventsBloc(EventApis()),
        ),
        BlocProvider<ManifestoBloc>(
          create: (_) => ManifestoBloc(
            ManifestoApis(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFebebeb),
              body: Stack(
                children: [
                  BannerSection(partyData: widget.partyData),
                  DraggableScrollableSheet(
                    initialChildSize: defaultSheetRatio,
                    minChildSize: defaultSheetRatio,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) {
                      return NotificationListener<
                        DraggableScrollableNotification
                      >(
                        onNotification: (notification) {
                          final currentExtent = notification.extent;
                          final previousExtent = _previousSheetExtent;

                          _previousSheetExtent = currentExtent;

                          if (previousExtent == null || !mounted) {
                            return false;
                          }

                          final delta = currentExtent - previousExtent;

                          // Sheet is expanding = user scrolling up
                          if (delta > 0) {
                            _scrollDelta += delta;

                            // Don't hide immediately.
                            // Wait until the user has actually scrolled enough.
                            if (_scrollDelta >= _hideThreshold &&
                                showPartyDetails) {
                              _scrollDelta = 0.0;

                              _showDetailsTimer?.cancel();

                              setState(() {
                                showPartyDetails = false;
                              });
                            }
                          }
                          // Sheet is collapsing = user scrolling down
                          else if (delta < 0) {
                            _scrollDelta += delta;

                            // Wait until enough downward scrolling has happened.
                            if (_scrollDelta.abs() >= _showThreshold &&
                                !showPartyDetails) {
                              _scrollDelta = 0.0;

                              _showDetailsTimer?.cancel();

                              setState(() {
                                showPartyDetails = true;
                              });
                            }
                          }

                          return false;
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: partyFullFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                                  fullData['leaderGroup']
                                      as List<LeaderGroupModel>;
                              final List<MemberDirectoryModel> members =
                                  fullData['members']
                                      as List<MemberDirectoryModel>;
                              final Map<String, List<MemberDirectoryModel>>
                              membersByRegion =
                                  fullData['membersByRegion']
                                      as Map<
                                        String,
                                        List<MemberDirectoryModel>
                                      >;

                              return CustomScrollView(
                                controller: scrollController,
                                slivers: [
                                  // Header Section (Party details)
                                  SliverToBoxAdapter(
                                    child: Column(
                                      children: [
                                        ///--------Party, followers, follow, like....
                                        AnimatedSize(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          alignment: Alignment.topCenter,
                                          child: ClipRect(
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              heightFactor: showPartyDetails
                                                  ? 1.0
                                                  : 0.0,
                                              child: PartyDetailsSection(
                                                key: const ValueKey(
                                                  'party_details',
                                                ),
                                                partyData: widget.partyData,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.01,
                                          color: const Color(
                                            0xFF000000,
                                          ).withOpacity(0.08),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Pinned TabBar
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: _SliverTabBarDelegate(
                                      TabBar(
                                        controller: _tabController,
                                        tabAlignment: TabAlignment.start,
                                        padding: EdgeInsets.only(
                                          left:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.02,
                                        ),
                                        isScrollable: true,
                                        labelStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.25,
                                        ),
                                        unselectedLabelStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.25,
                                        ),
                                        labelColor: const Color(0xFF000000),
                                        unselectedLabelColor: const Color(
                                          0xFF666666,
                                        ),
                                        indicatorColor: Colors.red,
                                        dividerColor: ColorScheme.of(
                                          context,
                                        ).onSurface.withOpacity(0.2),
                                        tabs: [
                                          Tab(text: PartyPageData.info),
                                          Tab(text: PartyPageData.symbol),
                                          Tab(text: PartyPageData.journey),
                                          Tab(text: PartyPageData.leadership),
                                          Tab(text: PartyPageData.feed),
                                          Tab(text: PartyPageData.event,),
                                          Tab(text: PartyPageData.quote,),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Dynamic Tab Body Content
                                  SliverToBoxAdapter(
                                    child: _buildActiveTabContent(
                                      party: party,
                                      symbol: symbol,
                                      journey: journey,
                                      leaders: leaders,
                                      members: members,
                                      membersByRegion: membersByRegion,
                                      scrollController: scrollController,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  if ((_tabController.index == 4 || _tabController.index == 5 || _tabController.index==6) &&
                      isAdmin == true)
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.03,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: InkWell(
                          onTap: () async{
                            isAddSelected.value = true;
                          await  showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Close',
                              barrierColor: Colors.black.withOpacity(0.4),
                              pageBuilder: (_, __, ___) {
                                return Stack(
                                  children: [
                                    Positioned(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.03 +
                                          MediaQuery.of(context).size.width *
                                              0.2 +
                                          20,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: VerticalActionMenu(
                                          height: MediaQuery.of(context).size.height*0.35,
                                          items: [
                                            ActionMenuItem(
                                              imageIcon:
                                                  PartyPageData.addFeedIcon,
                                              title: PartyPageData.feed,
                                              onTap: () {
                                                Navigator.pop(context);

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        BlocProvider.value(
                                                          value: context
                                                              .read<FeedBloc>(),
                                                          child: AddingFeed(
                                                            partyId: widget
                                                                .partyData["id"],
                                                            editFeed: null,
                                                          ),
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            ActionMenuItem(
                                              imageIcon:
                                                  PartyPageData.addQuoteIcon,
                                              title: PartyPageData.quotes,
                                              onTap: () {
                                                Navigator.pop(context);

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        BlocProvider.value(
                                                          value: context
                                                              .read<FeedBloc>(),
                                                          child: AddingQuote(
                                                            partyId: widget
                                                                .partyData["id"],
                                                            editQuote: null,
                                                          ),
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),

                                            ActionMenuItem(
                                              imageIcon:
                                                  PartyPageData.eventIcon,
                                              title: PartyPageData.event,
                                              onTap: () {
                                                Navigator.pop(context);

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        BlocProvider.value(
                                                          value: context
                                                              .read<EventsBloc>(),
                                                          child: AddEvent(
                                                            partyId: widget
                                                                .partyData["id"],

                                                          ),
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),

                                            ActionMenuItem(
                                              imageIcon:
                                                  PartyPageData.newGroupIcon,
                                              title: PartyPageData.newGroup,
                                              onTap: () {
                                                // New Group action
                                              },
                                            ),
                                            ActionMenuItem(
                                              imageIcon:
                                              PartyPageData.calenderIcon,
                                              title: PartyPageData.quote,
                                              onTap: () {
                                                // New manifesto
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              transitionDuration: const Duration(
                                milliseconds: 650,
                              ),
                              transitionBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOutCubic,
                                        ),
                                      ),
                                  child: child,
                                );
                              },
                            );
                            isAddSelected.value = false;
                          },
                          child: ValueListenableBuilder(
                            valueListenable: isAddSelected,
                            builder: (context, isSelected, child) {
                              return Container(
                                height: MediaQuery.of(context).size.width * 0.18,
                                decoration: BoxDecoration(
                                  gradient: GradientColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    isSelected
                                        ? PartyPageData.crossIconLight
                                        : PartyPageData.addIconLight,
                                    height:
                                        MediaQuery.of(context).size.width *
                                        0.06,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.06,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

///--------------Sliver TabBar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, {this.backgroundColor = Colors.white});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
