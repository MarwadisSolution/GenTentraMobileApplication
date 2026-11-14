// =============================================================================
// india_map_widget.dart
// Interactive India Map – Multi-Level Vector GeoJSON Visualization
// =============================================================================
//
// 3-Level Architecture:
//   Level 1 – Country  : Complete map of India with individual state boundaries.
//                        States are independently selectable and highlighted.
//   Level 2 – State    : Detailed state map displaying individual district
//                        boundaries. Each district is independently selectable.
//   Level 3 – District : District level details and statistics information panel.
//
// GeoJSON Source: lib/CountryPage/india.geojson (760 features, 36 states/UTs).
// Pure Flutter code without external map image files (no PNG/JPG/SVG map images).
// =============================================================================

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS & ASSET PATH
// ─────────────────────────────────────────────────────────────────────────────

const String _kGeoJsonAsset = 'lib/CountryPage/india.geojson';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS & MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// 3-Level Navigation Hierarchy
enum MapLevel {
  country,  // Level 1: Full India with state boundaries
  state,    // Level 2: Selected state with district boundaries
  district, // Level 3: District focused with statistics
}

/// Geographic Bounding Box
class GeoBounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  const GeoBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  double get latSpan => maxLat - minLat;
  double get lngSpan => maxLng - minLng;
}

/// A single district in a state (Level-2 and Level-3 model)
class GeoDistrict {
  final String districtName;
  final String districtCode;
  final String stateName;
  final String stateCode;

  /// Rings projected to country-normalised [0,1] coordinates
  final List<List<Offset>> countryRings;

  /// Rings projected to state-local normalised [0,1] coordinates for Level 2
  final List<List<Offset>> stateRings;

  /// Center point in country-normalised coords
  final Offset center;

  const GeoDistrict({
    required this.districtName,
    required this.districtCode,
    required this.stateName,
    required this.stateCode,
    required this.countryRings,
    required this.stateRings,
    required this.center,
  });
}

/// An aggregated State/UT (Level-1 model)
class GeoState {
  final String name;
  final String code;
  final List<GeoDistrict> districts;

  /// All rings from all districts belonging to this state (country-normalised [0,1])
  final List<List<Offset>> countryRings;

  /// State bounding box in country-normalised [0,1]
  final Rect countryBounds;

  /// Geographic center
  final Offset center;

  const GeoState({
    required this.name,
    required this.code,
    required this.districts,
    required this.countryRings,
    required this.countryBounds,
    required this.center,
  });
}

/// Parsed & Projected In-Memory Map Data Cache
class IndiaMapData {
  final List<GeoState> states;
  final List<GeoDistrict> allDistricts;
  final GeoBounds bounds;
  final double aspectRatio; // Width / Height

