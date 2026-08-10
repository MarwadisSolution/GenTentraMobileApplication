import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/reusable_functions.dart';

import 'Tabs/Feed Tab/apis.dart';
import 'Tabs/Feed Tab/feed_bloc.dart';
import 'Tabs/Feed Tab/feed_tab.dart';
import 'Tabs/info_tab.dart';
import 'Tabs/journey_tab.dart';
import 'Tabs/leadership_tab.dart';
import 'Tabs/symbol_tab.dart';

class PartyFetchedData extends StatefulWidget {
  final Map<String, dynamic> partyData;
  const PartyFetchedData({
    super.key,
    required this.partyData,
  });

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
  double? _previousSheetExtent;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Rebuild when active tab index changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
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
        return BlocProvider(
          create: (_) => FeedBloc(FeedApis()),
          child: const FeedTab(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double defaultSheetRatio = (207.0 / screenHeight).clamp(0.0, 0.9);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFebebeb),
        body: Stack(
          children: [
            BannerSection(
              partyData: widget.partyData,
            ),
            DraggableScrollableSheet(
              initialChildSize: defaultSheetRatio,
              minChildSize: defaultSheetRatio,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    final currentExtent = notification.extent;
                    final previousExtent = _previousSheetExtent;

                    _previousSheetExtent = currentExtent;

                    if (previousExtent == null || !mounted) {
                      return false;
                    }

                    final isScrollingUp = currentExtent > previousExtent;
                    final isScrollingDown = currentExtent < previousExtent;

                    if (isScrollingUp) {
                      _showDetailsTimer?.cancel();

                      if (showPartyDetails) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted || !showPartyDetails) return;

                          setState(() {
                            showPartyDetails = false;
                          });
                        });
                      }
                    } else if (isScrollingDown && !showPartyDetails) {
                      _showDetailsTimer?.cancel();

                      _showDetailsTimer = Timer(const Duration(milliseconds: 100), () {
                        if (!mounted || showPartyDetails) return;

                        setState(() {
                          showPartyDetails = true;
                        });
                      });
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
                        fullData['leaderGroup'] as List<LeaderGroupModel>;
                        final List<MemberDirectoryModel> members =
                        fullData['members'] as List<MemberDirectoryModel>;
                        final Map<String, List<MemberDirectoryModel>>
                        membersByRegion = fullData['membersByRegion']
                        as Map<String, List<MemberDirectoryModel>>;

                        return CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            // Header Section (Party details)
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  if (showPartyDetails)
                                    PartyDetailsSection(
                                      partyData: widget.partyData,
                                    ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                    color: const Color(0xFF000000)
                                        .withOpacity(0.08),
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
                                    left: MediaQuery.of(context).size.width *
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
                                  unselectedLabelColor: const Color(0xFF666666),
                                  indicatorColor: Colors.red,
                                  dividerColor: ColorScheme.of(context)
                                      .onSurface
                                      .withOpacity(0.2),
                                  tabs: [
                                    Tab(text: PartyPageData.info),
                                    Tab(text: PartyPageData.symbol),
                                    Tab(text: PartyPageData.journey),
                                    Tab(text: PartyPageData.leadership),
                                    Tab(text: PartyPageData.feed),
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
          ],
        ),
      ),
    );
  }
}

///--------------Sliver TabBar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(
      this.tabBar, {
        this.backgroundColor = Colors.white,
      });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
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