import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Country_api.dart';
import 'State_item_model.dart';
import 'State_screen.dart';

/// [STATE SELECTION SCREEN]
/// Displays the list of states fetched live from `GET /api/v1/civic/countries/{countryId}/states`.
/// All data comes dynamically from the API — no hardcoded mock lists.
class StateSelectionScreen extends StatefulWidget {
  final int countryId;
  final String countryName;

  const StateSelectionScreen({
    super.key,
    this.countryId = 13,
    this.countryName = 'INDIA',
  });

  @override
  State<StateSelectionScreen> createState() => _StateSelectionScreenState();
}

class _StateSelectionScreenState extends State<StateSelectionScreen> {
  late Future<List<StateItemModel>> _statesFuture;
  final CountryProfileRepository _repository = CountryProfileRepository();

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  void _loadStates() {
    _statesFuture = _repository.fetchCountryStatesList(countryId: widget.countryId);
  }

  Future<void> _refreshStates() async {
    setState(() {
      _loadStates();
    });
    await _statesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final double topPadding = mediaQuery.padding.top;
    final double bottomPadding = mediaQuery.padding.bottom;

    // Responsive measurements via MediaQuery
    final double headerHorizontalPadding = screenWidth * (20.0 / 375.0);
    final double headerVerticalPadding = screenHeight * (16.0 / 812.0);
    final double cardMarginHorizontal = screenWidth * (16.0 / 375.0);
    // Reduced spacing between cards using MediaQuery
    final double cardMarginBottom = screenHeight * (6.0 / 812.0);
    final double cardPaddingHorizontal = screenWidth * (18.0 / 375.0);
    final double cardPaddingVertical = screenHeight * (12.0 / 812.0);
    final double cardRadius = screenWidth * (14.0 / 375.0);
    final double sheetRadius = screenWidth * (24.0 / 375.0);
    // Space between Assembly Seats and Lok Sabha Seats
    final double seatsSpacing = screenWidth * (28.0 / 375.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFFE3A31),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF483D),
                Color(0xFFFE3A31),
              ],
            ),
          ),
          child: Column(
            children: [
              // ── TOP HEADER BAR ──
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding + headerVerticalPadding * 0.5,
                  bottom: headerVerticalPadding,
                  left: headerHorizontalPadding,
                  right: headerHorizontalPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // COUNTRY INDIA ▼
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'COUNTRY ',
                          style: TextStyle(
                            fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          widget.countryName.toUpperCase(),
                          style: TextStyle(
                            fontSize: (screenWidth * (17.0 / 375.0)).clamp(15.0, 19.0),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: screenWidth * (6.0 / 375.0)),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: (screenWidth * (22.0 / 375.0)).clamp(20.0, 24.0),
                        ),
                      ],
                    ),

                    // Close Button ✕
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * (4.0 / 375.0)),
                        color: Colors.transparent,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: (screenWidth * (24.0 / 375.0)).clamp(22.0, 26.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── WHITE ROUNDED SHEET BODY ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(sheetRadius),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FutureBuilder<List<StateItemModel>>(
                    future: _statesFuture,
                    builder: (context, snapshot) {
                      // 1. Loading State
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFFFE3A31),
                            strokeWidth: (screenWidth * (3.0 / 375.0)).clamp(2.0, 4.0),
                          ),
                        );
                      }

                      // 2. Error State
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: cardMarginHorizontal),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: screenWidth * (48.0 / 375.0),
                                  color: const Color(0xFFFE3A31),
                                ),
                                SizedBox(height: screenHeight * (12.0 / 812.0)),
                                Text(
                                  'Failed to load states from server',
                                  style: TextStyle(
                                    fontSize: (screenWidth * (15.0 / 375.0)).clamp(14.0, 16.0),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                SizedBox(height: screenHeight * (16.0 / 812.0)),
                                ElevatedButton(
                                  onPressed: _refreshStates,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFE3A31),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(screenWidth * (8.0 / 375.0)),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * (24.0 / 375.0),
                                      vertical: screenHeight * (10.0 / 812.0),
                                    ),
                                  ),
                                  child: const Text('RETRY'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final states = snapshot.data ?? [];

                      // 3. Empty State
                      if (states.isEmpty) {
                        return RefreshIndicator(
                          color: const Color(0xFFFE3A31),
                          onRefresh: _refreshStates,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: screenHeight * 0.25),
                              Center(
                                child: Text(
                                  'No states available',
                                  style: TextStyle(
                                    fontSize: (screenWidth * (15.0 / 375.0)).clamp(14.0, 16.0),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // 4. Loaded State — API items
                      return RefreshIndicator(
                        color: const Color(0xFFFE3A31),
                        onRefresh: _refreshStates,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: screenHeight * (16.0 / 812.0),
                            bottom: bottomPadding + screenHeight * (20.0 / 812.0),
                          ),
                          itemCount: states.length,
                          itemBuilder: (context, index) {
                            final state = states[index];

                            return Container(
                              margin: EdgeInsets.only(
                                left: cardMarginHorizontal,
                                right: cardMarginHorizontal,
                                bottom: cardMarginBottom,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(cardRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(cardRadius),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(cardRadius),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StateProfileScreen(
                                          stateId: state.id,
                                          stateName: state.name,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: cardPaddingHorizontal,
                                      vertical: cardPaddingVertical,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.name,
                                          style: TextStyle(
                                            fontSize: (screenWidth * (15.0 / 375.0)).clamp(14.0, 16.0),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1E1E1E),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        if (state.hasBothSeats) ...[
                                          SizedBox(height: screenHeight * (5.0 / 812.0)),
                                          Row(
                                            children: [
                                              Text(
                                                state.assemblySeatsText,
                                                style: TextStyle(
                                                  fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(0xFF757575),
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                              SizedBox(width: seatsSpacing),
                                              Text(
                                                state.lokSabhaSeatsText,
                                                style: TextStyle(
                                                  fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(0xFF757575),
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ] else if (state.formattedElectoralFootprint.isNotEmpty) ...[
                                          SizedBox(height: screenHeight * (5.0 / 812.0)),
                                          Text(
                                            state.formattedElectoralFootprint,
                                            style: TextStyle(
                                              fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF757575),
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
