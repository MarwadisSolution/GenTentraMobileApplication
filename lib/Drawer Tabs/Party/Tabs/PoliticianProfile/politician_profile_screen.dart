import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Feed Tab/apis.dart';
import '../Feed Tab/feed_bloc.dart';
import '../Feed Tab/feed_tab.dart';
import '../journey_tab.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import '../../../../Reusable Functions/rich_text_editor.dart';
import 'politician_page_data.dart';
import 'politician_profile_bloc.dart';
import 'politician_profile_event.dart';
import 'politician_profile_state.dart';

class PoliticianInfoIcons {
  static final String gender = PoliticianPageData.genderIcon;
  static final String dob = PoliticianPageData.dobIcon;
  static final String birthPlace = PoliticianPageData.birthPlaceIcon;
  static final String politicalParty = PoliticianPageData.politicalPartyIcon;
  static final String constituency = PoliticianPageData.constituencyIcon;
  static final String address = PoliticianPageData.addressIcon;
}

class PoliticianProfileScreen extends StatelessWidget {
  final int politicianId;
  final String? photoUrl;
  final String? name;

  const PoliticianProfileScreen({
    super.key,
    this.politicianId = 12,
    this.photoUrl,
    this.name,
  });


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PoliticianProfileBloc>(
          create: (context) =>
          PoliticianProfileBloc(
            repository: PoliticianProfileRepository(),
          )..add(
            FetchPoliticianProfileEvent(politicianId),
          ),
        ),
        BlocProvider<FeedBloc>(
          create: (_) => FeedBloc(FeedApis()),
        ),
      ],
      child: _PoliticianProfileView(
        politicianId: politicianId,
        initialPhotoUrl: photoUrl,
        initialName: name,
      ),
    );
  }

}

class _PoliticianProfileView extends StatefulWidget {
  final int politicianId;
  final String? initialPhotoUrl;
  final String? initialName;

  const _PoliticianProfileView({
    required this.politicianId,
    this.initialPhotoUrl,
    this.initialName,
  });

  @override
  State<_PoliticianProfileView> createState() => _PoliticianProfileViewState();
}

