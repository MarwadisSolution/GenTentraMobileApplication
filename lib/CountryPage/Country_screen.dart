// Country Profile Screen
// Complete, vertically scrollable mobile civic information page
// matching the exact visual hierarchy of the provided reference screens.

import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_page_data.dart';
import 'reusable_functions.dart';

/// [SCREEN ENTRY POINT] Provides the CountryProfileBloc and triggers the load event.
class CountryProfileScreen extends StatelessWidget {
  final int countryId;
  final String? countryName;

  const CountryProfileScreen({
    super.key,
    int? countryId,
    int? politicianId,
    String? countryName,
    String? name,
    String? photoUrl,
  })  : countryId = countryId ?? politicianId ?? 1,
        countryName = countryName ?? name;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CountryProfileBloc>(
      create: (context) => CountryProfileBloc(
        repository: CountryProfileRepository(),
      )..add(FetchCountryProfileEvent(countryId)),
      child: _CountryProfileView(
        countryId: countryId,
        initialName: countryName,
      ),
    );
  }
}

// Aliases for compatibility
typedef PoliticianProfileScreen = CountryProfileScreen;

class _CountryProfileView extends StatefulWidget {
  final int countryId;
  final String? initialName;

  const _CountryProfileView({
    required this.countryId,
    this.initialName,
  });

  @override
  State<_CountryProfileView> createState() => _CountryProfileViewState();
}

