// Country Profile Screen
// Complete, vertically scrollable mobile civic information page
// matching the exact visual hierarchy of the provided reference screens.

import 'package:flutter/material.dart';
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
  late final ScrollController _scrollController;
  late final PageController _bannerPageController;
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isCollapsed = ValueNotifier<bool>(false);
  int _currentBannerIndex = 0;
  bool _isInfoExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _scrollController = ScrollController();
    _bannerPageController = PageController();

    // Tab switch listener
    _tabController.addListener(() {
      if (!mounted) return;
      if (!_tabController.indexIsChanging) {
        _selectedTabIndex.value = _tabController.index;
      }
    });

    // Collapse listener: detect when banner has collapsed into pinned app bar
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final screenHeight = MediaQuery.of(context).size.height;
      final defaultSheetRatio = (screenHeight < 500)
          ? 0.45
          : (screenHeight < 800)
              ? 0.28
              : (screenHeight < 900)
                  ? 0.247
                  : (218.0 / screenHeight).clamp(0.1, 0.85);
      final bannerHeight = screenHeight * (1.0 - defaultSheetRatio);
      final collapsedHeight =
          kToolbarHeight + MediaQuery.of(context).padding.top;
      final threshold = bannerHeight - collapsedHeight - 30.0;
      final isNowCollapsed = _scrollController.offset > threshold;
      if (isNowCollapsed != _isCollapsed.value) {
        _isCollapsed.value = isNowCollapsed;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _bannerPageController.dispose();
    _selectedTabIndex.dispose();
    _isCollapsed.dispose();
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
                      size: 54,
                      color: Color(0xFFFE3A31),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      state.errorMessage ?? 'Failed to load country profile',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.06,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
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

    final double bannerHeight = screenHeight * (1.0 - defaultSheetRatio);
    final double topPadding = MediaQuery.of(context).padding.top;
    final double collapsedHeight = kToolbarHeight + topPadding;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // ====================================================================
        // [HERO BANNER SLIVER APP BAR]
        // ====================================================================
        SliverAppBar(
          pinned: true,
          stretch: true,
          elevation: 0,
          backgroundColor: Colors.white,
          expandedHeight: bannerHeight,
          collapsedHeight: collapsedHeight,
          leading: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.38),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 3.141592653589793,
                      child: SvgPicture.asset(
                        CountryPageData.arrow,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        height: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          title: ValueListenableBuilder<bool>(
            valueListenable: _isCollapsed,
            builder: (context, isCollapsed, _) {
              return AnimatedOpacity(
                opacity: isCollapsed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isIndia ? 'India - भारत' : country.name,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _bannerPageController,
                  itemCount: banners.length,
                  onPageChanged: (index) {
                    if (mounted) setState(() => _currentBannerIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final image = banners[index];
                    final imageUrl =
                        image.startsWith('/api/') ? '$api$image' : image;
                    return buildImageWidget(imageUrl, fit: BoxFit.cover);
                  },
                ),

                // Top Gradient for back button clarity
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Banner indicator dots matching Screenshot 1
                if (banners.length > 1)
                  Positioned(
                    bottom: 30,
                    right: 28,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(banners.length, (index) {
                        final isSelected = _currentBannerIndex == index;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 7,
                          width: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFFE3A31)
                                : Colors.black.withOpacity(0.35),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 1,
                                  ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ====================================================================
        // [OVERLAPPING COUNTRY IDENTITY CARD]
        // ====================================================================
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 8,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: CountryDetailsSection(country: country),
          ),
        ),

        // ====================================================================
        // [PINNED TAB BAR] Matches Screenshot 1
        // ====================================================================
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 18),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              labelColor: const Color(0xFF1E1E1E),
              unselectedLabelColor: const Color(0xFF757575),
              indicatorColor: const Color(0xFFFE3A31),
              indicatorWeight: 2.5,
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

        // ====================================================================
        // [TAB BODY CONTENT]
        // ====================================================================
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF333333),
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
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              setState(() => _isInfoExpanded = !_isInfoExpanded);
            },
            child: Text(
              _isInfoExpanded ? 'READ LESS' : 'READ MORE',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFE3A31),
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ==================================================================
          // [6 KEY CIVIC DETAIL ROWS WITH ICONS] Matches Screenshot 1
          // ==================================================================
          // 1. CAPITAL
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.capitalIcon,
              width: 22,
              height: 22,
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
              width: 22,
              height: 22,
            ),
            label: CountryPageData.nationalAnthem,
            value: country.nationalAnthem?.isNotEmpty == true
                ? country.nationalAnthem!
                : (isIndia ? 'JANA GANA MANA' : '-'),
          ),

          // 3. POPULATION with Map Floating Action Button on right
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.populationIcon,
              width: 22,
              height: 22,
            ),
            label: CountryPageData.population,
            value: country.population?.isNotEmpty == true
                ? country.population!
                : (isIndia ? '145.09 crores (2024)' : '-'),
            trailing: GestureDetector(
              onTap: () {
                _tabController.animateTo(2); // Switches to GEOGRAPHIC tab
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFE3A31),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFE3A31).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    CountryPageData.orangeButtonLogo,
                    width: 21,
                    height: 21,
                  ),
                ),
              ),
            ),
          ),

          // 4. PRESIDENT
          _buildCivicDetailRow(
            icon: SvgPicture.asset(
              CountryPageData.presidentIcon,
              width: 22,
              height: 22,
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
              width: 22,
              height: 22,
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
              width: 20,
              height: 20,
            ),
            label: CountryPageData.dateOfIndependence,
            value: country.independenceDay?.isNotEmpty == true &&
                    formatCountryDate(country.independenceDay) != '-'
                ? formatCountryDate(country.independenceDay)
                : (isIndia ? '15 August 1947' : '-'),
          ),

          // Divider before leadership sections
          const Divider(thickness: 1, color: Color(0xFFEEEEEE), height: 36),

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

          const Divider(thickness: 1, color: Color(0xFFEEEEEE), height: 36),

          // ==================================================================
          // [PRIME MINISTER] Matches Screenshot 2 & 3
          // ==================================================================
          _buildLeaderHorizontalSection(
            title: 'PRIME MINISTER',
            leaders: primeMinisters,
            showPartyLogo: true,
          ),

          const Divider(thickness: 1, color: Color(0xFFEEEEEE), height: 36),

          // ==================================================================
          // [DEFENCE MINISTER] Matches Screenshot 3
          // ==================================================================
          _buildLeaderHorizontalSection(
            title: 'DEFENCE MINISTER',
            leaders: defenceMinisters,
            showPartyLogo: true,
          ),

          const Divider(thickness: 1, color: Color(0xFFEEEEEE), height: 36),

          // ==================================================================
          // [HOME MINISTER] Matches Screenshot 3
          // ==================================================================
          _buildLeaderHorizontalSection(
            title: 'HOME MINISTER',
            leaders: homeMinisters,
            showPartyLogo: true,
          ),

          const Divider(thickness: 1, color: Color(0xFFEEEEEE), height: 36),

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
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
  // ==========================================================================
  Widget _buildLeaderHorizontalSection({
    required String title,
    required List<NationalLeader> leaders,
    bool showPartyLogo = true,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Use MediaQuery for responsive dimensions while matching Figma spec (280w x 339h, radius 20)
    final double cardWidth = screenWidth < 360
        ? screenWidth * 0.75
        : (screenWidth < 420 ? 280.0 : (screenWidth * 0.70).clamp(280.0, 320.0));
    final double cardImageHeight = cardWidth * (339.0 / 280.0);
    const double cardRadius = 20.0;
    final double listHeight = cardImageHeight + 62.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 14),
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
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Image with rounded corners (radius 20) and translucent pill badge (280x339)
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
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  leader.badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Below image: Party Logo (if applicable) and Name + Tenure in GREEN
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showPartyLogo &&
                            leader.partyLogo != null &&
                            leader.partyLogo!.isNotEmpty) ...[
                          ClipOval(
                            child: Container(
                              width: 26,
                              height: 26,
                              color: Colors.white,
                              child: buildImageWidget(
                                leader.partyLogo!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leader.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                leader.tenure,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50), // Green tenure as shown in screenshot!
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'OTHER CABINATE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFF1E1E1E),
              ),
            ),
            Icon(Icons.arrow_forward, size: 18, color: Color(0xFFFE3A31)),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemCount: cabinets.length,
          itemBuilder: (context, index) {
            final minister = cabinets[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: minister.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: buildImageWidget(
                        minister.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  minister.firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  minister.lastName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
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

    final places = country.placesToVisit?.places ?? [];
    final symbols = country.symbols.isNotEmpty
        ? country.symbols
        : [
            const SymbolView(
              id: 1,
              kind: 'FLAG',
              label: 'National Flag of India (Tiranga)',
              urls: [
                'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/1200px-Flag_of_India.svg.png'
              ],
              downloadable: true,
            ),
            const SymbolView(
              id: 2,
              kind: 'EMBLEM',
              label: 'State Emblem of India (Lion Capital)',
              urls: [
                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Emblem_of_India.svg/800px-Emblem_of_India.svg.png'
              ],
              downloadable: true,
            ),
          ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSymbolsSection(symbols),
          if (places.isNotEmpty) ...[
            SizedBox(height: h * 0.035),
            _buildPlacesSection(country.placesToVisit!),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: GEOGRAPHIC TAB]
  // ==========================================================================
  Widget _buildGeographicTabContent(CountryModel country) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final bool isIndia = country.name.toLowerCase().contains('india') ||
        country.name.isEmpty ||
        country.registrationCode == 'IND';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.05,
        vertical: h * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(context, title: 'GEOGRAPHIC & ADMINISTRATIVE'),
          SizedBox(height: h * 0.015),
          Container(
            padding: EdgeInsets.all(w * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildGeographicRow('Country Name', isIndia ? 'India (भारत)' : country.name),
                Divider(height: h * 0.03),
                _buildGeographicRow('Capital City', country.capital ?? (isIndia ? 'New Delhi' : '-')),
                Divider(height: h * 0.03),
                _buildGeographicRow(
                  'Registration Code',
                  country.registrationCode ?? (isIndia ? 'IND' : '-'),
                ),
                Divider(height: h * 0.03),
                _buildGeographicRow(
                  'Numeric Code',
                  country.numericCode?.toString() ?? (isIndia ? '356' : '-'),
                ),
                Divider(height: h * 0.03),
                _buildGeographicRow(
                  'States',
                  country.statesCount ?? (isIndia ? '28' : '-'),
                ),
                Divider(height: h * 0.03),
                _buildGeographicRow(
                  'Union Territories',
                  country.unionTerritories?.toString() ?? (isIndia ? '8' : '-'),
                ),
                Divider(height: h * 0.03),
                _buildGeographicRow('Population', country.population ?? (isIndia ? '145.09 crores (2024)' : '-')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesSection(PlacesToVisit placesToVisit) {
    final h = MediaQuery.of(context).size.height;
    final places = placesToVisit.places;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(
          context,
          title: CountryPageData.placesToVisit,
          trailing: places.length > 2
              ? Text(
                  '${places.length} places',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF888888),
                  ),
                )
              : null,
        ),
        if (placesToVisit.description != null &&
            placesToVisit.description!.isNotEmpty) ...[
          SizedBox(height: h * 0.005),
          Text(
            placesToVisit.description!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: h * 0.015),
        ],
        if (places.isNotEmpty)
          SizedBox(
            height: h * 0.26,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: places.length,
              itemBuilder: (context, index) {
                return buildPlaceCard(context, places[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSymbolsSection(List<SymbolView> symbols) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(
          context,
          title: 'NATIONAL SYMBOLS & EMBLEMS',
          trailing: Text(
            '${symbols.length} symbols',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
            ),
          ),
        ),
        SizedBox(height: h * 0.012),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: w * 0.035,
            mainAxisSpacing: w * 0.035,
            childAspectRatio: 0.95,
          ),
          itemCount: symbols.length,
          itemBuilder: (context, index) {
            return buildSymbolCard(
              context,
              symbols[index],
              onDownload: (url) {
                downloadImage(url, context);
              },
            );
          },
        ),
      ],
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