class _PoliticianProfileViewState extends State<_PoliticianProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);
  final ValueNotifier<double> _sheetProgress = ValueNotifier<double>(0.0);

  bool showPoliticianDetails = true;
  bool _isUserScrolling = false;

  bool _isFollowing = false;
  bool _isFavorite = false;
  int _followCount = 0;
  bool _hasInitializedFollowerCount = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (!_tabController.indexIsChanging) {
        _selectedTabIndex.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _sheetProgress.dispose();
    _selectedTabIndex.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count > 9999999) {
      return "${(count / 10000000).toStringAsFixed(1)}C";
    } else if (count > 99999) {
      return "${(count / 100000).toStringAsFixed(1)}L";
    } else if (count > 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double defaultSheetRatio = (screenHeight < 500)
        ? 0.45
        : (screenHeight < 800)
        ? 0.28
        : (screenHeight < 900)
        ? 0.247
        : (218.0 / screenHeight).clamp(0.1, 0.85);

    return BlocConsumer<PoliticianProfileBloc, PoliticianProfileState>(
      listener: (context, state) {
        if (state.status == PoliticianProfileStatus.success &&
            state.politician != null &&
            !_hasInitializedFollowerCount) {
          setState(() {
            _followCount = state.politician!.followerCount ?? 0;
            _isFollowing = state.politician!.isFollowing ?? false;
            _isFavorite = state.politician!.isFavorite ?? false;
            _hasInitializedFollowerCount = true;
          });
        }
      },
      builder: (context, state) {
        final String effectivePhoto =
            state.politician?.photoUrl ?? widget.initialPhotoUrl ?? '';
        final String effectiveName =
            (state.politician != null &&
                state.politician!.displayName.isNotEmpty)
            ? state.politician!.displayName
            : (widget.initialName ?? '');

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xFFebebeb),
            body: Stack(
              children: [
                // 1. Background Leader Photo Section (progressive blur + darkening on scroll)
                ValueListenableBuilder<double>(
                  valueListenable: _sheetProgress,
                  builder: (context, progress, child) {
                    return _buildLeaderBannerSection(
                      context: context,
                      photoUrl: effectivePhoto,
                      politicianName: effectiveName,
                      progress: progress,
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                    );
                  },
                ),

                // 2. DraggableScrollableSheet containing the details, TabBar and Tab views
                NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    final progress =
                        ((notification.extent - defaultSheetRatio) /
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
                          if (!mounted) return false;
                          if (notification.depth != 0) return false;
                          if (notification is ScrollStartNotification) {
                            _isUserScrolling = notification.dragDetails != null;
                          }
                          if (notification is ScrollEndNotification) {
                            _isUserScrolling = false;
                          }
                          // Only respond to actual user scroll direction.
                          if (notification is UserScrollNotification &&
                              _isUserScrolling) {
                            if (notification.direction ==
                                ScrollDirection.reverse) {
                              // User scrolls up: hide politician details
                              if (showPoliticianDetails) {
                                setState(() {
                                  showPoliticianDetails = false;
                                });
                              }
                            } else if (notification.direction ==
                                ScrollDirection.forward) {
                              // User scrolls down: show politician details
                              if (!showPoliticianDetails) {
                                setState(() {
                                  showPoliticianDetails = true;
                                });
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
                              top: Radius.circular(24),
                            ),
                          ),
                          child: _buildSheetContent(
                            context: context,
                            state: state,
                            scrollController: scrollController,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderBannerSection({
    required BuildContext context,
    required String? photoUrl,
    required String politicianName,
    required double progress,
    required double screenHeight,
    required double screenWidth,
  }) {
    final double clampedProgress = progress.clamp(0.0, 1.0);
    final double blur = clampedProgress * 8.0;
    final double darkOpacity = clampedProgress * 0.48;
    final double titleOpacity = ((clampedProgress - 0.15) / 0.45).clamp(
      0.0,
      1.0,
    );

    return SizedBox(
      height: screenHeight * 0.8,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo with progressive blur
          if (photoUrl == null || photoUrl.isEmpty)
            const ColoredBox(
              color: Colors.white,
              child: Center(
                child: Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            )
          else
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: buildImageWidget(
                photoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: screenHeight * 0.8,
              ),
            ),

          // Darken overlay as sheet expands
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
            child: Builder(
              builder: (context) {
                final double buttonSize = 40;
                return SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(buttonSize / 2),
                    child: Center(
                      child: Transform.rotate(
                        angle: 3.141592653589793,
                        child: SvgPicture.asset(
                          PoliticianPageData.arrow,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          height: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Politician name fading in at the top bar
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05 + 52,
            right: screenWidth * 0.05,
            child: Opacity(
              opacity: titleOpacity,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - titleOpacity)),
                child: Text(
                  politicianName,
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
        ],
      ),
    );
  }

  Widget _buildSheetContent({
    required BuildContext context,
    required PoliticianProfileState state,
    required ScrollController scrollController,
    required double screenWidth,
    required double screenHeight,
  }) {
    if (state.status == PoliticianProfileStatus.loading ||
        state.status == PoliticianProfileStatus.initial) {
      return Column(
        children: [
          SizedBox(height: screenHeight * 0.01),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: screenHeight * 0.008,
              width: screenWidth * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorScheme.of(
                  context,
                ).onSurface.withValues(alpha: 0.16),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: CircularProgressIndicator(
                  color: ColorScheme.of(context).onSurface,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (state.status == PoliticianProfileStatus.failure ||
        state.politician == null) {
      return Column(
        children: [
          SizedBox(height: screenHeight * 0.01),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: screenHeight * 0.008,
              width: screenWidth * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorScheme.of(
                  context,
                ).onSurface.withValues(alpha: 0.16),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ?? "Failed to load politician details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorScheme.of(context).onSurface,
                        fontSize: MediaQuery.textScalerOf(context).scale(screenWidth * 0.036),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE3A31),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        context.read<PoliticianProfileBloc>().add(
                          FetchPoliticianProfileEvent(widget.politicianId),
                        );
                      },
                      child: Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.textScalerOf(context).scale(screenWidth * 0.036),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final politician = state.politician!;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Header Section (Politician details, animated when user scrolls)
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: showPoliticianDetails ? 1.0 : 0.0,
                child: _buildPoliticianDetailsSection(
                  context,
                  politician,
                  screenWidth,
                  screenHeight,
                ),
              ),
            ),
          ),
        ),

        // Pinned TabBar
        SliverPersistentHeader(
          pinned: true,
          delegate: _PoliticianProfileTabBarDelegate(
            TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.center,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              padding: EdgeInsets.only(left: screenWidth * 0.02),
              isScrollable: true,
              labelStyle: TextStyle(
                fontSize: MediaQuery.textScalerOf(context).scale(screenWidth * 0.036),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.25,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: MediaQuery.textScalerOf(context).scale(screenWidth * 0.036),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.25,
              ),
              labelColor: const Color(0xFF000000),
              unselectedLabelColor: const Color(0xFF666666),
              indicatorColor: Colors.red,
              dividerColor: ColorScheme.of(
                context,
              ).onSurface.withValues(alpha: 0.2),
              tabs: [
                Tab(text: PoliticianPageData.info),
                Tab(text: PoliticianPageData.journey),
                Tab(text: PoliticianPageData.feed),
                Tab(text: PoliticianPageData.development),
              ],
            ),
            dividerHeight: screenHeight * 0.01,
          ),
        ),

        // Dynamic Tab Body Content

        SliverToBoxAdapter(
          child: ValueListenableBuilder<int>(
            valueListenable: _selectedTabIndex,
            builder: (context, selectedIndex, child) {
              return Stack(
                children: [
                  // INFO
                  Offstage(
                    offstage: selectedIndex != 0,
                    child: _buildPoliticianTabContent(
                      index: 0,
                      politician: politician,
                      scrollController: scrollController,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                  ),

                  // JOURNEY
                  Offstage(
                    offstage: selectedIndex != 1,
                    child: _buildPoliticianTabContent(
                      index: 1,
                      politician: politician,
                      scrollController: scrollController,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                  ),

                  // FEED
                  Offstage(
                    offstage: selectedIndex != 2,
                    child: _buildPoliticianTabContent(
                      index: 2,
                      politician: politician,
                      scrollController: scrollController,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                  ),

                  // DEVELOPMENT
                  Offstage(
                    offstage: selectedIndex != 3,
                    child: _buildPoliticianTabContent(
                      index: 3,
                      politician: politician,
                      scrollController: scrollController,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

      ],
    );
  }
///----------------------Tabs

  Widget _buildPoliticianTabContent({
    required int index,
    required PoliticianModel politician,
    required ScrollController scrollController,
    required double screenWidth,
    required double screenHeight,
  }) {
    switch (index) {
      case 0:
        return _buildInfoTab(
          context,
          politician,
          screenWidth,
          screenHeight,
        );

      case 1:
        return politician.journeys.isEmpty
            ? _buildPlaceholderTab(
          context,
          icon: Icons.timeline_rounded,
          title: "No Journey Available",
          subtitle:
          "Journey timeline for this politician will appear here.",
          h: screenHeight,
          w: screenWidth,
        )
            : JourneyTab(
          key: ValueKey(
            'politician_journey_${politician.id}_${politician.journeys.length}',
          ),
          journeys: politician.journeys,
        );

      case 2:
        return FeedTab(
          key: const ValueKey('feed_tab'),
          partyId: widget.politicianId,
          scrollController: scrollController,
          isVisible: _tabController.index == 2,
          fromWhichPage: "Politician",
        );

      case 3:
        return _buildPlaceholderTab(
          context,
          icon: Icons.work_outline_rounded,
          title: "No Development Updates",
          subtitle:
          "Development milestones and projects will be shown here.",
          h: screenHeight,
          w: screenWidth,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  ///----------------------------------------
  Widget _buildPoliticianDetailsSection(
    BuildContext context,
    PoliticianModel politician,
    double w,
    double h,
  ) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      padding: EdgeInsets.only(
        top: h * 0.01,
        left: w * 0.053,
        right: w * 0.04,
        bottom: h * 0.015,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag indicator bar
          Align(
            alignment: Alignment.center,
            child: Container(
              height: h * 0.008,
              width: w * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorScheme.of(
                  context,
                ).onSurface.withValues(alpha: 0.16),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: w * 0.005, top: h * 0.003),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and name row
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
                        radius: w * 0.085,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: SizedBox.expand(
                            child:
                                (politician.photoUrl != null &&
                                    politician.photoUrl!.isNotEmpty)
                                ? buildImageWidget(
                                    politician.photoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 35,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            politician.displayName.isNotEmpty
                                ? politician.displayName
                                : politician.name,
                            style: TextStyle(
                              fontSize: textScaler.scale(w * 0.043),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: h * 0.004),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                PoliticianPageData.designationPrefix,
                                style: TextStyle(
                                  fontSize: textScaler.scale(w * 0.035),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.25,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  politician.designation.isNotEmpty
                                      ? politician.designation
                                      : (politician.position ?? '-'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: textScaler.scale(w * 0.035),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.25,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (politician.party?.name != null &&
                              politician.party!.name!.isNotEmpty) ...[
                            SizedBox(height: h * 0.002),
                            Text(
                              politician.party!.name!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: textScaler.scale(w * 0.031),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFE3A31),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.015),

                // Views, Followers, Follow & Favorite row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PoliticianPageData.view,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: textScaler.scale(w * 0.028),
                            letterSpacing: 0.22,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        Text(
                          _formatCount(politician.viewCount ?? 0),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: textScaler.scale(w * 0.058),
                            letterSpacing: 0.3,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: w * 0.06),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PoliticianPageData.followers,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: textScaler.scale(w * 0.028),
                            letterSpacing: 0.22,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        Text(
                          _formatCount(_followCount),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: textScaler.scale(w * 0.058),
                            letterSpacing: 0.3,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Follow button
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                          if (_isFollowing) {
                            _followCount++;
                          } else if (_followCount > 0) {
                            _followCount--;
                          }
                        });
                      },
                      child: Container(
                        height: w * 0.1,
                        padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                        decoration: BoxDecoration(
                          color: _isFollowing ? null : const Color(0xFF666666),
                          gradient: _isFollowing
                              ? GradientColors.primaryGradient
                              : null,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _isFollowing ? PoliticianPageData.following : PoliticianPageData.follow,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: textScaler.scale(w * 0.032),
                              letterSpacing: 0.37,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.05),

                    // Favorite button
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                      child: SvgPicture.asset(
                        PoliticianPageData.favoriteIcon,
                        height: w * 0.06,
                        colorFilter: _isFavorite
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDobAndAge(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return "-";

    if (dateStr.contains("year") || dateStr.contains("(")) {
      return dateStr;
    }

    try {
      DateTime? dt;
      final slashParts = dateStr.trim().split(RegExp(r'[/.-]'));
      if (slashParts.length == 3) {
        if (slashParts[0].length == 4) {
          // YYYY-MM-DD
          final y = int.tryParse(slashParts[0]);
          final m = int.tryParse(slashParts[1]);
          final d = int.tryParse(slashParts[2].split('T')[0]);
          if (y != null && m != null && d != null) {
            dt = DateTime(y, m, d);
          }
        } else if (slashParts[2].length >= 4) {
          // DD/MM/YYYY
          final d = int.tryParse(slashParts[0]);
          final m = int.tryParse(slashParts[1]);
          final y = int.tryParse(slashParts[2].split('T')[0]);
          if (y != null && m != null && d != null) {
            dt = DateTime(y, m, d);
          }
        }
      }

      dt ??= DateTime.tryParse(dateStr);

      if (dt != null) {
        final now = DateTime.now();
        int age = now.year - dt.year;
        if (now.month < dt.month ||
            (now.month == dt.month && now.day < dt.day)) {
          age--;
        }
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final year = dt.year.toString();
        if (age > 0) {
          return "$day / $month / $year  ($age years)";
        } else {
          return "$day / $month / $year";
        }
      }
    } catch (_) {}

    return dateStr;
  }

  Widget _buildInfoTab(
    BuildContext context,
    PoliticianModel politician,
    double w,
    double h,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.053, vertical: h * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Biography / Info section with READ MORE
          if (politician.info != null &&
              politician.info!.trim().isNotEmpty) ...[
            AppRichTextEditor(
              fieldKey: 'politician_info_${politician.id}',
              value: politician.info!,
              readOnly: true,
            ),
            SizedBox(height: h * 0.025),
          ],

          // 2. GENDER
          _buildInfoRow(
            context,
            icon: PoliticianPageData.genderIcon,
            title: PoliticianPageData.gender,
            data: politician.gender?.isNotEmpty == true
                ? politician.gender!.toUpperCase()
                : "-",
            w: w,
            h: h,
          ),
          SizedBox(height: h * 0.032),

          // 3. DOB / AGE
          _buildInfoRow(
            context,
            icon: PoliticianPageData.dobIcon,
            title: PoliticianPageData.dobAge,
            data: _formatDobAndAge(politician.dateOfBirth),
            w: w,
            h: h,
          ),
          SizedBox(height: h * 0.032),

          // 4. BIRTH PLACE
          _buildInfoRow(
            context,
            icon: PoliticianPageData.birthPlaceIcon,
            title: PoliticianPageData.birthPlace,
            data: politician.birthPlace?.isNotEmpty == true
                ? politician.birthPlace!
                : "-",
            w: w,
            h: h,
          ),
          SizedBox(height: h * 0.032),

          // 5. POLITICAL PARTY
          _buildInfoRow(
            context,
            icon: PoliticianPageData.politicalPartyIcon,
            title: PoliticianPageData.politicalParty,
            data: politician.party?.name?.isNotEmpty == true
                ? politician.party!.name!
                : "-",
            w: w,
            h: h,
          ),
          SizedBox(height: h * 0.032),

          // 6. CONSTITUENCY
          _buildInfoRow(
            context,
            icon: PoliticianPageData.constituencyIcon,
            title: PoliticianPageData.constituency,
            data: politician.constituency?.isNotEmpty == true
                ? politician.constituency!
                : "-",
            w: w,
            h: h,
          ),
          SizedBox(height: h * 0.032),

          // 7. ADDRESS
          _buildInfoRow(
            context,
            icon: PoliticianPageData.addressIcon,
            title: PoliticianPageData.address,
            data: politician.address?.isNotEmpty == true
                ? politician.address!
                : "-",
            w: w,
            h: h,
          ),
          SizedBox(height: h * 0.04),

          // ===================================================================
          // Extra fields commented out as requested (only show fields in reference image)
          // ===================================================================
          // _buildInfoRow(
          //   context,
          //   icon: 'Assets/LeadershipPage/Info/Education.svg',
          //   title: "EDUCATION",
          //   data: politician.education?.isNotEmpty == true
          //       ? politician.education!
          //       : "-",
          //   w: w,
          //   h: h,
          // ),
          // SizedBox(height: h * 0.032),
          //
          // _buildInfoRow(
          //   context,
          //   icon: PoliticianInfoIcons.gender,
          //   title: "DESIGNATION",
          //   data: politician.designation.isNotEmpty
          //       ? politician.designation
          //       : "-",
          //   w: w,
          //   h: h,
          // ),
          // SizedBox(height: h * 0.032),
          //
          // _buildInfoRow(
          //   context,
          //   icon: PoliticianInfoIcons.gender,
          //   title: "POSITION",
          //   data: politician.position?.isNotEmpty == true
          //       ? politician.position!
          //       : "-",
          //   w: w,
          //   h: h,
          // ),
          // SizedBox(height: h * 0.032),
          //
          // _buildInfoRow(
          //   context,
          //   icon: PoliticianInfoIcons.address,
          //   title: "REGION",
          //   data: politician.region?.isNotEmpty == true
          //       ? politician.region!
          //       : "-",
          //   w: w,
          //   h: h,
          // ),
          // SizedBox(height: h * 0.032),
          //
          // _buildInfoRow(
          //   context,
          //   icon: PoliticianInfoIcons.address,
          //   title: "STATE",
          //   data: politician.state?.isNotEmpty == true
          //       ? politician.state!
          //       : "-",
          //   w: w,
          //   h: h,
          // ),
          // SizedBox(height: h * 0.032),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String icon,
    required String title,
    required String data,
    required double w,
    required double h,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: w * 0.065,
          height: w * 0.065,
          child: SvgPicture.asset(
            icon,
            width: w * 0.065,
            height: w * 0.065,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: w * 0.045),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: textScaler.scale(w * 0.032),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.25,
                  color: const Color(0xFF666666),
                ),
              ),
              SizedBox(height: h * 0.005),
              Text(
                data,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: textScaler.scale(w * 0.042),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: const Color(0xFF0E0E0E),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required double h,
    required double w,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: h * 0.08, horizontal: w * 0.06),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: w * 0.11,
              color: ColorScheme.of(context).onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: h * 0.015),
            Text(
              title,
              style: TextStyle(
                fontSize: textScaler.scale(w * 0.041),
                fontWeight: FontWeight.w600,
                color: ColorScheme.of(context).onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: h * 0.008),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textScaler.scale(w * 0.033),
                color: ColorScheme.of(context).onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoliticianProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final double dividerHeight;

  _PoliticianProfileTabBarDelegate(this.tabBar, {this.dividerHeight = 8.0});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: dividerHeight,
            child: ColoredBox(
              color: const Color(0xFF000000).withValues(alpha: 0.08),
            ),
          ),
          tabBar,
        ],
      ),
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height + dividerHeight;

  @override
  double get minExtent => tabBar.preferredSize.height + dividerHeight;

  @override
  bool shouldRebuild(_PoliticianProfileTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar ||
        oldDelegate.dividerHeight != dividerHeight;
  }
}
