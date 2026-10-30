
// Country Profile Reusable Functions & UI Components
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Favourite/favourite_api.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_page_data.dart';

/// Formats date string from yyyy-MM-dd to a human-readable string (e.g. 15 August 1947)
String formatCountryDate(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty) return '-';
  try {
    final parsed = DateTime.tryParse(rawDate.trim());
    if (parsed == null) return rawDate;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  } catch (_) {
    return rawDate;
  }
}

/// Banner Section matching the exact Party screen banner layout, animations and sizing
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
            const ColoredBox(
              color: Colors.white,
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 60,
                  color: Colors.grey,
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
                      return const ColoredBox(
                        color: Colors.white,
                        child: Center(
                          child: Icon(Icons.image),
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
              width: 40,
              height: 40,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(20),
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
            left: screenWidth * 0.05 + 52,
            right: screenWidth * 0.05,
            child: Opacity(
              opacity: titleOpacity,
              child: Transform.translate(
                offset: Offset(
                  0,
                  18 * (1 - titleOpacity),
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
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected
                              ? GradientColors.primaryGradient
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          border: Border.all(
                            color: Colors.red,
                            width: 1,
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

/// Country Details Section matching PartyDetailsSection layout, metrics and styles
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

    final bool isIndia = widget.country.name.toLowerCase().contains('india') ||
        widget.country.registrationCode == 'IND';

    // Matches the reference design: "India - भारत"
    final String countryTitle = isIndia
        ? "India - भारत"
        : (widget.country.registrationCode != null &&
                widget.country.registrationCode!.isNotEmpty
            ? "${widget.country.name} - ${widget.country.registrationCode}"
            : widget.country.name);

    final String capitalText = widget.country.capital != null &&
            widget.country.capital!.isNotEmpty
        ? widget.country.capital!
        : (isIndia ? 'New Delhi' : '');

    return Container(
      padding: EdgeInsets.only(
        top: h * 0.015,
        left: w * 0.05,
        right: w * 0.05,
        bottom: h * 0.015,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: "India - भारत" on the left, Favorite Heart on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  countryTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              InkWell(
                onTap: _toggleFavourite,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    CountryPageData.favoriteIcon,
                    height: w * 0.06,
                    // Reference from Leadership page (politician_profile_screen.dart lines 1250-1258):
                    // ColorFilter with primary active red when favorited, grey #666666 when not.
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

          // Subtitle: "Capital City - New Delhi"
          Text(
            "Capital City - $capitalText",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: h * 0.018),

          // Stats Row: STATES and UNION TERRITORIES with vertical separator
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // States
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    CountryPageData.states,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.country.statesCount ?? (isIndia ? "28" : "-"),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              // Thin vertical divider line (increased height matching design)
              Container(
                height: h * 0.052,
                width: 1.2,
                color: const Color(0xFFE0E0E0),
                margin: EdgeInsets.symmetric(horizontal: w * 0.07),
              ),
              // Union Territories
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    CountryPageData.unionTerritories,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.country.unionTerritories != null
                        ? widget.country.unionTerritories!
                            .toString()
                            .padLeft(2, '0')
                        : (isIndia ? "08" : "-"),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Color(0xFF1E1E1E),
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

/// Reusable section title with accent styling
Widget buildSectionHeader(
  BuildContext context, {
  required String title,
  Widget? trailing,
}) {
  final w = MediaQuery.of(context).size.width;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: w * 0.02),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: (w * 0.042).clamp(15.0, 18.0),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

/// Reusable key-value info row matching the UI reference
Widget buildCountryInfoRow(
  BuildContext context, {
  required String title,
  required String value,
  String? iconAsset,
  IconData? fallbackIcon,
}) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: h * 0.01),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: w * 0.095,
          height: w * 0.095,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: iconAsset != null && iconAsset.endsWith('.svg')
                ? SvgPicture.asset(
                    iconAsset,
                    width: w * 0.05,
                    height: w * 0.05,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF666666),
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    fallbackIcon ?? Icons.info_outline,
                    size: w * 0.05,
                    color: const Color(0xFF666666),
                  ),
          ),
        ),
        SizedBox(width: w * 0.035),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: (w * 0.03).clamp(11.0, 13.0),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: const Color(0xFF888888),
                ),
              ),
              SizedBox(height: h * 0.004),
              Text(
                value.isNotEmpty ? value : '-',
                style: TextStyle(
                  fontSize: (w * 0.038).clamp(13.0, 16.0),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: const Color(0xFF111111),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Stat card item (e.g. STATES: 28, UNION TERRITORIES: 08)
Widget buildStatItem(
  BuildContext context, {
  required String label,
  required String count,
}) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: (w * 0.028).clamp(10.0, 12.0),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: const Color(0xFF777777),
        ),
      ),
      SizedBox(height: h * 0.005),
      Text(
        count,
        style: TextStyle(
          fontSize: (w * 0.05).clamp(18.0, 24.0),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111111),
        ),
      ),
    ],
  );
}

/// Place to visit card
Widget buildPlaceCard(BuildContext context, PlaceView place) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;

  return Container(
    width: w * 0.62,
    margin: EdgeInsets.only(right: w * 0.035),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: h * 0.14,
            width: double.infinity,
            child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                ? buildImageWidget(place.imageUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.place, size: 36, color: Colors.grey),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(w * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place.category != null && place.category!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02,
                      vertical: h * 0.004,
                    ),
                    margin: EdgeInsets.only(bottom: h * 0.006),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFE3A31).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      place.category!,
                      style: TextStyle(
                        fontSize: (w * 0.026).clamp(10.0, 12.0),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFE3A31),
                      ),
                    ),
                  ),
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: (w * 0.038).clamp(13.0, 15.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
                if (place.description != null &&
                    place.description!.isNotEmpty) ...[
                  SizedBox(height: h * 0.005),
                  Text(
                    place.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (w * 0.03).clamp(11.0, 12.0),
                      color: const Color(0xFF666666),
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Country symbol card
Widget buildSymbolCard(
  BuildContext context,
  SymbolView symbol, {
  void Function(String url)? onDownload,
}) {
  final w = MediaQuery.of(context).size.width;
  final h = MediaQuery.of(context).size.height;

  final primaryUrl = symbol.urls.isNotEmpty ? symbol.urls.first : '';
  final label = symbol.label ?? symbol.kind ?? 'Symbol';

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: EdgeInsets.all(w * 0.03),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: primaryUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: buildImageWidget(primaryUrl, fit: BoxFit.contain),
                  )
                : const Icon(Icons.flag_outlined, size: 40, color: Colors.grey),
          ),
        ),
        SizedBox(height: h * 0.008),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: (w * 0.034).clamp(12.0, 14.0),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF222222),
          ),
        ),
        if (symbol.kind != null && symbol.kind!.isNotEmpty)
          Text(
            symbol.kind!,
            style: TextStyle(
              fontSize: (w * 0.026).clamp(10.0, 11.0),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF888888),
            ),
          ),
        if (symbol.downloadable && primaryUrl.isNotEmpty && onDownload != null) ...[
          SizedBox(height: h * 0.006),
          InkWell(
            onTap: () => onDownload(primaryUrl),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.025,
                vertical: h * 0.005,
              ),
              decoration: BoxDecoration(
                gradient: GradientColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