  const IndiaMapData({
    required this.states,
    required this.allDistricts,
    required this.bounds,
    required this.aspectRatio,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PARSER & CACHE
// ─────────────────────────────────────────────────────────────────────────────

class IndiaMapParser {
  static IndiaMapData? _cachedData;

  /// Loads and parses the GeoJSON asset once and caches in memory.
  static Future<IndiaMapData> load() async {
    if (_cachedData != null) return _cachedData!;

    final raw = await rootBundle.loadString(_kGeoJsonAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final features = json['features'] as List<dynamic>;

    // ── 1. Find overall geographic bounds ──
    double minLat = 90, maxLat = -90;
    double minLng = 180, maxLng = -180;

    // Structure raw features
    final List<_ParsedFeature> parsedList = [];

    for (final feat in features) {
      final props = feat['properties'] as Map<String, dynamic>? ?? {};
      final geom = feat['geometry'] as Map<String, dynamic>? ?? {};

      final stateName = props['st_nm']?.toString() ?? 'Unknown State';
      if (stateName.toLowerCase().contains('andaman') ||
          stateName.toLowerCase().contains('nicobar')) {
        // Skip Andaman and Nicobar islands so the mainland map is clean, prominent, and free of stray dots
        continue;
      }
      final stateCode = props['st_code']?.toString() ?? '';
      final districtName = props['district']?.toString() ?? 'Unknown District';
      final districtCode = props['dt_code']?.toString() ?? '';

      final geomType = geom['type']?.toString() ?? '';
      final coords = geom['coordinates'] as List<dynamic>? ?? [];

      final List<List<List<double>>> rings = [];

      if (geomType == 'Polygon') {
        for (final ring in coords) {
          rings.add(_extractRing(ring as List));
        }
      } else if (geomType == 'MultiPolygon') {
        for (final poly in coords) {
          for (final ring in (poly as List)) {
            rings.add(_extractRing(ring as List));
          }
        }
      }

      for (final ring in rings) {
        for (final pt in ring) {
          final lat = pt[0];
          final lng = pt[1];
          if (lat < minLat) minLat = lat;
          if (lat > maxLat) maxLat = lat;
          if (lng < minLng) minLng = lng;
          if (lng > maxLng) maxLng = lng;
        }
      }

      parsedList.add(_ParsedFeature(
        stateName: stateName,
        stateCode: stateCode,
        districtName: districtName,
        districtCode: districtCode,
        rawRings: rings,
      ));
    }

    final latSpan = maxLat - minLat;
    final lngSpan = maxLng - minLng;

    // Aspect ratio calculation with latitude cosine correction:
    // 1 deg lng at mean latitude is shorter than 1 deg lat.
    final meanLatRad = ((minLat + maxLat) / 2) * (math.pi / 180.0);
    final cosLat = math.cos(meanLatRad);
    final geoWidth = lngSpan * cosLat;
    final geoHeight = latSpan;
    final aspectRatio = geoWidth / geoHeight;

    // Normalised projection for entire country: (lat, lng) -> Offset(0..1, 0..1)
    Offset projectCountry(double lat, double lng) {
      final x = (lng - minLng) / lngSpan;
      final y = (maxLat - lat) / latSpan; // Invert Y so north is at top
      return Offset(x, y);
    }

    // ── 2. Group by State ──
    final Map<String, List<_ParsedFeature>> stateMap = {};
    for (final p in parsedList) {
      stateMap.putIfAbsent(p.stateName, () => []).add(p);
    }

    final List<GeoState> geoStates = [];
    final List<GeoDistrict> allDistricts = [];

    for (final entry in stateMap.entries) {
      final stateName = entry.key;
      final stateFeatures = entry.value;
      final stateCode = stateFeatures.first.stateCode;

      // Find state-specific geographic bounds for Level-2 projection
      double sMinLat = 90, sMaxLat = -90, sMinLng = 180, sMaxLng = -180;
      for (final f in stateFeatures) {
        for (final ring in f.rawRings) {
          for (final pt in ring) {
            if (pt[0] < sMinLat) sMinLat = pt[0];
            if (pt[0] > sMaxLat) sMaxLat = pt[0];
            if (pt[1] < sMinLng) sMinLng = pt[1];
            if (pt[1] > sMaxLng) sMaxLng = pt[1];
          }
        }
      }

      final sLatSpan = (sMaxLat - sMinLat).clamp(0.0001, 90.0);
      final sLngSpan = (sMaxLng - sMinLng).clamp(0.0001, 180.0);

      Offset projectState(double lat, double lng) {
        final x = (lng - sMinLng) / sLngSpan;
        final y = (sMaxLat - lat) / sLatSpan;
        return Offset(x, y);
      }

      final List<GeoDistrict> stateDistricts = [];
      final List<List<Offset>> allStateCountryRings = [];

      double cMinX = 1, cMaxX = 0, cMinY = 1, cMaxY = 0;

      for (final f in stateFeatures) {
        final List<List<Offset>> countryRings = [];
        final List<List<Offset>> stateRings = [];

        double dMinX = 1, dMaxX = 0, dMinY = 1, dMaxY = 0;

        for (final r in f.rawRings) {
          final cRing = r.map((pt) {
            final off = projectCountry(pt[0], pt[1]);
            if (off.dx < cMinX) cMinX = off.dx;
            if (off.dx > cMaxX) cMaxX = off.dx;
            if (off.dy < cMinY) cMinY = off.dy;
            if (off.dy > cMaxY) cMaxY = off.dy;

            if (off.dx < dMinX) dMinX = off.dx;
            if (off.dx > dMaxX) dMaxX = off.dx;
            if (off.dy < dMinY) dMinY = off.dy;
            if (off.dy > dMaxY) dMaxY = off.dy;
            return off;
          }).toList();

          final sRing = r.map((pt) => projectState(pt[0], pt[1])).toList();

          countryRings.add(cRing);
          stateRings.add(sRing);
          allStateCountryRings.add(cRing);
        }

        final districtCenter = Offset((dMinX + dMaxX) / 2, (dMinY + dMaxY) / 2);

        final district = GeoDistrict(
          districtName: f.districtName,
          districtCode: f.districtCode,
          stateName: stateName,
          stateCode: stateCode,
          countryRings: countryRings,
          stateRings: stateRings,
          center: districtCenter,
        );

        stateDistricts.add(district);
        allDistricts.add(district);
      }

      final stateBounds = Rect.fromLTRB(cMinX, cMinY, cMaxX, cMaxY);
      final stateCenter = Offset((cMinX + cMaxX) / 2, (cMinY + cMaxY) / 2);

      geoStates.add(GeoState(
        name: stateName,
        code: stateCode,
        districts: stateDistricts,
        countryRings: allStateCountryRings,
        countryBounds: stateBounds,
        center: stateCenter,
      ));
    }

    _cachedData = IndiaMapData(
      states: geoStates,
      allDistricts: allDistricts,
      bounds: GeoBounds(
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
      ),
      aspectRatio: aspectRatio,
    );

    return _cachedData!;
  }

  static List<List<double>> _extractRing(List<dynamic> ring) {
    return ring.map<List<double>>((pt) {
      final p = pt as List<dynamic>;
      final lng = (p[0] as num).toDouble();
      final lat = (p[1] as num).toDouble();
      return [lat, lng]; // [0] = lat, [1] = lng
    }).toList();
  }
}

class _ParsedFeature {
  final String stateName;
  final String stateCode;
  final String districtName;
  final String districtCode;
  final List<List<List<double>>> rawRings;

  _ParsedFeature({
    required this.stateName,
    required this.stateCode,
    required this.districtName,
    required this.districtCode,
    required this.rawRings,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER (Level 1: Country View, Level 2: State View)
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveMapPainter extends CustomPainter {
  final IndiaMapData mapData;
  final MapLevel level;
  final GeoState? selectedState;
  final GeoDistrict? selectedDistrict;

  // Visual styling matching reference mockup
  static const Color _countryFillColor = Color(0xFF0D5C96); // Deep rich blue from mockup
  static const Color _stateHighlightColor = Color(0xFFFE3A31); // Coral red when selected
  static const Color _districtFillColor = Color(0xFF1976D2);
  static const Color _districtSelectedColor = Color(0xFFFE3A31);
  static const Color _boundaryStrokeColor = Colors.white; // Crisp white boundaries
  static const Color _districtStrokeColor = Color(0xFFE0E0E0);

  _InteractiveMapPainter({
    required this.mapData,
    required this.level,
    this.selectedState,
    this.selectedDistrict,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFill = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (level == MapLevel.country) {
      _paintCountryMap(canvas, size, paintFill, paintStroke);
    } else {
      _paintStateMap(canvas, size, paintFill, paintStroke);
    }
  }

  /// Level 1: Paints all states of India
  void _paintCountryMap(
    Canvas canvas,
    Size size,
    Paint paintFill,
    Paint paintStroke,
  ) {
    // 1. Draw all unselected states
    for (final state in mapData.states) {
      if (state == selectedState) continue;

      paintFill.color = _countryFillColor;
      paintStroke.color = _boundaryStrokeColor;
      paintStroke.strokeWidth = 0.8;

      for (final ring in state.countryRings) {
        if (ring.length < 3) continue;
        final path = _buildScaledPath(ring, size);
        canvas.drawPath(path, paintFill);
        canvas.drawPath(path, paintStroke);
      }
    }

    // 2. Draw selected state on top with highlight color
    if (selectedState != null) {
      paintFill.color = _stateHighlightColor;
      paintStroke.color = Colors.white;
      paintStroke.strokeWidth = 1.6;

      for (final ring in selectedState!.countryRings) {
        if (ring.length < 3) continue;
        final path = _buildScaledPath(ring, size);
        canvas.drawPath(path, paintFill);
        canvas.drawPath(path, paintStroke);
      }
    }
  }

  /// Level 2: Paints individual districts of the selected state
  void _paintStateMap(
    Canvas canvas,
    Size size,
    Paint paintFill,
    Paint paintStroke,
  ) {
    if (selectedState == null) return;

    for (final district in selectedState!.districts) {
      final isDistrictSelected = district == selectedDistrict;

      paintFill.color = isDistrictSelected
          ? _districtSelectedColor
          : _districtFillColor.withValues(alpha: 0.9);

      paintStroke.color = isDistrictSelected ? Colors.white : _districtStrokeColor;
      paintStroke.strokeWidth = isDistrictSelected ? 1.8 : 0.9;

      for (final ring in district.stateRings) {
        if (ring.length < 3) continue;
        final path = _buildScaledPath(ring, size);
        canvas.drawPath(path, paintFill);
        canvas.drawPath(path, paintStroke);
      }
    }
  }

  Path _buildScaledPath(List<Offset> ring, Size size) {
    const double padding = 16.0;
    final double availWidth = math.max(10.0, size.width - (padding * 2));
    final double availHeight = math.max(10.0, size.height - (padding * 2));

    final double geoAspect = mapData.aspectRatio; // ~0.88 for India
    final double canvasAspect = availWidth / availHeight;

    double scaleX, scaleY, offsetX, offsetY;
    if (canvasAspect > geoAspect) {
      // Canvas is wider than map: fit to height
      scaleY = availHeight;
      scaleX = availHeight * geoAspect;
      offsetX = padding + (availWidth - scaleX) / 2;
      offsetY = padding;
    } else {
      // Canvas is taller than map: fit to width
      scaleX = availWidth;
      scaleY = availWidth / geoAspect;
      offsetX = padding;
      offsetY = padding + (availHeight - scaleY) / 2;
    }

    final path = Path();
    final first = ring.first;
    path.moveTo(offsetX + first.dx * scaleX, offsetY + first.dy * scaleY);
    for (int i = 1; i < ring.length; i++) {
      path.lineTo(offsetX + ring[i].dx * scaleX, offsetY + ring[i].dy * scaleY);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _InteractiveMapPainter old) {
    return old.level != level ||
        old.selectedState != selectedState ||
        old.selectedDistrict != selectedDistrict ||
        old.mapData != mapData;
  }

  /// Hit test for Level 1 (detects state at local coordinate)
  GeoState? hitTestState(Offset localPoint, Size size) {
    // Test selected state first if already on top
    final statesToTest = [
      ?selectedState,
      ...mapData.states.where((s) => s != selectedState),
    ];

    for (final state in statesToTest) {
      for (final ring in state.countryRings) {
        if (ring.length < 3) continue;
        final path = _buildScaledPath(ring, size);
        if (path.contains(localPoint)) {
          return state;
        }
      }
    }
    return null;
  }

  /// Hit test for Level 2 (detects district at local coordinate)
  GeoDistrict? hitTestDistrict(Offset localPoint, Size size) {
    if (selectedState == null) return null;

    final districtsToTest = [
      ?selectedDistrict,
      ...selectedState!.districts.where((d) => d != selectedDistrict),
    ];

    for (final district in districtsToTest) {
      for (final ring in district.stateRings) {
        if (ring.length < 3) continue;
        final path = _buildScaledPath(ring, size);
        if (path.contains(localPoint)) {
          return district;
        }
      }
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC INTERACTIVE MAP WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// Full Interactive Multi-Level Vector Map for India
class IndiaMapWidget extends StatefulWidget {
  /// Callback when a state is selected (Level 1 hook)
  final void Function(GeoState state)? onStateSelected;

  /// Callback when a district is selected (Level 2 & 3 hook)
  final void Function(GeoDistrict district)? onDistrictSelected;

  /// Initial state name to highlight (optional)
  final String? initialSelectedState;

  const IndiaMapWidget({
    super.key,
    this.onStateSelected,
    this.onDistrictSelected,
    this.initialSelectedState,
  });

  @override
  State<IndiaMapWidget> createState() => _IndiaMapWidgetState();
}

class _IndiaMapWidgetState extends State<IndiaMapWidget> {
  IndiaMapData? _mapData;
  bool _isLoading = true;
  String? _errorMessage;

  // Navigation State
  MapLevel _currentLevel = MapLevel.country;
  GeoState? _selectedState;
  GeoDistrict? _selectedDistrict;

  Size _renderedCanvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadGeoJson() async {
    try {
      final data = await IndiaMapParser.load();
      if (!mounted) return;

      GeoState? initialMatch;
      if (widget.initialSelectedState != null &&
          widget.initialSelectedState!.trim().isNotEmpty) {
        final query = widget.initialSelectedState!.toLowerCase().trim();
        for (final s in data.states) {
          if (s.name.toLowerCase().contains(query) ||
              s.code.toLowerCase() == query) {
            initialMatch = s;
            break;
          }
        }
      }

      setState(() {
        _mapData = data;
        _selectedState = initialMatch;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Handle tap detection
  void _handleTap(TapUpDetails details) {
    if (_mapData == null || _renderedCanvasSize == Size.zero) return;

    final painter = _InteractiveMapPainter(
      mapData: _mapData!,
      level: _currentLevel,
      selectedState: _selectedState,
      selectedDistrict: _selectedDistrict,
    );

    if (_currentLevel == MapLevel.country) {
      final hit = painter.hitTestState(details.localPosition, _renderedCanvasSize);
      setState(() {
        if (_selectedState == hit) {
          _selectedState = null; // Toggle selection off
        } else {
          _selectedState = hit;
        }
        _selectedDistrict = null;
      });

      if (_selectedState != null) {
        widget.onStateSelected?.call(_selectedState!);
      }
    } else {
      final hit = painter.hitTestDistrict(details.localPosition, _renderedCanvasSize);
      setState(() {
        _selectedDistrict = hit;
      });

      if (_selectedDistrict != null) {
        widget.onDistrictSelected?.call(_selectedDistrict!);
      }
    }
  }

  // Level Navigation
  void _enterStateLevel(GeoState state) {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _currentLevel = MapLevel.state;
    });
  }

  void _returnToCountryLevel() {
    setState(() {
      _currentLevel = MapLevel.country;
      _selectedDistrict = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return Container(
        height: h * 0.45,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: w * 0.08,
              height: w * 0.08,
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF0D5C96),
              ),
            ),
            SizedBox(height: h * 0.015),
            Text(
              'Loading India Map...',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _mapData == null) {
      return Container(
        height: h * 0.35,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: w * 0.12, color: Colors.grey[400]),
            SizedBox(height: h * 0.012),
            Text(
              'Could not load geographical map data',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Map container height responsive using MediaQuery, providing adequate vertical room for full map
    final double mapContainerHeight = (w * 1.05).clamp(340.0, 480.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Navigation Bar / Breadcrumb (Only shown in drill-down) ───────────
        if (_currentLevel != MapLevel.country) ...[
          _buildBreadcrumbBar(w, h),
          SizedBox(height: h * 0.012),
        ],

        // ── Map Canvas (Seamless, Borderless, full page scrollable) ───────────
        Container(
          width: w,
          height: mapContainerHeight,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: _handleTap,
            child: LayoutBuilder(
              builder: (context, constraints) {
                _renderedCanvasSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                return CustomPaint(
                  size: _renderedCanvasSize,
                  painter: _InteractiveMapPainter(
                    mapData: _mapData!,
                    level: _currentLevel,
                    selectedState: _selectedState,
                    selectedDistrict: _selectedDistrict,
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: h * 0.015),

        // ── Level 1 / Level 2 / Level 3 Information Panel ───────────────────
        if (_currentLevel == MapLevel.country && _selectedState != null)
          _buildStateInfoCard(w, h, _selectedState!)
        else if (_currentLevel == MapLevel.state && _selectedDistrict != null)
          _buildDistrictInfoCard(w, h, _selectedDistrict!)
        else if (_currentLevel == MapLevel.state && _selectedState != null)
          _buildStateOverviewPrompt(w, h, _selectedState!),
      ],
    );
  }

  /// Top Breadcrumb Bar (allows returning from Level 2 to Level 1)
  Widget _buildBreadcrumbBar(double w, double h) {
    if (_currentLevel == MapLevel.country) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'GEOGRAPHICAL MAP OF INDIA',
            style: TextStyle(
              fontSize: (w * 0.038).clamp(13.0, 15.0),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
              letterSpacing: 0.4,
            ),
          ),
          Text(
            '36 States & UTs',
            style: TextStyle(
              fontSize: (w * 0.032).clamp(11.0, 13.0),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF888888),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _returnToCountryLevel,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.025,
              vertical: h * 0.005,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0D5C96).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(w * 0.015),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: w * 0.028,
                  color: const Color(0xFF0D5C96),
                ),
                SizedBox(width: w * 0.012),
                Text(
                  'All India',
                  style: TextStyle(
                    fontSize: (w * 0.035).clamp(12.0, 14.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D5C96),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: w * 0.02),
        Text(
          '/',
          style: TextStyle(fontSize: (w * 0.038).clamp(13.0, 15.0), color: Colors.grey),
        ),
        SizedBox(width: w * 0.02),
        Expanded(
          child: Text(
            _selectedState?.name ?? 'State',
            style: TextStyle(
              fontSize: (w * 0.04).clamp(14.0, 16.0),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// State Info Card (Level 1 selected state)
  Widget _buildStateInfoCard(double w, double h, GeoState state) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(w * 0.035),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // State Icon Badge
          Container(
            width: w * 0.11,
            height: w * 0.11,
            decoration: BoxDecoration(
              color: const Color(0xFFFE3A31).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                size: w * 0.055,
                color: const Color(0xFFFE3A31),
              ),
            ),
          ),
          SizedBox(width: w * 0.035),
          // State Name & District Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.name,
                  style: TextStyle(
                    fontSize: (w * 0.043).clamp(15.0, 18.0),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  '${state.districts.length} Districts  •  Code: ${state.code.isNotEmpty ? state.code : "-"}',
                  style: TextStyle(
                    fontSize: (w * 0.035).clamp(12.0, 14.0),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          // Button to enter Level 2: State Map
          GestureDetector(
            onTap: () => _enterStateLevel(state),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.032,
                vertical: h * 0.01,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0D5C96),
                borderRadius: BorderRadius.circular(w * 0.02),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore State',
                    style: TextStyle(
                      fontSize: (w * 0.035).clamp(12.0, 14.0),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: w * 0.01),
                  Icon(Icons.arrow_forward_ios, size: w * 0.025, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Level 2 Overview prompt when inside a state but no district is clicked yet
  Widget _buildStateOverviewPrompt(double w, double h, GeoState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.012),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(w * 0.03),
        border: Border.all(color: const Color(0xFFE3E8EF)),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, size: w * 0.038, color: const Color(0xFF0D5C96)),
          SizedBox(width: w * 0.025),
          Expanded(
            child: Text(
              'Tap any of the ${state.districts.length} districts to view Level 3 details.',
              style: TextStyle(
                fontSize: (w * 0.035).clamp(12.0, 14.0),
                color: const Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// District Info Card (Level 3 selected district details)
  Widget _buildDistrictInfoCard(double w, double h, GeoDistrict district) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(w * 0.035),
        border: Border.all(color: const Color(0xFFFE3A31).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.11,
            height: w * 0.11,
            decoration: BoxDecoration(
              color: const Color(0xFFFE3A31).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.place,
                size: w * 0.055,
                color: const Color(0xFFFE3A31),
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
                  district.districtName,
                  style: TextStyle(
                    fontSize: (w * 0.043).clamp(15.0, 17.0),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: h * 0.003),
                Text(
                  'District Code: ${district.districtCode.isNotEmpty ? district.districtCode : "-"}  •  ${district.stateName}',
                  style: TextStyle(
                    fontSize: (w * 0.035).clamp(12.0, 14.0),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.025,
              vertical: h * 0.006,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFE3A31),
              borderRadius: BorderRadius.circular(w * 0.015),
            ),
            child: Text(
              'SELECTED',
              style: TextStyle(
                fontSize: (w * 0.03).clamp(10.0, 12.0),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
