import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Favourite/favourite_api.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_Flag_Page.dart';
import 'Country_Geo_Page.dart';
import 'Country_PlacesToVisit_Page.dart';
import 'Country_api.dart';
import 'Country_model.dart';
import 'Country_page_data.dart';
import 'Country_screen.dart';
import 'State_Info_Page.dart';
import 'State_bloc.dart';
import 'State_event.dart';
import 'State_model.dart';
import 'State_state.dart';
import 'reusable_functions.dart';

class StateProfileScreen extends StatelessWidget {
  final int stateId;
  final String? stateName;

  const StateProfileScreen({
    super.key,
    int? stateId,
    String? stateName,
    String? name,
  })  : stateId = stateId ?? 10,
        stateName = stateName ?? name;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StateProfileBloc>(
      create: (context) => StateProfileBloc(
        repository: CountryProfileRepository(),
      )..add(FetchStateProfileEvent(stateId)),
      child: _StateProfileView(
        stateId: stateId,
        initialName: stateName,
      ),
    );
  }
}

class _StateProfileView extends StatefulWidget {
  final int stateId;
  final String? initialName;

  const _StateProfileView({
    required this.stateId,
    this.initialName,
  });

  @override
  State<_StateProfileView> createState() => _StateProfileViewState();
}

class _StateProfileViewState extends State<_StateProfileView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);
  final ValueNotifier<double> _sheetProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _showStateDetails = ValueNotifier<bool>(true);
  bool _isUserScrolling = false;
  late final ValueNotifier<Offset?> _draggableFabPosition = ValueNotifier<Offset?>(null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );

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
    _showStateDetails.dispose();
    _draggableFabPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: BlocConsumer<StateProfileBloc, StateProfileState>(
        listener: (context, state) {
          if (state.isFailure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFFE3A31),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context
                        .read<StateProfileBloc>()
                        .add(FetchStateProfileEvent(widget.stateId));
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Stack(
              children: [
                if (widget.initialName != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFE3A31),
                  ),
                ),
              ],
            );
          }

          if (state.isFailure) {
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
                      state.errorMessage ?? 'Failed to load state profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (screenWidth * (16.0 / 375.0)).clamp(15.0, 18.0),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<StateProfileBloc>()
                            .add(FetchStateProfileEvent(widget.stateId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE3A31),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.isSuccess && state.state != null) {
            return _buildLoadedContent(state.state!, screenHeight);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedContent(StateModel state, double screenHeight) {
    final double defaultSheetRatio = (screenHeight < 500)
        ? 0.45
        : (screenHeight < 800)
            ? 0.28
            : (screenHeight < 900)
                ? 0.247
                : (218.0 / screenHeight).clamp(0.1, 0.85);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double fabSize = screenWidth * (62.0 / 375.0);

    _draggableFabPosition.value ??= Offset(
      screenWidth - fabSize - screenWidth * 0.05,
      screenHeight - fabSize - MediaQuery.of(context).padding.bottom - screenHeight * 0.06,
    );

    final countryRepresentation = state.toCountryModel();

    return Stack(
      children: [
        // 1. Parallax Banner
        ValueListenableBuilder<double>(
          valueListenable: _sheetProgress,
          builder: (context, progress, child) {
            return CountryBannerSection(
              banners: state.bannerImages.isNotEmpty
                  ? state.bannerImages
                  : const [
                      'https://gentantrabackend-production.up.railway.app/api/v1/public/media/0b8c4436-9087-485a-adbf-5d08a5ed106a',
                      'https://gentantrabackend-production.up.railway.app/api/v1/public/media/752a753c-98ce-4184-9fdc-bd0d50d16637',
                    ],
              countryName: state.name,
              progress: progress,
            );
          },
        ),

        // 2. Draggable Bottom Sheet
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
                      if (_showStateDetails.value) {
                        _showStateDetails.value = false;
                      }
                    } else if (notification.direction == ScrollDirection.forward) {
                      if (!_showStateDetails.value) {
                        _showStateDetails.value = true;
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
                      // Collapsible State Details Header
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _showStateDetails,
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
                              StateDetailsSection(state: state),
                              Container(
                                height: screenWidth * (6.0 / 375.0),
                                width: double.infinity,
                                color: const Color(0xFFEBEBEB),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Pinned Tab Bar
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
                              fontSize: (screenWidth * (14.0 / 375.0)).clamp(13.0, 15.0),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: (screenWidth * (14.0 / 375.0)).clamp(13.0, 15.0),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.25,
                            ),
                            labelColor: const Color(0xFF1E1E1E),
                            unselectedLabelColor: const Color(0xFF757575),
                            indicator: SmallTabIndicator(
                              color: const Color(0xFFFE3A31),
                              width: screenWidth * (42.0 / 375.0),
                              height: screenHeight * (4.0 / 812.0),
                              borderRadius: BorderRadius.circular(screenWidth * (2.0 / 375.0)),
                            ),
                            dividerColor: ColorScheme.of(context)
                                .onSurface
                                .withValues(alpha: 0.2),
                            tabs: const [
                              Tab(text: 'INFO'),
                              Tab(text: 'STATE/EMBLEM'),
                              Tab(text: 'PLACES TO VISIT'),
                              Tab(text: 'GEOGRAPHIC'),
                            ],
                          ),
                          dividerHeight: 0,
                        ),
                      ),

                      // Tab Contents
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          child: ValueListenableBuilder<int>(
                            valueListenable: _selectedTabIndex,
                            builder: (context, selectedIndex, child) {
                              return Stack(
                                children: [
                                  Offstage(
                                    offstage: selectedIndex != 0,
                                    child: StateInfoPage(state: state),
                                  ),
                                  Offstage(
                                    offstage: selectedIndex != 1,
                                    child: CountryFlagPage(country: countryRepresentation),
                                  ),
                                  Offstage(
                                    offstage: selectedIndex != 2,
                                    child: CountryPlacesToVisitPage(
                                      country: countryRepresentation,
                                      isActive: selectedIndex == 2,
                                    ),
                                  ),
                                  Offstage(
                                    offstage: selectedIndex != 3,
                                    child: CountryGeoPage(country: countryRepresentation),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 3. Draggable Orange Floating Action Button
        ValueListenableBuilder<Offset?>(
          valueListenable: _draggableFabPosition,
          builder: (context, pos, child) {
            if (pos == null) return const SizedBox.shrink();
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final double minX = screenWidth * 0.02;
                  final double maxX = screenWidth - fabSize - screenWidth * 0.02;
                  final double minY = MediaQuery.of(context).padding.top + screenHeight * 0.02;
                  final double maxY = screenHeight - fabSize - MediaQuery.of(context).padding.bottom - screenHeight * 0.02;

                  _draggableFabPosition.value = Offset(
                    (pos.dx + details.delta.dx).clamp(minX, maxX),
                    (pos.dy + details.delta.dy).clamp(minY, maxY),
                  );
                },
                onTap: () {
                  // On state page, tapping toggles to geographic or pops back
                  if (_tabController.index != 3) {
                    _tabController.animateTo(3);
                  } else {
                    Navigator.pop(context);
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
            );
          },
        ),
      ],
    );
  }
}

class StateDetailsSection extends StatefulWidget {
  final StateModel state;

  const StateDetailsSection({
    super.key,
    required this.state,
  });

  @override
  State<StateDetailsSection> createState() => _StateDetailsSectionState();
}

class _StateDetailsSectionState extends State<StateDetailsSection> {
  final FavouriteApi _favouriteApi = FavouriteApi();
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavouriteStatus();
  }

  @override
  void didUpdateWidget(covariant StateDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.id != widget.state.id) {
      _loadFavouriteStatus();
    }
  }

  Future<void> _loadFavouriteStatus() async {
    final int id = widget.state.id > 0 ? widget.state.id : 10;
    try {
      final favouriteIds = await _favouriteApi.getFavouritePartyIds("STATE");
      if (mounted) {
        setState(() {
          favorite = favouriteIds.contains(id);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFavourite() async {
    final int id = widget.state.id > 0 ? widget.state.id : 10;
    final bool newFavorite = !favorite;
    setState(() {
      favorite = newFavorite;
    });

    try {
      if (newFavorite) {
        await _favouriteApi.postFavourite(id, "STATE");
      } else {
        await _favouriteApi.deleteFavourite(id, "STATE");
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final String stateName = widget.state.name.trim().isNotEmpty
        ? widget.state.name.trim()
        : 'Karnataka';

    final String nativeName = widget.state.nativeName?.trim().isNotEmpty == true
        ? widget.state.nativeName!.trim()
        : (stateName.toLowerCase().contains('karnataka') ? 'ಕರ್ನಾಟಕ' : '');

    final String titleDisplay = nativeName.isNotEmpty
        ? "$stateName - $nativeName"
        : stateName;

    final String capitalCity = widget.state.capital?.trim().isNotEmpty == true
        ? widget.state.capital!.trim()
        : 'Bengaluru';

    final String districtsValue = widget.state.districtsCount?.trim().isNotEmpty == true
        ? widget.state.districtsCount!.trim()
        : '31';

    final String stateCodeValue = widget.state.code?.trim().isNotEmpty == true
        ? (widget.state.code!.length <= 2 && int.tryParse(widget.state.code!) != null
            ? widget.state.code!
            : '29')
        : '29';

    final String registrationValue = widget.state.code?.trim().isNotEmpty == true
        ? widget.state.code!.toUpperCase()
        : 'KA';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  titleDisplay,
                  style: TextStyle(
                    fontSize: (w * 0.052).clamp(18.0, 22.0),
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
            "Capital City - $capitalCity",
            style: TextStyle(
              fontSize: (w * (14.0 / 375.0)).clamp(13.0, 15.0),
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: h * 0.018),

          // 3 Stats: DISTRICTS | STATE CODE | REGISTRATION
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // DISTRICTS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DISTRICTS',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: (w * (11.0 / 375.0)).clamp(10.0, 12.0),
                      letterSpacing: 0.22,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: h * 0.003),
                  Text(
                    districtsValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: (w * (24.0 / 375.0)).clamp(20.0, 26.0),
                      letterSpacing: 0.3,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              Container(
                height: h * 0.045,
                width: w * 0.003,
                color: const Color(0xFFE0E0E0),
                margin: EdgeInsets.symmetric(horizontal: w * 0.05),
              ),
              // STATE CODE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATE CODE',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: (w * (11.0 / 375.0)).clamp(10.0, 12.0),
                      letterSpacing: 0.22,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: h * 0.003),
                  Text(
                    stateCodeValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: (w * (24.0 / 375.0)).clamp(20.0, 26.0),
                      letterSpacing: 0.3,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              Container(
                height: h * 0.045,
                width: w * 0.003,
                color: const Color(0xFFE0E0E0),
                margin: EdgeInsets.symmetric(horizontal: w * 0.05),
              ),
              // REGISTRATION
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REGISTRATION',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: (w * (11.0 / 375.0)).clamp(10.0, 12.0),
                      letterSpacing: 0.22,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: h * 0.003),
                  Text(
                    registrationValue,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: (w * (24.0 / 375.0)).clamp(20.0, 26.0),
                      letterSpacing: 0.3,
                      color: const Color(0xFF333333),
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
