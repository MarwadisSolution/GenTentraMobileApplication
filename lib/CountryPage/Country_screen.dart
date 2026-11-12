// Country Profile Screen
// Vertically scrollable civic information page with smooth DraggableScrollableSheet
// matching the exact visual hierarchy and smooth scroll physics of PartyFetchedData.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Favourite/favourite_api.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';
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
      backgroundColor: const Color(0xFFEBEBEB),
      body: BlocConsumer<CountryProfileBloc, CountryProfileState>(
        listener: (context, state) {
          if (state is CountryProfileErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message.isNotEmpty
                      ? state.message
                      : 'Unable to load profile data',
                ),
                backgroundColor: const Color(0xFFFE3A31),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'RETRY',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<CountryProfileBloc>().add(
                          FetchCountryProfileEvent(widget.countryId),
                        );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          // Loading State
          if (state is CountryProfileLoadingState) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorScheme.of(context).onSurface,
              ),
            );
          }

          // Error State with fallback
          if (state is CountryProfileErrorState && state.cachedCountry == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: screenWidth * 0.16,
                      color: const Color(0xFFFE3A31),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Failed to load data',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CountryProfileBloc>().add(
                              FetchCountryProfileEvent(widget.countryId),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE3A31),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.014,
                        ),
                      ),
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Loaded State
          if (state is CountryProfileLoadedState && state.country != null) {
            return _buildLoadedContent(state.country!, screenHeight);
          }

          // Fallback if cached country is present during error
          if (state is CountryProfileErrorState && state.cachedCountry != null) {
            return _buildLoadedContent(state.cachedCountry!, screenHeight);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ==========================================================================
  // [BUILD METHOD: LOADED CONTENT - Matching Party Page scroll physics]
  // ==========================================================================
  Widget _buildLoadedContent(CountryModel country, double screenHeight) {
    final double defaultSheetRatio = (screenHeight < 500)
        ? 0.45
        : (screenHeight < 800)
            ? 0.28
            : (screenHeight < 900)
                ? 0.247
                : (218.0 / screenHeight).clamp(0.1, 0.85);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double fabSize = screenWidth * (62.0 / 375.0);

    // Initialize FAB position to bottom right with safe area padding
    _draggableFabPosition ??= Offset(
      screenWidth - fabSize - screenWidth * 0.05,
      screenHeight - fabSize - MediaQuery.of(context).padding.bottom - screenHeight * 0.06,
    );

    return Stack(
      children: [
        // ====================================================================
        // [LAYER 1: FULL SCREEN BANNER WITH PROGRESSIVE BLUR]
        // ====================================================================
        ValueListenableBuilder<double>(
          valueListenable: _sheetProgress,
          builder: (context, progress, child) {
            return CountryBannerSection(
              banners: country.bannerImages,
              countryName: country.name,
              progress: progress,
            );
          },
        ),

        // Back button on top left of banner
        Positioned(
          top: MediaQuery.of(context).padding.top + screenHeight * 0.01,
          left: screenWidth * 0.03,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
        ),

        // ====================================================================
        // [LAYER 2: DRAGGABLE SCROLLABLE SHEET - Exact Party Page physics]
        // ====================================================================
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

                  if (notification is UserScrollNotification && _isUserScrolling) {
                    if (notification.direction == ScrollDirection.reverse) {
                      if (_showCountryDetails.value) {
                        _showCountryDetails.value = false;
                      }
                    } else if (notification.direction == ScrollDirection.forward) {
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: screenWidth * 0.03,
                        offset: Offset(0, -screenHeight * 0.005),
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Country Details Section (Collapsible Header with smooth AnimatedSize)
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
                              CountryDetailsSection(country: country),
                              Container(
                                height: screenWidth * (6.0 / 375.0),
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
                        delegate: SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            onTap: (index) {
                              _selectedTabIndex.value = index;
                            },
                            tabAlignment: TabAlignment.center,
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                            ),
                            isScrollable: true,
                            labelStyle: TextStyle(
                              fontSize: screenWidth * 0.037,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: screenWidth * 0.037,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.25,
                            ),
                            labelColor: const Color(0xFF1E1E1E),
                            unselectedLabelColor: const Color(0xFF757575),
                            indicator: SmallTabIndicator(
                              color: const Color(0xFFFE3A31),
                              width: screenWidth * 0.055,
                              height: screenHeight * 0.0035,
                              borderRadius: BorderRadius.circular(screenWidth * 0.01),
                            ),
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

                      // Tab Body Content Routed Through Model & Data File
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
                                    child: _buildTabContent(
                                      index: 0,
                                      country: country,
                                    ),
                                  ),
                                  // Tab 1: FLAG / EMBLEM
                                  Offstage(
                                    offstage: selectedIndex != 1,
                                    child: _buildTabContent(
                                      index: 1,
                                      country: country,
                                    ),
                                  ),
                                  // Tab 2: GEOGRAPHIC
                                  Offstage(
                                    offstage: selectedIndex != 2,
                                    child: _buildTabContent(
                                      index: 2,
                                      country: country,
                                    ),
                                  ),
                                  // Tab 3: PLACES TO VISIT
                                  Offstage(
                                    offstage: selectedIndex != 3,
                                    child: _buildTabContent(
                                      index: 3,
                                      country: country,
                                    ),
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
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFE3A31),
                    Color(0xFFFF6B4A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFE3A31).withValues(alpha: 0.38),
                    blurRadius: screenWidth * 0.035,
                    offset: Offset(0, screenHeight * 0.006),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  CountryPageData.orangeButtonLogo,
                  width: fabSize * 0.52,
                  height: fabSize * 0.52,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // [TAB ROUTING HELPER - Routed via CountryPageData / Model exactly like Party]
  // ==========================================================================
  Widget _buildTabContent({
    required int index,
    required CountryModel country,
  }) {
    return CountryPageData.buildTabContent(
      index: index,
      country: country,
    );
  }
}

// ============================================================================
// [COUNTRY BANNER SECTION]
// ============================================================================
class CountryBannerSection extends StatefulWidget {
  final List<String> banners;
  final String countryName;
  final double progress;

  const CountryBannerSection({
    super.key,
    required this.banners,
    required this.countryName,
    this.progress = 0.0,
  });

  @override
  State<CountryBannerSection> createState() => _CountryBannerSectionState();
}

class _CountryBannerSectionState extends State<CountryBannerSection> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> banners = widget.banners;
    final double progress = widget.progress.clamp(0.0, 1.0);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Animation values matching party banner exactly
    final double blur = progress * 8.0;
    final double darkOpacity = progress * 0.48;
    final double titleOpacity =
        ((progress - 0.15) / 0.45).clamp(0.0, 1.0);

    return SizedBox(
      height: screenHeight * 0.8,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner images with progressive blur
          if (banners.isEmpty)
            ColoredBox(
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: SvgPicture.asset(
                  "Assets/PartyPage/photoIcon.svg",
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFBDBDBD),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            )
          else
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blur,
                sigmaY: blur,
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() {
                      currentIndex = index;
                    });
                  }
                },
                itemBuilder: (context, index) {
                  final image = banners[index];
                  final imageUrl =
                      image.startsWith("/api/") ? "$api$image" : image;

                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return ColoredBox(
                        color: const Color(0xFFF5F5F5),
                        child: Center(
                          child: SvgPicture.asset(
                            "Assets/PartyPage/photoIcon.svg",
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFBDBDBD),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          // Darken the image as the sheet expands
          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              color: Colors.black.withValues(alpha: darkOpacity),
            ),
          ),

          // Fixed back arrow
          Positioned(
            top: screenHeight * 0.04,
            left: screenWidth * 0.05,
            child: SizedBox(
              width: screenWidth * 0.1,
              height: screenWidth * 0.1,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                child: Center(
                  child: Transform.rotate(
                    angle: 3.141592653589793,
                    child: SvgPicture.asset(
                      CountryPageData.arrow,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      height: screenWidth * 0.035,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Country Name in header bar (fades in as bottom sheet scrolls up)
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05 + screenWidth * 0.13,
            right: screenWidth * 0.05,
            child: Opacity(
              opacity: titleOpacity,
              child: Transform.translate(
                offset: Offset(
                  0,
                  screenHeight * 0.022 * (1 - titleOpacity),
                ),
                child: Text(
                  widget.countryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Banner page indicator dots
          if (banners.length > 1)
            Positioned(
              top: screenHeight * 0.68,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 1 - progress * 0.7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                    (index) {
                      final bool isSelected = currentIndex == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        height: screenWidth * 0.024,
                        width: screenWidth * 0.024,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected
                              ? GradientColors.primaryGradient
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          border: Border.all(
                            color: Colors.red,
                            width: screenWidth * 0.0025,
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
    );
  }
}

// ============================================================================
// [COUNTRY DETAILS SECTION]
// ============================================================================
class CountryDetailsSection extends StatefulWidget {
  final CountryModel country;

  const CountryDetailsSection({
    super.key,
    required this.country,
  });

  @override
  State<CountryDetailsSection> createState() => _CountryDetailsSectionState();
}

class _CountryDetailsSectionState extends State<CountryDetailsSection> {
  final FavouriteApi _favouriteApi = FavouriteApi();
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavouriteStatus();
  }

  @override
  void didUpdateWidget(covariant CountryDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country.id != widget.country.id) {
      _loadFavouriteStatus();
    }
  }

  Future<void> _loadFavouriteStatus() async {
    final int id = widget.country.id > 0 ? widget.country.id : 1;
    try {
      final favouriteIds =
          await _favouriteApi.getFavouritePartyIds("COUNTRY");
      if (mounted) {
        setState(() {
          favorite = favouriteIds.contains(id);
        });
      }
    } catch (e) {
      debugPrint("loadFavouriteStatus error: $e");
    }
  }

  Future<void> _toggleFavourite() async {
    final int id = widget.country.id > 0 ? widget.country.id : 1;

    // Instant optimistic toggle matching Party & Leadership pages
    final bool newFavorite = !favorite;
    setState(() {
      favorite = newFavorite;
    });

    try {
      if (newFavorite) {
        await _favouriteApi.postFavourite(id, "COUNTRY");
      } else {
        await _favouriteApi.deleteFavourite(id, "COUNTRY");
      }
    } catch (e) {
      debugPrint("Toggle favourite error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final String countryTitle = widget.country.name.trim().isNotEmpty
        ? widget.country.name.trim()
        : 'Country';

    final String capitalText = widget.country.capital != null &&
            widget.country.capital!.trim().isNotEmpty
        ? widget.country.capital!.trim()
        : '-';

    final bool isState = widget.country.registrationCode != null &&
        widget.country.registrationCode!.trim().isNotEmpty &&
        widget.country.registrationCode != 'IND' &&
        widget.country.registrationCode != 'IN';

    final String statesValue = widget.country.statesCount?.trim().isNotEmpty == true
        ? widget.country.statesCount!.trim()
        : '-';

    final String utValue = widget.country.unionTerritories != null
        ? widget.country.unionTerritories!.toString().padLeft(2, '0')
        : '-';

    final String stateCodeValue = widget.country.numericCode != null
        ? widget.country.numericCode.toString()
        : '-';

    final String regCodeValue = widget.country.registrationCode?.trim().isNotEmpty == true
        ? widget.country.registrationCode!.trim()
        : '-';

    return Container(
      padding: EdgeInsets.only(
        top: h * 0.015,
        left: w * 0.05,
        right: w * 0.05,
        bottom: h * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.064)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: Country name on the left, Favorite Heart on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  countryTitle,
                  style: TextStyle(
                    fontSize: w * 0.048,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              InkWell(
                onTap: _toggleFavourite,
                borderRadius: BorderRadius.circular(w * 0.05),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.01),
                  child: SvgPicture.asset(
                    CountryPageData.favoriteIcon,
                    height: w * 0.06,
                    colorFilter: favorite
                        ? const ColorFilter.mode(
                            Color(0xFFFF2164),
                            BlendMode.srcIn,
                          )
                        : const ColorFilter.mode(
                            Color(0xFF666666),
                            BlendMode.srcIn,
                          ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.005),
          Text(
            "Capital City - $capitalText",
            style: TextStyle(
              fontSize: w * 0.033,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF757575),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: h * 0.018),

          // Stats Row: DISTRICTS/STATES, STATE CODE/UT, REGISTRATION with vertical separators
          if (isState)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Districts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISTRICTS',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: w * 0.026,
                        letterSpacing: 0.5,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      statesValue,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.055,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
                // Thin vertical divider line
                Container(
                  height: h * 0.045,
                  width: w * 0.003,
                  color: const Color(0xFFE0E0E0),
                  margin: EdgeInsets.symmetric(horizontal: w * 0.05),
                ),
                // State Code
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATE CODE',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: w * 0.026,
                        letterSpacing: 0.5,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      stateCodeValue,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.055,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
                // Thin vertical divider line
                Container(
                  height: h * 0.045,
                  width: w * 0.003,
                  color: const Color(0xFFE0E0E0),
                  margin: EdgeInsets.symmetric(horizontal: w * 0.05),
                ),
                // Registration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGISTRATION',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: w * 0.026,
                        letterSpacing: 0.5,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      regCodeValue,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.055,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // States
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CountryPageData.states,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: w * 0.028,
                        letterSpacing: 0.5,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      statesValue,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.058,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
                // Thin vertical divider line
                Container(
                  height: h * 0.052,
                  width: w * 0.003,
                  color: const Color(0xFFE0E0E0),
                  margin: EdgeInsets.symmetric(horizontal: w * 0.07),
                ),
                // Union Territories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CountryPageData.unionTerritories,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: w * 0.028,
                        letterSpacing: 0.5,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: h * 0.003),
                    Text(
                      utValue,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: w * 0.058,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