class _CountryProfileViewState extends State<_CountryProfileView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);
  final ValueNotifier<double> _sheetProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _showCountryDetails = ValueNotifier<bool>(true);
  bool _isUserScrolling = false;
  bool _isInfoExpanded = false;
  bool _isFlagExpanded = false;
  Offset? _draggableFabPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    // Tab switch listener matching Party Page exactly
    _tabController.addListener(() {
      if (!mounted) return;
      if (!_tabController.indexIsChanging) {
        _selectedTabIndex.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedTabIndex.dispose();
    _sheetProgress.dispose();
    _showCountryDetails.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<CountryProfileBloc, CountryProfileState>(
        builder: (context, state) {
          if (state.status == CountryProfileStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFE3A31),
              ),
            );
          }

          if (state.status == CountryProfileStatus.failure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "Assets/PartyPage/crossIcon.svg",
                      width: screenWidth * 0.14,
                      height: screenWidth * 0.14,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFE3A31),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      state.errorMessage ?? 'Failed to load country profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<CountryProfileBloc>()
                            .add(FetchCountryProfileEvent(widget.countryId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE3A31),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.status == CountryProfileStatus.success &&
              state.country != null) {
            return _buildLoadedContent(state.country!, screenHeight);
          }

          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFE3A31),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: LOADED CONTENT]
  // ==========================================================================
  Widget _buildLoadedContent(CountryModel country, double screenHeight) {
    final List<String> banners = country.bannerImages;

    final double defaultSheetRatio = (screenHeight < 500)
        ? 0.45
        : (screenHeight < 800)
            ? 0.28
            : (screenHeight < 900)
                ? 0.247
                : (218.0 / screenHeight).clamp(0.1, 0.85);

    final String countryHeaderTitle = country.name.isNotEmpty
        ? country.name
        : '';

    final double screenWidth = MediaQuery.of(context).size.width;
    final double fabSize = screenWidth * 0.12;

    _draggableFabPosition ??= Offset(
      screenWidth - fabSize - screenWidth * 0.05,
      screenHeight * 0.62,
    );

    return Stack(
      children: [
        // Background banner with progressive blur & darkening matching Party Page
        ValueListenableBuilder<double>(
          valueListenable: _sheetProgress,
          builder: (context, progress, child) {
            return CountryBannerSection(
              banners: banners,
              countryName: countryHeaderTitle,
              progress: progress,
            );
          },
        ),

        // Draggable Scrollable Sheet matching Party Page scrolling behavior
        NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            final progress = ((notification.extent - defaultSheetRatio) /
                    (0.9 - defaultSheetRatio))
                .clamp(0.0, 1.0);
            if ((progress - _sheetProgress.value).abs() > 0.005) {
              _sheetProgress.value = progress;
            }
            return false;
          },
          child: DraggableScrollableSheet(
            initialChildSize: defaultSheetRatio,
            minChildSize: defaultSheetRatio,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (!mounted || notification.depth != 0) {
                    return false;
                  }

                  if (notification is ScrollStartNotification) {
                    _isUserScrolling = notification.dragDetails != null;
                  }

                  if (notification is ScrollEndNotification) {
                    _isUserScrolling = false;
                  }

                  if (notification is UserScrollNotification &&
                      _isUserScrolling) {
                    if (notification.direction == ScrollDirection.reverse) {
                      if (_showCountryDetails.value) {
                        _showCountryDetails.value = false;
                      }
                    } else if (notification.direction ==
                        ScrollDirection.forward) {
                      if (!_showCountryDetails.value) {
                        _showCountryDetails.value = true;
                      }
                    }
                  }

                  return false;
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(screenWidth * 0.06),
                    ),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header Section (Country details) with animated collapse on scroll
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _showCountryDetails,
                          builder: (context, showDetails, child) {
                            return AnimatedSize(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topCenter,
                              child: ClipRect(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  heightFactor: showDetails ? 1.0 : 0.0,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CountryDetailsSection(
                                key: const ValueKey('country_details'),
                                country: country,
                              ),
                              Container(
                                height: MediaQuery.of(context).size.width * (6.0 / 375.0),
                                width: double.infinity,
                                color: const Color(0xFFEBEBEB),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Pinned TabBar
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            onTap: (index) {
                              _selectedTabIndex.value = index;
                            },
                            tabAlignment: TabAlignment.start,
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                            isScrollable: true,
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02,
                            ),
                            labelStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.033,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.25,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.033,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.25,
                            ),
                            labelColor: const Color(0xFF000000),
                            unselectedLabelColor: const Color(0xFF666666),
                            indicatorColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: SmallTabIndicator(
                              width: MediaQuery.of(context).size.width * 0.07,
                              height: MediaQuery.of(context).size.width * 0.0075,
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.0035,
                              ),
                            ),
                            dividerColor: ColorScheme.of(context).onSurface.withValues(alpha: 0.2),
                            tabs: const [
                              Tab(text: CountryPageData.infoTab),
                              Tab(text: CountryPageData.flagEmblemTab),
                              Tab(text: CountryPageData.geographicTab),
                              Tab(text: CountryPageData.placesTab),
                            ],
                          ),
                          dividerHeight: 0,
                        ),
                      ),

                      // Tab Body Content
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          child: ValueListenableBuilder<int>(
                            valueListenable: _selectedTabIndex,
                            builder: (context, selectedIndex, child) {
                              return Stack(
                                children: [
                                  // Tab 0: INFO
                                  Offstage(
                                    offstage: selectedIndex != 0,
                                    child: _buildInfoTabContent(country),
                                  ),
                                  // Tab 1: FLAG / EMBLEM
                                  Offstage(
                                    offstage: selectedIndex != 1,
                                    child: _buildPlacesAndSymbolsTab(country),
                                  ),
                                  // Tab 2: GEOGRAPHIC
                                  Offstage(
                                    offstage: selectedIndex != 2,
                                    child: _buildGeographicTabContent(country),
                                  ),
                                  // Tab 3: PLACES TO VISIT
                                  Offstage(
                                    offstage: selectedIndex != 3,
                                    child: _buildPlacesToVisitTab(country),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // Bottom Spacing
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height * 0.06,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ====================================================================
        // [GLOBAL DRAGGABLE ORANGE FAB]
        // Accessible across all tabs (Info, Flag/Emblem, Geographic)
        // Can be freely dragged anywhere on the screen by the user
        // ====================================================================
        Positioned(
          left: _draggableFabPosition!.dx,
          top: _draggableFabPosition!.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final double minX = screenWidth * 0.02;
                final double maxX = screenWidth - fabSize - screenWidth * 0.02;
                final double minY = MediaQuery.of(context).padding.top + screenHeight * 0.02;
                final double maxY = screenHeight - fabSize - MediaQuery.of(context).padding.bottom - screenHeight * 0.02;

                _draggableFabPosition = Offset(
                  (_draggableFabPosition!.dx + details.delta.dx).clamp(minX, maxX),
                  (_draggableFabPosition!.dy + details.delta.dy).clamp(minY, maxY),
                );
              });
            },
            onTap: () {
              if (_tabController.index != 2) {
                _tabController.animateTo(2); // Switches to GEOGRAPHIC tab
              }
            },
            child: Container(
              width: fabSize,
              height: fabSize,
              decoration: BoxDecoration(
                color: const Color(0xFFFE3A31),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFE3A31).withValues(alpha: 0.4),
                    blurRadius: screenWidth * 0.025,
                    spreadRadius: 1.0,
                    offset: Offset(0, screenHeight * 0.004),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  CountryPageData.orangeButtonLogo,
                  width: fabSize * 0.46,
                  height: fabSize * 0.46,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // [BUILD METHOD: INFO TAB] Full civic data with robust fallbacks
  // ==========================================================================
  Widget _buildInfoTabContent(CountryModel country) {
    final String countryName = country.name;
    final String descriptionText = country.info?.trim() ?? '';

    // Setup leadership lists from backend data without hardcoded fallbacks
    final List<NationalLeader> presidents = country.leaders
        .where((l) => l.title.toUpperCase().contains('PRESIDENT'))
        .toList();

    final List<NationalLeader> primeMinisters = country.leaders
        .where((l) => l.title.toUpperCase().contains('PRIME'))
        .toList();

    final List<NationalLeader> defenceMinisters = country.leaders
        .where((l) => l.title.toUpperCase().contains('DEFENCE'))
        .toList();

    final List<NationalLeader> homeMinisters = country.leaders
        .where((l) => l.title.toUpperCase().contains('HOME'))
        .toList();

    final List<CabinetMinister> cabinets = country.otherCabinets;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.016,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================================
          // [OVERVIEW PARAGRAPH & READ MORE]
          // ==================================================================
          if (descriptionText.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: _isInfoExpanded ? null : 4,
                    overflow:
                        _isInfoExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: screenWidth * 0.034,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF333333),
                        height: 1.5,
                      ),
                      children: [
                        if (countryName.isNotEmpty)
                          TextSpan(
                            text: '$countryName, ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        TextSpan(
                          text: (countryName.isNotEmpty && descriptionText.startsWith(countryName))
                              ? descriptionText.substring(countryName.length).trimLeft()
                              : descriptionText,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isInfoExpanded = !_isInfoExpanded);
                    },
                    child: Text(
                      _isInfoExpanded ? 'READ LESS' : 'READ MORE',
                      style: TextStyle(
                        fontSize: screenWidth * 0.031,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFE3A31),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ],

          // ==================================================================
          // [6 KEY CIVIC DETAIL ROWS WITH ICONS]
          // ==================================================================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CAPITAL
                _buildCivicDetailRow(
                  icon: SvgPicture.asset(
                    CountryPageData.capitalIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.capital,
                  value: country.capital?.trim().isNotEmpty == true
                      ? country.capital!.trim()
                      : '-',
                ),

                // 2. NATIONAL ANTHEM
                _buildCivicDetailRow(
                  icon: SvgPicture.asset(
                    CountryPageData.nationalAnthemIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.nationalAnthem,
                  value: country.nationalAnthem?.trim().isNotEmpty == true
                      ? country.nationalAnthem!.trim()
                      : '-',
                ),

                // 3. POPULATION
                _buildCivicDetailRow(
                  icon: SvgPicture.asset(
                    CountryPageData.populationIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.population,
                  value: country.population?.trim().isNotEmpty == true
                      ? country.population!.trim()
                      : '-',
                ),

                // 4. PRESIDENT
                _buildCivicDetailRow(
                  icon: SvgPicture.asset(
                    CountryPageData.presidentIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.president,
                  value: country.president?.trim().isNotEmpty == true
                      ? country.president!.trim()
                      : '-',
                ),

                // 5. PRIME MINISTER
                _buildCivicDetailRow(
                  icon: SvgPicture.asset(
                    CountryPageData.primeMinisterIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.primeMinister,
                  value: country.primeMinister?.trim().isNotEmpty == true
                      ? country.primeMinister!.trim()
                      : '-',
                ),

                // 6. DATE OF INDEPENDENCE
                _buildCivicDetailRow(
                  icon: SvgPicture.asset(
                    CountryPageData.dateOfIndependenceIcon,
                    width: screenWidth * 0.055,
                    height: screenWidth * 0.055,
                  ),
                  label: CountryPageData.dateOfIndependence,
                  value: country.independenceDay?.trim().isNotEmpty == true &&
                          formatCountryDate(country.independenceDay) != '-'
                      ? formatCountryDate(country.independenceDay)
                      : '-',
                ),
              ],
            ),
          ),

          // ==================================================================
          // [LEADERSHIP SECTIONS - ONLY RENDERED IF BACKEND PROVIDES DATA]
          // ==================================================================
          if (presidents.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              title: 'PRESIDENT',
              leaders: presidents,
              showPartyLogo: false,
            ),
          ],

          if (primeMinisters.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              title: 'PRIME MINISTER',
              leaders: primeMinisters,
              showPartyLogo: true,
            ),
          ],

          if (defenceMinisters.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              title: 'DEFENCE MINISTER',
              leaders: defenceMinisters,
              showPartyLogo: true,
            ),
          ],

          if (homeMinisters.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              title: 'HOME MINISTER',
              leaders: homeMinisters,
              showPartyLogo: true,
            ),
          ],

          if (cabinets.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildOtherCabinetsSection(cabinets),
          ],

          buildSectionDivider(context),
        ],
      ),
    );
  }

  // ==========================================================================
  // [CIVIC DETAIL ROW HELPER]
  // ==========================================================================
  Widget _buildCivicDetailRow({
    required Widget icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.075,
            height: screenWidth * 0.075,
            child: Center(child: icon),
          ),
          SizedBox(width: screenWidth * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.026,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: const Color(0xFF888888),
                  ),
                ),
                SizedBox(height: screenHeight * 0.003),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: LEADERSHIP HORIZONTAL SECTION]
  // Sized strictly using MediaQuery without hardcoded dimensions.
  // ==========================================================================
  Widget _buildLeaderHorizontalSection({
    required String title,
    required List<NationalLeader> leaders,
    bool showPartyLogo = true,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double cardWidth = screenWidth * (280.0 / 375.0);
    final double cardImageHeight = cardWidth * (339.0 / 280.0);
    final double listHeight = cardWidth * (396.0 / 280.0);
    final double cardRadius = cardWidth * (20.0 / 280.0);
    final double cardMarginRight = screenWidth * (16.0 / 375.0);
    final double spacingBelowImage = cardWidth * (10.0 / 280.0);
    final double partyLogoSize = cardWidth * (28.0 / 280.0);
    final double badgeBottom = cardImageHeight * (12.0 / 339.0);
    final double badgeRight = cardWidth * (12.0 / 280.0);
    final double badgeHorizontalPadding = cardWidth * (12.0 / 280.0);
    final double badgeVerticalPadding = cardImageHeight * (5.0 / 339.0);
    final double badgeRadius = cardWidth * (14.0 / 280.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.034,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: const Color(0xFF1E1E1E),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.016),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final leader = leaders[index];
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: cardMarginRight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Image with rounded corners and translucent pill badge
                    Container(
                      height: cardImageHeight,
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(cardRadius),
                            child: leader.imageUrl.isNotEmpty
                                ? buildImageWidget(
                                    leader.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: const Color(0xFFF5F5F5),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "Assets/PartyPage/personIcon.svg",
                                        width: cardWidth * 0.25,
                                        height: cardWidth * 0.25,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFBDBDBD),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          if (leader.badge.isNotEmpty)
                            Positioned(
                              bottom: badgeBottom,
                              right: badgeRight,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: badgeHorizontalPadding,
                                  vertical: badgeVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(badgeRadius),
                                ),
                                child: Text(
                                  leader.badge,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: cardWidth * (11.0 / 280.0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacingBelowImage),
                    // Below image: Party Logo (if applicable) and Name + Tenure
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showPartyLogo &&
                            leader.partyLogo != null &&
                            leader.partyLogo!.isNotEmpty) ...[
                          ClipOval(
                            child: Container(
                              width: partyLogoSize,
                              height: partyLogoSize,
                              color: Colors.white,
                              child: buildImageWidget(
                                leader.partyLogo!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: cardWidth * (8.0 / 280.0)),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leader.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: cardWidth * (13.5 / 280.0),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                              if (leader.tenure.isNotEmpty) ...[
                                SizedBox(height: screenHeight * 0.003),
                                Text(
                                  leader.tenure,
                                  style: TextStyle(
                                    fontSize: cardWidth * (11.5 / 280.0),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // [BUILD METHOD: OTHER CABINETS]
  // ==========================================================================
  Widget _buildOtherCabinetsSection(List<CabinetMinister> cabinets) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OTHER CABINATE',
                style: TextStyle(
                  fontSize: screenWidth * 0.033,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              SvgPicture.asset(
                CountryPageData.arrow,
                width: screenWidth * 0.046,
                height: screenWidth * 0.046,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFE3A31),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.003),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: screenWidth * 0.026,
              mainAxisSpacing: screenHeight * 0.016,
              childAspectRatio: 0.68,
            ),
            itemCount: cabinets.length,
            itemBuilder: (context, index) {
              final minister = cabinets[index];
              final double ministerRadius = screenWidth * 0.04;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: minister.backgroundColor,
                        borderRadius: BorderRadius.circular(ministerRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ministerRadius),
                        child: minister.imageUrl.isNotEmpty
                            ? buildImageWidget(
                                minister.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFF5F5F5),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "Assets/PartyPage/personIcon.svg",
                                    width: screenWidth * 0.1,
                                    height: screenWidth * 0.1,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFBDBDBD),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.007),
                  Text(
                    minister.firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  Text(
                    minister.lastName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: screenWidth * 0.028,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: FLAG / EMBLEM TAB]
  // ==========================================================================
  Widget _buildPlacesAndSymbolsTab(CountryModel country) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    // 1. Dynamic Backend Lookup
    SymbolView? flagSymbol;
    SymbolView? emblemSymbol;
    for (final s in country.symbols) {
      final kind = (s.kind ?? '').toUpperCase();
      final label = (s.label ?? '').toLowerCase();
      if ((kind.contains('FLAG') || label.contains('flag') || label.contains('tiranga')) && flagSymbol == null) {
        flagSymbol = s;
      } else if ((kind.contains('EMBLEM') || label.contains('emblem') || label.contains('capital') || label.contains('lion')) && emblemSymbol == null) {
        emblemSymbol = s;
      }
    }
    if (flagSymbol == null && country.symbols.isNotEmpty) {
      flagSymbol = country.symbols.first;
    }
    if (emblemSymbol == null && country.symbols.length > 1) {
      emblemSymbol = country.symbols[1];
    }

    // 2. Dynamic Description from Backend or fallback
    final String? backendDesc = (flagSymbol?.description?.trim().isNotEmpty == true)
        ? flagSymbol!.description
        : ((emblemSymbol?.description?.trim().isNotEmpty == true)
            ? emblemSymbol!.description
            : (country.cultureAndTradition?.trim().isNotEmpty == true
                ? country.cultureAndTradition
                : (country.info?.trim().isNotEmpty == true ? country.info : null)));

    final String flagDesc = backendDesc?.trim().isNotEmpty == true
        ? backendDesc!.trim()
        : '';

    // 3. Dynamic Image URLs
    final String flagUrl = flagSymbol?.urls.firstWhere(
          (u) => u.trim().isNotEmpty,
          orElse: () => '',
        ) ?? '';
    final String emblemUrl = emblemSymbol?.urls.firstWhere(
          (u) => u.trim().isNotEmpty,
          orElse: () => '',
        ) ?? '';

    // 4. Labels
    final String flagLabel = (flagSymbol?.label?.trim().isNotEmpty == true)
        ? flagSymbol!.label!
        : (country.name.isNotEmpty ? '${country.name} Flag' : 'Flag');

    final String emblemLabel = (emblemSymbol?.label?.trim().isNotEmpty == true)
        ? emblemSymbol!.label!
        : (country.name.isNotEmpty ? '${country.name} Emblem' : 'Emblem');

    // 5. Proportional MediaQuery Dimensions (180x180 & 180x193 on 375w reference)
    final double flagWidth = w * (180.0 / 375.0);
    final double flagHeight = flagWidth * (180.0 / 180.0);

    final double emblemWidth = w * (180.0 / 375.0);
    final double emblemHeight = emblemWidth * (193.0 / 180.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: h * 0.018,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description Paragraph with READ MORE / READ LESS toggle
                RichText(
                  maxLines: _isFlagExpanded ? null : 4,
                  overflow:
                      _isFlagExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: w * 0.034,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF333333),
                      height: 1.5,
                    ),
                    text: flagDesc,
                  ),
                ),
                SizedBox(height: h * 0.008),
                GestureDetector(
                  onTap: () {
                    setState(() => _isFlagExpanded = !_isFlagExpanded);
                  },
                  child: Text(
                    _isFlagExpanded ? 'READ LESS' : 'READ MORE',
                    style: TextStyle(
                      fontSize: w * 0.031,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFE3A31),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(height: h * 0.025),

                // Centered Flag
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: flagWidth,
                        height: flagHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(flagWidth * (8.0 / 180.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: flagWidth * (8.0 / 180.0),
                              offset: Offset(0, h * 0.002),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: _buildFlagImageWidget(flagUrl, flagWidth, flagHeight),
                      ),
                      SizedBox(height: h * 0.014),
                      Text(
                        flagLabel,
                        style: TextStyle(
                          fontSize: w * 0.03,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.035),

                // Centered Emblem
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: emblemWidth,
                        height: emblemHeight,
                        child: Center(
                          child: _buildEmblemImageWidget(emblemUrl, emblemWidth, emblemHeight),
                        ),
                      ),
                      SizedBox(height: h * 0.014),
                      Text(
                        emblemLabel,
                        style: TextStyle(
                          fontSize: w * 0.03,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.02),
          buildSectionDivider(context),
        ],
      ),
    );
  }

  Widget _buildFlagImageWidget(String rawUrl, double width, double height) {
    final url = rawUrl.trim();
    if (url.isNotEmpty) {
      final fullUrl = (url.startsWith('http://') || url.startsWith('https://'))
          ? url
          : (url.startsWith('/') ? '$api$url' : '$api/$url');
      return ClipRRect(
        borderRadius: BorderRadius.circular(width * (8.0 / 180.0)),
        child: buildImageWidget(
          fullUrl,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.flag_rounded,
        size: width * 0.45,
        color: const Color(0xFFBDBDBD),
      ),
    );
  }

  Widget _buildEmblemImageWidget(String rawUrl, double width, double height) {
    final url = rawUrl.trim();
    if (url.isNotEmpty) {
      final fullUrl = (url.startsWith('http://') || url.startsWith('https://'))
          ? url
          : (url.startsWith('/') ? '$api$url' : '$api/$url');
      return buildImageWidget(
        fullUrl,
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }
    return Center(
      child: Icon(
        Icons.shield_rounded,
        size: width * 0.45,
        color: const Color(0xFFBDBDBD),
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: PLACES TO VISIT TAB]
  // Full-width image cards with place name and description
  // ==========================================================================
  Widget _buildPlacesToVisitTab(CountryModel country) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final List<PlaceView> places = country.placesToVisit?.places ?? [];

    // Header intro text — from backend description or generic copy
    final String introText =
        (country.placesToVisit?.description?.trim().isNotEmpty == true)
            ? country.placesToVisit!.description!.trim()
            : 'Here are a few iconic places you simply must experience.';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.045,
        vertical: h * 0.022,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Intro text ──
          Text(
            introText,
            style: TextStyle(
              fontSize: w * 0.038,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E),
              height: 1.45,
            ),
          ),
          SizedBox(height: h * 0.022),

          // ── Place cards ──
          ...places.map((place) => _buildPlaceListCard(context, place, w, h)),

          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }

  /// Full-width vertical card matching the reference UI:
  /// clean image with pagination dots at bottom right, name in bold uppercase, description below.
  Widget _buildPlaceListCard(
    BuildContext context,
    PlaceView place,
    double w,
    double h,
  ) {
    final double imageHeight = h * 0.22;
    final double borderRadius = w * 0.04;

    // Resolve full image URL
    final String rawUrl = place.imageUrl?.trim() ?? '';
    final String imageUrl =
        rawUrl.isEmpty
            ? ''
            : (rawUrl.startsWith('http://') || rawUrl.startsWith('https://'))
            ? rawUrl
            : (rawUrl.startsWith('/') ? '$api$rawUrl' : '$api/$rawUrl');

    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.024),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Clean photo with pagination indicator dots at bottom right ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: SizedBox(
                  width: double.infinity,
                  height: imageHeight,
                  child: imageUrl.isNotEmpty
                      ? buildImageWidget(imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF0F0F0),
                          child: Center(
                            child: Icon(
                              Icons.landscape_rounded,
                              size: w * 0.12,
                              color: const Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                ),
              ),

              // Pagination indicator dots at bottom right matching reference UI
              Positioned(
                bottom: h * 0.012,
                right: w * 0.035,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.018,
                    vertical: h * 0.0035,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (dotIndex) {
                      final bool isSelected = dotIndex == 2;
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: w * 0.005),
                        width: isSelected ? w * 0.018 : w * 0.013,
                        height: isSelected ? w * 0.018 : w * 0.013,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.red
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: h * 0.014),

          // ── Place name ──
          Text(
            place.name.toUpperCase(),
            style: TextStyle(
              fontSize: w * 0.042,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
              letterSpacing: 0.3,
            ),
          ),

          // ── Description ──
          if (place.description != null && place.description!.isNotEmpty) ...[
            SizedBox(height: h * 0.006),
            Text(
              place.description!,
              style: TextStyle(
                fontSize: w * 0.033,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555555),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: GEOGRAPHIC TAB]
  // ==========================================================================
  Widget _buildGeographicTabContent(CountryModel country) {
    return GeographicTabSection(country: country);
  }
}

/// Custom compact TabBar indicator decoration matching Party & Country reference
class SmallTabIndicator extends Decoration {
  final double width;
  final double height;
  final Color color;
  final BorderRadiusGeometry borderRadius;

  const SmallTabIndicator({
    required this.width,
    required this.height,
    this.color = Colors.red,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
  });

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is SmallTabIndicator) {
      return SmallTabIndicator(
        width: lerpDouble(a.width, width, t) ?? width,
        height: lerpDouble(a.height, height, t) ?? height,
        color: Color.lerp(a.color, color, t) ?? color,
        borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t) ?? borderRadius,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is SmallTabIndicator) {
      return SmallTabIndicator(
        width: lerpDouble(width, b.width, t) ?? width,
        height: lerpDouble(height, b.height, t) ?? height,
        color: Color.lerp(color, b.color, t) ?? b.color,
        borderRadius: BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t) ?? b.borderRadius,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _SmallTabIndicatorPainter(this, onChanged);
  }
}

class _SmallTabIndicatorPainter extends BoxPainter {
  final SmallTabIndicator decoration;

  _SmallTabIndicatorPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & (configuration.size ?? Size.zero);
    final double indicatorWidth = decoration.width;
    final double left = rect.center.dx - (indicatorWidth / 2);
    final double top = rect.bottom - decoration.height;
    final Rect indicatorRect = Rect.fromLTWH(
      left,
      top,
      indicatorWidth,
      decoration.height,
    );
    final Paint paint = Paint()..color = decoration.color;
    canvas.drawRRect(
      decoration.borderRadius
          .resolve(configuration.textDirection)
          .toRRect(indicatorRect),
      paint,
    );
  }
}

/// Sliver TabBar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;
  final double dividerHeight;

  _SliverTabBarDelegate(
    this.tabBar, {
    this.dividerHeight = 0.0,
  }) : backgroundColor = Colors.white;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height + dividerHeight;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dividerHeight != dividerHeight;
  }
}

// ============================================================================
// [GEOGRAPHIC TAB SECTION]
// Responsive Geographic & Administrative Profile Section
// Includes 3-Level Interactive Vector India Map (Country -> State -> District)
// ============================================================================
class GeographicTabSection extends StatefulWidget {
  final CountryModel country;

  const GeographicTabSection({
    super.key,
    required this.country,
  });

  @override
  State<GeographicTabSection> createState() => _GeographicTabSectionState();
}

class _GeographicTabSectionState extends State<GeographicTabSection> {
  bool _isExpanded = true;

  String _formatArea(String? area) {
    if (area != null && area.trim().isNotEmpty) {
      final a = area.trim();
      if (a.toLowerCase().contains('km') || a.toLowerCase().contains('sq')) {
        return a;
      }
      return '$a km2';
    }
    return '-';
  }

  Widget _buildFormattedParagraph(String text, double fontSize, {EdgeInsetsGeometry? padding}) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF333333),
            height: 1.45,
            letterSpacing: 0.1,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E1E1E),
          height: 1.45,
          letterSpacing: 0.1,
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF333333),
          height: 1.45,
          letterSpacing: 0.1,
        ),
      ));
    }

    final richText = RichText(
      text: TextSpan(children: spans),
    );

    if (padding != null) {
      return Padding(
        padding: padding,
        child: richText,
      );
    }
    return richText;
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String iconAsset,
    required String label,
    required String value,
    required double w,
    required double h,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: w * 0.048,
          height: w * 0.048,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: w * 0.038,
              height: w * 0.038,
            ),
          ),
        ),
        SizedBox(width: w * 0.035),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: w * 0.026,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9E9E9E),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: h * 0.002),
              Text(
                value,
                style: TextStyle(
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    // 1. Description: API first
    final String rawDescription = widget.country.geographicDescription?.trim().isNotEmpty == true
        ? widget.country.geographicDescription!.trim()
        : (widget.country.info?.trim().isNotEmpty == true
            ? widget.country.info!.trim()
            : '');

    final List<String> allParagraphs = rawDescription
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final List<String> paragraphs = allParagraphs.isNotEmpty
        ? allParagraphs
        : rawDescription.split('\n').where((p) => p.trim().isNotEmpty).toList();

    final List<String> visibleParagraphs = _isExpanded
        ? paragraphs
        : (paragraphs.length > 2 ? paragraphs.sublist(0, 2) : paragraphs);

    final bool canToggle = paragraphs.length > 2 || rawDescription.length > 250;

    // 2. Stats values from API
    final String areaValue = _formatArea(widget.country.area);
    final String regCodeValue = widget.country.registrationCode?.trim().isNotEmpty == true
        ? widget.country.registrationCode!.trim()
        : '-';
    final String populationValue = widget.country.population?.trim().isNotEmpty == true
        ? widget.country.population!.trim()
        : '-';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.018,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width description paragraphs
          for (int i = 0; i < visibleParagraphs.length; i++) ...[
            _buildFormattedParagraph(
              visibleParagraphs[i],
              w * 0.034,
            ),
            if (i < visibleParagraphs.length - 1)
              SizedBox(height: h * 0.016),
          ],

          // SHOW LESS / SHOW MORE Toggle
          if (canToggle) ...[
            SizedBox(height: h * 0.012),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'SHOW LESS' : 'SHOW MORE',
                style: TextStyle(
                  fontSize: w * 0.032,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFE3A31),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],

          SizedBox(height: h * 0.025),

          // Civic Stats (AREA, REGISTRATION CODE, POPULATION)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats 1: AREA
              _buildStatRow(
                context: context,
                iconAsset: CountryPageData.geographicAreaIcon,
                label: 'AREA',
                value: areaValue,
                w: w,
                h: h,
              ),

              SizedBox(height: h * 0.016),

              // Stats 2: REGISTRATION CODE
              _buildStatRow(
                context: context,
                iconAsset: CountryPageData.geographicRegistrationCodeIcon,
                label: 'REGISTRATION CODE',
                value: regCodeValue,
                w: w,
                h: h,
              ),

              SizedBox(height: h * 0.016),

              // Stats 3: POPULATION
              _buildStatRow(
                context: context,
                iconAsset: CountryPageData.geographicPopulationIcon,
                label: 'POPULATION',
                value: populationValue,
                w: w,
                h: h,
              ),
            ],
          ),

          SizedBox(height: h * 0.025),

          // ── INTERACTIVE INDIA MAP SECTION ──
          IndiaMapWidget(
            initialSelectedState: widget.country.registrationCode,
            onStateSelected: (state) {
              debugPrint('Selected State: ${state.name} (${state.code})');
            },
            onDistrictSelected: (district) {
              debugPrint('Selected District: ${district.districtName} in ${district.stateName}');
            },
          ),

          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }
}
