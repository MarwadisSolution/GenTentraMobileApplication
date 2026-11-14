import 'package:flutter/material.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';

/// [PLACES TO VISIT TAB PAGE] Displays tourist attractions, landmarks,
/// and places to visit for the country.
class CountryPlacesToVisitPage extends StatelessWidget {
  final CountryModel country;

  const CountryPlacesToVisitPage({
    super.key,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
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
              fontSize: (w * (15.0 / 375.0)).clamp(14.0, 16.0),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E),
              height: 1.5,
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
  /// clean photo with pagination indicator dots at bottom right, name in bold uppercase, description below.
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
              fontSize: (w * (16.0 / 375.0)).clamp(15.0, 18.0),
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
                fontSize: (w * (15.0 / 375.0)).clamp(14.0, 16.0),
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
}

// Aliases for compatibility
typedef CountryPlacesToVisitTab = CountryPlacesToVisitPage;
