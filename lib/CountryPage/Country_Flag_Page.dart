import 'package:flutter/material.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';
import 'reusable_functions.dart';

/// [FLAG & EMBLEM TAB PAGE] Displays the National Flag and National Emblem,
/// along with their descriptions and download options.
class CountryFlagPage extends StatefulWidget {
  final CountryModel country;

  const CountryFlagPage({
    super.key,
    required this.country,
  });

  @override
  State<CountryFlagPage> createState() => _CountryFlagPageState();
}

class _CountryFlagPageState extends State<CountryFlagPage> {
  bool _isFlagExpanded = false;

  @override
  Widget build(BuildContext context) {
    final country = widget.country;
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
                if (flagDesc.isNotEmpty) ...[
                  RichText(
                    maxLines: _isFlagExpanded ? null : 4,
                    overflow:
                        _isFlagExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: (w * (15.0 / 375.0)).clamp(14.0, 16.0),
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
                        fontSize: (w * (13.0 / 375.0)).clamp(12.0, 14.0),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFE3A31),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.025),
                ],

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
                          fontSize: (w * (14.0 / 375.0)).clamp(13.0, 15.0),
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
                          fontSize: (w * (14.0 / 375.0)).clamp(13.0, 15.0),
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
}

