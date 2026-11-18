import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Country_model.dart';
import 'Country_page_data.dart';
import 'india_map_widget.dart';

/// [GEOGRAPHIC TAB PAGE] Responsive Geographic & Administrative Profile Section.
/// Includes interactive Vector India Map, administrative stats, and geographic overview.
class CountryGeoPage extends StatelessWidget {
  final CountryModel country;

  const CountryGeoPage({
    super.key,
    required this.country,
  });

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

  Widget _buildFormattedParagraph(String text, {double fontSize = 15, EdgeInsetsGeometry? padding}) {
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
                  fontSize: (w * (13.0 / 375.0)).clamp(12.0, 14.0),
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF666666),
                  letterSpacing: 0.21,
                ),
              ),
              SizedBox(height: h * 0.002),
              Text(
                value,
                style: TextStyle(
                  fontSize: (w * 0.045).clamp(14.0, 16.0),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E1E1E),
                  letterSpacing: 0.31,
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
    final String rawDescription = country.geographicDescription?.trim().isNotEmpty == true
        ? country.geographicDescription!.trim()
        : (country.info?.trim().isNotEmpty == true
            ? country.info!.trim()
            : '');

    final List<String> allParagraphs = rawDescription
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final List<String> paragraphs = allParagraphs.isNotEmpty
        ? allParagraphs
        : rawDescription.split('\n').where((p) => p.trim().isNotEmpty).toList();

    final bool canToggle = paragraphs.length > 2 || rawDescription.length > 250;

    // 2. Stats values from API
    final String areaValue = _formatArea(country.area);
    final String regCodeValue = country.registrationCode?.trim().isNotEmpty == true
        ? country.registrationCode!.trim()
        : '-';
    final String populationValue = country.population?.trim().isNotEmpty == true
        ? country.population!.trim()
        : '-';

    // ValueNotifier replaces setState for expand/collapse toggle
    final expandedNotifier = ValueNotifier<bool>(true);

    return ValueListenableBuilder<bool>(
      valueListenable: expandedNotifier,
      builder: (context, isExpanded, _) {
        final List<String> visibleParagraphs = isExpanded
            ? paragraphs
            : (paragraphs.length > 2 ? paragraphs.sublist(0, 2) : paragraphs);

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
              fontSize: (w * (15.0 / 375.0)).clamp(14.0, 16.0),
            ),
            if (i < visibleParagraphs.length - 1)
              SizedBox(height: h * 0.016),
          ],

          // SHOW LESS / SHOW MORE Toggle
          if (canToggle) ...[
            SizedBox(height: h * 0.012),
            GestureDetector(
              onTap: () {
                expandedNotifier.value = !expandedNotifier.value;
              },
              child: Text(
                isExpanded ? 'SHOW LESS' : 'SHOW MORE',
                style: TextStyle(
                  fontSize: (w * (13.0 / 375.0)).clamp(12.0, 14.0),
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
            initialSelectedState: country.registrationCode,
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
      }, // end ValueListenableBuilder builder
    );   // end ValueListenableBuilder
  }
}

// Aliases for compatibility
typedef GeographicTabSection = CountryGeoPage;
typedef CountryGeoTab = CountryGeoPage;
