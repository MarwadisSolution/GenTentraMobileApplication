// Country Profile Screen
// Complete, vertically scrollable mobile civic information page
// matching the exact visual hierarchy of the provided reference screens.

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
      length: 3,
      vsync: this,
    );

    // Tab switch listener
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
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: screenWidth * 0.14,
                      color: Color(0xFFFE3A31),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      state.errorMessage ?? 'Failed to load country profile',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    ElevatedButton.icon(
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
                          horizontal: MediaQuery.of(context).size.width * 0.06,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: screenWidth * 0.046),
                      label: const Text('Try Again'),
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
    final bool isIndia = country.name.toLowerCase().contains('india') ||
        country.name.isEmpty ||
        country.registrationCode == 'IND';

    final List<String> banners = country.bannerImages.isNotEmpty
        ? country.bannerImages
        : [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Taj_Mahal_%28Edited%29.jpeg/1200px-Taj_Mahal_%28Edited%29.jpeg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Taj_Mahal_%28Edited%29.jpeg/1200px-Taj_Mahal_%28Edited%29.jpeg',
          ];

    final double defaultSheetRatio = (screenHeight < 500)
        ? 0.45
        : (screenHeight < 800)
            ? 0.28
            : (screenHeight < 900)
                ? 0.247
                : (218.0 / screenHeight).clamp(0.1, 0.85);

    final String countryHeaderTitle = isIndia ? 'India - भारत' : country.name;
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(screenWidth * 0.06),
                    ),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
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
                          child: CountryDetailsSection(
                            key: const ValueKey('country_details'),
                            country: country,
                          ),
                        ),
                      ),

                      // Pinned TabBar
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            tabAlignment: TabAlignment.start,
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                            isScrollable: true,
                            labelPadding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.045,
                            ),
                            labelStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.033,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.033,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            labelColor: const Color(0xFF1E1E1E),
                            unselectedLabelColor: const Color(0xFF757575),
                            indicatorColor: const Color(0xFFFE3A31),
                            indicatorWeight: MediaQuery.of(context).size.width * 0.007,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: const Color(0xFFEEEEEE),
                            tabs: const [
                              Tab(text: CountryPageData.infoTab),
                              Tab(text: CountryPageData.flagEmblemTab),
                              Tab(text: CountryPageData.geographicTab),
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
  // [BUILD METHOD: INFO TAB] Pixel-perfect match for Screenshots 1, 2, 3, 4
  // ==========================================================================
  Widget _buildInfoTabContent(CountryModel country) {
    final bool isIndia = country.name.toLowerCase().contains('india') ||
        country.name.isEmpty ||
        country.registrationCode == 'IND';

    final String countryName = country.name.isNotEmpty ? country.name : 'India';

    final String descriptionText = country.info?.isNotEmpty == true
        ? country.info!
        : 'officially the Republic of India, is a country in South Asia. It is the seventh-largest country by area; the most populous country since 2023; and, since its independence in 1947, the world\'s most populous democracy.';

    // Setup leadership lists
    final List<NationalLeader> presidents = [
      NationalLeader(
        title: 'PRESIDENTS OF INDIA',
        name: country.president?.isNotEmpty == true
            ? country.president!
            : 'Droupadi Murmu',
        tenure: '2022 - Present',
        badge: 'Current President',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Droupadi_Murmu_official_portrait_%28cropped%29.jpg/800px-Droupadi_Murmu_official_portrait_%28cropped%29.jpg',
      ),
      const NationalLeader(
        title: 'PRESIDENTS OF INDIA',
        name: 'Ram Nath Kovind',
        tenure: '2017 - 2022',
        badge: 'Former President',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Ram_Nath_Kovind_official_portrait.jpg/800px-Ram_Nath_Kovind_official_portrait.jpg',
      ),
      const NationalLeader(
        title: 'PRESIDENTS OF INDIA',
        name: 'Pranab Mukherjee',
        tenure: '2012 - 2017',
        badge: 'Former President',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Pranab_Mukherjee_in_2012.jpg/800px-Pranab_Mukherjee_in_2012.jpg',
      ),
    ];

    // Prime Minister matching Screenshot 2 & 3
    final List<NationalLeader> primeMinisters = [
      NationalLeader(
        title: 'PRIME MINISTER',
        name: country.primeMinister?.isNotEmpty == true
            ? country.primeMinister!
            : 'Shri D. K. Shivakumar',
        tenure: '2022 - Present',
        badge: 'Current PM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
      ),
      const NationalLeader(
        title: 'PRIME MINISTER',
        name: 'Dr. Manmohan Singh',
        tenure: '2004 - 2014',
        badge: 'Former PM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Manmohan_Singh_%28cropped%29.jpg/800px-Manmohan_Singh_%28cropped%29.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
      ),
    ];

    // Defence Minister matching Screenshot 3
    final List<NationalLeader> defenceMinisters = [
      const NationalLeader(
        title: 'DEFENCE MINISTER',
        name: 'Shri D. K. Shivakumar',
        tenure: '2022 - Present',
        badge: 'Current PM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
      ),
      const NationalLeader(
        title: 'DEFENCE MINISTER',
        name: 'Shri Rajnath Singh',
        tenure: '2019 - Present',
        badge: 'Current DEM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Rajnath_Singh_in_2023.jpg/800px-Rajnath_Singh_in_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Bharatiya_Janata_Party_logo.svg/800px-Bharatiya_Janata_Party_logo.svg.png',
      ),
    ];

    // Home Minister matching Screenshot 3
    final List<NationalLeader> homeMinisters = [
      const NationalLeader(
        title: 'HOME MINISTER',
        name: 'Shri D. K. Shivakumar',
        tenure: '2022 - Present',
        badge: 'Current PM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
      ),
      const NationalLeader(
        title: 'HOME MINISTER',
        name: 'Shri Amit Shah',
        tenure: '2019 - Present',
        badge: 'Current HM',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
        partyLogo:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Bharatiya_Janata_Party_logo.svg/800px-Bharatiya_Janata_Party_logo.svg.png',
      ),
    ];

    // Other Cabinets matching Screenshot 4 (3 rows x 3 columns)
    final List<CabinetMinister> cabinets = country.otherCabinets.isNotEmpty
        ? country.otherCabinets
        : [
            // Row 1
            const CabinetMinister(
              firstName: 'H. D.',
              lastName: 'Revana',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
              backgroundColor: Color(0xFFFF5252),
            ),
            const CabinetMinister(
              firstName: 'Amit',
              lastName: 'Shah',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
              backgroundColor: Color(0xFFFFB74D),
            ),
            const CabinetMinister(
              firstName: 'Kunal',
              lastName: 'Tilak',
              imageUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
              backgroundColor: Color(0xFFCFD8DC),
            ),
            // Row 2
            const CabinetMinister(
              firstName: 'H. D.',
              lastName: 'Revana',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
              backgroundColor: Color(0xFFFF5252),
            ),
            const CabinetMinister(
              firstName: 'Amit',
              lastName: 'Shah',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
              backgroundColor: Color(0xFFFFB74D),
            ),
            const CabinetMinister(
              firstName: 'Kunal',
              lastName: 'Tilak',
              imageUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
              backgroundColor: Color(0xFFCFD8DC),
            ),
            // Row 3
            const CabinetMinister(
              firstName: 'H. D.',
              lastName: 'Revana',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
              backgroundColor: Color(0xFFFF5252),
            ),
            const CabinetMinister(
              firstName: 'Amit',
              lastName: 'Shah',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
              backgroundColor: Color(0xFFFFB74D),
            ),
            const CabinetMinister(
              firstName: 'Kunal',
              lastName: 'Tilak',
              imageUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
              backgroundColor: Color(0xFFCFD8DC),
            ),
          ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.016,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================================
          // [OVERVIEW PARAGRAPH & READ MORE] Matches Screenshot 1
          // ==================================================================
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
                TextSpan(
                  text: '$countryName, ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: descriptionText.startsWith(countryName)
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

          // ==================================================================
          // [6 KEY CIVIC DETAIL ROWS WITH ICONS] Matches Screenshot 1
          // ==================================================================
          // 1. CAPITAL
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.capitalIcon,
              width: screenWidth * 0.058,
              height: screenWidth * 0.058,
            ),
            label: CountryPageData.capital,
            value: country.capital?.isNotEmpty == true
                ? country.capital!
                : (isIndia ? 'New Delhi' : '-'),
          ),

          // 2. NATIONAL ANTHEM
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.nationalAnthemIcon,
              width: screenWidth * 0.058,
              height: screenWidth * 0.058,
            ),
            label: CountryPageData.nationalAnthem,
            value: country.nationalAnthem?.isNotEmpty == true
                ? country.nationalAnthem!
                : (isIndia ? 'JANA GANA MANA' : '-'),
          ),

          // 3. POPULATION
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.populationIcon,
              width: screenWidth * 0.058,
              height: screenWidth * 0.058,
            ),
            label: CountryPageData.population,
            value: country.population?.isNotEmpty == true
                ? country.population!
                : (isIndia ? '145.09 crores (2024)' : '-'),
          ),

          // 4. PRESIDENT
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.presidentIcon,
              width: screenWidth * 0.058,
              height: screenWidth * 0.058,
            ),
            label: CountryPageData.president,
            value: country.president?.isNotEmpty == true
                ? country.president!
                : (isIndia ? 'Droupadi Murmu' : '-'),
          ),

          // 5. PRIME MINISTER
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.primeMinisterIcon,
              width: screenWidth * 0.058,
              height: screenWidth * 0.058,
            ),
            label: CountryPageData.primeMinister,
            value: country.primeMinister?.isNotEmpty == true
                ? country.primeMinister!
                : (isIndia ? 'Shri Narendra Modi' : '-'),
          ),

          // 6. DATE OF INDEPENDENCE
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.dateOfIndependenceIcon,
              width: screenWidth * 0.055,
              height: screenWidth * 0.055,
            ),
            label: CountryPageData.dateOfIndependence,
            value: country.independenceDay?.isNotEmpty == true &&
                    formatCountryDate(country.independenceDay) != '-'
                ? formatCountryDate(country.independenceDay)
                : (isIndia ? '15 August 1947' : '-'),
          ),

          // Divider before leadership sections
          Divider(
            thickness: 1,
            color: const Color(0xFFEEEEEE),
            height: screenHeight * 0.04,
          ),

          // ==================================================================
          // [PRESIDENTS OF INDIA] Matches Screenshot 2
          // ==================================================================
          _buildLeaderHorizontalSection(
            title: isIndia
                ? 'PRESIDENTS OF INDIA'
                : 'PRESIDENTS OF ${country.name.toUpperCase()}',
            leaders: presidents,
            showPartyLogo: false, // President is non-partisan
          ),

          Divider(
            thickness: 1,
            color: const Color(0xFFEEEEEE),
            height: screenHeight * 0.04,
          ),

          // ==================================================================
          // [PRIME MINISTER] Matches Screenshot 2 & 3
          // ==================================================================
          _buildLeaderHorizontalSection(
            title: 'PRIME MINISTER',
            leaders: primeMinisters,
            showPartyLogo: true,
          ),

          Divider(
            thickness: 1,
            color: const Color(0xFFEEEEEE),
            height: screenHeight * 0.04,
          ),

          // ==================================================================
          // [DEFENCE MINISTER] Matches Screenshot 3
          // ==================================================================
          _buildLeaderHorizontalSection(
            title: 'DEFENCE MINISTER',
            leaders: defenceMinisters,
            showPartyLogo: true,
          ),

          Divider(
            thickness: 1,
            color: const Color(0xFFEEEEEE),
            height: screenHeight * 0.04,
          ),

          // ==================================================================
          // [HOME MINISTER] Matches Screenshot 3
          // ==================================================================
          _buildLeaderHorizontalSection(
            title: 'HOME MINISTER',
            leaders: homeMinisters,
            showPartyLogo: true,
          ),

          Divider(
            thickness: 1,
            color: const Color(0xFFEEEEEE),
            height: screenHeight * 0.04,
          ),

          // ==================================================================
          // [OTHER CABINATE] Matches Screenshot 4
          // ==================================================================
          _buildOtherCabinetsSection(cabinets),
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: LEADERSHIP HORIZONTAL SECTION] Matches Screenshot 2 & 3
  // Sized strictly using MediaQuery without hardcoded dimensions,
  // matching Figma specs: 280w x 339h image, 280w x 396h card, 20px radius.
  // ==========================================================================
  Widget _buildLeaderHorizontalSection({
    required String title,
    required List<NationalLeader> leaders,
    bool showPartyLogo = true,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive scaling strictly based on MediaQuery:
    // Reference screen width 375px with 280px card gives factor 280 / 375 ≈ 0.7467
    final double cardWidth = screenWidth * (280.0 / 375.0);
    // Exact proportional image height matching Figma 280w x 339h
    final double cardImageHeight = cardWidth * (339.0 / 280.0);
    // Exact proportional total card list height matching Figma 280w x 396h
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
        Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.034,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        SizedBox(height: screenHeight * 0.016),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
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
                            child: buildImageWidget(
                              leader.imageUrl,
                              fit: BoxFit.cover,
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
                    // Below image: Party Logo (if applicable) and Name + Tenure in GREEN
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
  // [BUILD METHOD: OTHER CABINATE] Matches Screenshot 4
  // ==========================================================================
  Widget _buildOtherCabinetsSection(List<CabinetMinister> cabinets) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
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
            Icon(Icons.arrow_forward, size: screenWidth * 0.046, color: const Color(0xFFFE3A31)),
          ],
        ),
        SizedBox(height: screenHeight * 0.016),
        GridView.builder(
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
                      child: buildImageWidget(
                        minister.imageUrl,
                        fit: BoxFit.cover,
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
    );
  }

  // ==========================================================================
  // [BUILD METHOD: FLAG / EMBLEM TAB]
  // ==========================================================================
  Widget _buildPlacesAndSymbolsTab(CountryModel country) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final bool isIndia = country.name.toLowerCase().contains('india') ||
        country.name.isEmpty ||
        country.registrationCode == 'IND';

    // 1. Dynamic Backend Lookup: Extract symbols provided by the backend API
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
    // Fallback order if kind was not explicitly specified
    if (flagSymbol == null && country.symbols.isNotEmpty) {
      flagSymbol = country.symbols.first;
    }
    if (emblemSymbol == null && country.symbols.length > 1) {
      emblemSymbol = country.symbols[1];
    }

    // 2. Dynamic Description from Backend (Symbols -> Culture -> Info -> Default)
    final String? backendDesc = (flagSymbol?.description?.trim().isNotEmpty == true)
        ? flagSymbol!.description
        : ((emblemSymbol?.description?.trim().isNotEmpty == true)
            ? emblemSymbol!.description
            : (country.cultureAndTradition?.trim().isNotEmpty == true
                ? country.cultureAndTradition
                : (country.info?.trim().isNotEmpty == true ? country.info : null)));

    final String flagDesc = backendDesc ??
        'The national flag of India, popularly known as the Tiranga (Tricolour), is a horizontal rectangular flag featuring three colors — India saffron, white, and India green — with the navy-blue Ashoka Chakra in the centre.';

    // 3. Dynamic Image URLs from Backend
    final String flagUrl = flagSymbol?.urls.firstWhere(
          (u) => u.trim().isNotEmpty,
          orElse: () => '',
        ) ?? '';
    final String emblemUrl = emblemSymbol?.urls.firstWhere(
          (u) => u.trim().isNotEmpty,
          orElse: () => '',
        ) ?? '';

    // 4. Dynamic Labels from Backend
    final String flagLabel = (flagSymbol?.label?.trim().isNotEmpty == true)
        ? flagSymbol!.label!
        : (isIndia ? 'Indian Flag' : (country.name.isNotEmpty ? '${country.name} Flag' : 'Flag'));

    final String emblemLabel = (emblemSymbol?.label?.trim().isNotEmpty == true)
        ? emblemSymbol!.label!
        : (isIndia ? 'Indian Emblem' : (country.name.isNotEmpty ? '${country.name} Emblem' : 'Emblem'));

    // 5. Proportional MediaQuery Dimensions matching exact Figma specs (180x180 & 180x193 on 375w reference)
    final double flagWidth = w * (180.0 / 375.0);
    final double flagHeight = flagWidth * (180.0 / 180.0); // 180 into 180

    final double emblemWidth = w * (180.0 / 375.0);
    final double emblemHeight = emblemWidth * (193.0 / 180.0); // 180 into 193

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.018,
      ),
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

          // 2. Centered Indian Flag (180 into 180 with MediaQuery)
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

          // 3. Centered State Emblem (180 into 193 with MediaQuery)
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

          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }

  Widget _buildFlagImageWidget(String rawUrl, double width, double height) {
    final url = rawUrl.trim();
    // 1. If backend provides a valid URL, load via universal buildImageWidget
    if (url.isNotEmpty && !url.toLowerCase().contains('wikimedia.org')) {
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
    // 2. High-res vector fallback asset
    return ClipRRect(
      borderRadius: BorderRadius.circular(width * (8.0 / 180.0)),
      child: SvgPicture.asset(
        CountryPageData.indianFlagSvg,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildEmblemImageWidget(String rawUrl, double width, double height) {
    final url = rawUrl.trim();
    // 1. If backend provides a valid URL, load via universal buildImageWidget
    if (url.isNotEmpty && !url.toLowerCase().contains('wikimedia.org')) {
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
    // 2. High-res raster fallback asset
    return Image.asset(
      CountryPageData.indianEmblemPng,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  // ==========================================================================
  // [BUILD METHOD: GEOGRAPHIC TAB]
  // ==========================================================================
  Widget _buildGeographicTabContent(CountryModel country) {
    return GeographicTabSection(country: country);
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
// Responsive Geographic & Administrative Profile Section matching reference image
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

  static const String _defaultKarnatakaDescription =
      "**Karnataka** has **31 districts**, organized into multiple divisions for administration. Geographically, the state is divided into three main regions-the coastal plains (Karavali), the hilly Western Ghats (Malnad), and the inland Deccan Plateau.\n\n"
      "The coastal region lies along the Arabian Sea and receives heavy rainfall, while the Western Ghats are rich in forests and biodiversity. The eastern part forms the Deccan Plateau, which is relatively dry with rolling plains.\n\n"
      "Major rivers such as the Krishna River and Cauvery River flow through the state, supporting agriculture and water supply. Karnataka's varied geography gives it a mix of climates, from humid coastal weather to semi-arid inland conditions.\n\n"
      "Karnataka is grouped into four administrative divisions **Bengaluru**, **Mysuru**, **Belagavi**, and **Kalaburagi** which help in efficient governance.";

  String _formatArea(String? area, bool isIndia) {
    if (area != null && area.trim().isNotEmpty) {
      final a = area.trim();
      if (a.toLowerCase().contains('km') || a.toLowerCase().contains('sq')) {
        return a;
      }
      return '$a km2';
    }
    return isIndia ? '191,791 km2' : '-';
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
    final bool isIndia = widget.country.name.toLowerCase().contains('india') ||
        widget.country.name.isEmpty ||
        widget.country.registrationCode == 'IND' ||
        widget.country.registrationCode == 'KA';

    // 1. Description: API first, then fallback
    final String rawDescription = widget.country.geographicDescription?.trim().isNotEmpty == true
        ? widget.country.geographicDescription!
        : (widget.country.info?.trim().isNotEmpty == true
            ? widget.country.info!
            : _defaultKarnatakaDescription);

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

    // 2. Stats values from API with fallback matching the reference mockup
    final String areaValue = _formatArea(widget.country.area, isIndia);
    final String regCodeValue = widget.country.registrationCode?.isNotEmpty == true
        ? widget.country.registrationCode!
        : (isIndia ? 'KA' : '-');
    final String populationValue = widget.country.population?.isNotEmpty == true
        ? widget.country.population!
        : (isIndia ? '61,095,297' : '-');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.018,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width description paragraphs (no right-side gap)
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

          SizedBox(height: h * 0.035),

          // ── INTERACTIVE INDIA MAP SECTION (Level 1, Level 2, Level 3) ──
          IndiaMapWidget(
              initialSelectedState: widget.country.registrationCode == 'KA' ? 'Karnataka' : null,
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
