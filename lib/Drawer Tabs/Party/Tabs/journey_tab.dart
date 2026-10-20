import 'package:flutter/material.dart';
import '../../../Reusable Functions/reusable_functions.dart';
import '../party_page_modal.dart';

class JourneyTab extends StatefulWidget {
  final List<JourneyModel> journeys;

  const JourneyTab({super.key, required this.journeys});

  @override
  State<JourneyTab> createState() => _JourneyTabState();
}

class _JourneyTabState extends State<JourneyTab> {
  int selectedIndex = 0;
  bool _isSynchronizingPages = false;
  late List<JourneyModel> journeys;
  late PageController _pageController;
  late PageController _timelineController;
  late PageController _textController;

  @override
  void initState() {
    super.initState();

    journeys = List.from(widget.journeys);

    journeys.sort(
      (a, b) =>
          (int.tryParse(a.year) ?? 0).compareTo(int.tryParse(b.year) ?? 0),
    );

    _pageController = PageController(
      initialPage: selectedIndex,
      viewportFraction: 0.85,
    );

    _timelineController = PageController(
      initialPage: selectedIndex,
      viewportFraction: 0.22,
    );

    _textController = PageController(initialPage: selectedIndex);
  }

  @override
  void didUpdateWidget(covariant JourneyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journeys != widget.journeys) {
      setState(() {
        journeys = List.from(widget.journeys);
        journeys.sort(
          (a, b) =>
              (int.tryParse(a.year) ?? 0).compareTo(int.tryParse(b.year) ?? 0),
        );
        if (selectedIndex >= journeys.length) {
          selectedIndex = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timelineController.dispose();
    _textController.dispose();

    super.dispose();
  }

  void _onYearChanged(int newIndex) {
    if (!mounted) return;
    if (newIndex < 0 || newIndex >= journeys.length) return;
    if (selectedIndex == newIndex) return;

    setState(() {
      selectedIndex = newIndex;
    });

    if (_isSynchronizingPages) return;

    _isSynchronizingPages = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        await Future.wait([
          _animateToPageIfNeeded(_pageController, newIndex),
          _animateToPageIfNeeded(_timelineController, newIndex),
          _animateToPageIfNeeded(_textController, newIndex),
        ]);
      } finally {
        if (mounted) {
          _isSynchronizingPages = false;
        }
      }
    });
  }

  Future<void> _animateToPageIfNeeded(
    PageController controller,
    int index,
  ) async {
    if (!controller.hasClients) return;

    final currentPage = controller.page;

    if (currentPage == null) return;

    if ((currentPage - index).abs() < 0.01) return;

    await controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (journeys.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(height * 0.045),
        child: Center(
          child: Text(
            "No journey found",
            style: TextStyle(
              color: ColorScheme.of(context).onSurface,
              fontSize: size * 0.045,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height safely from constraints
          final availableHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : height * 0.8;

          return SizedBox(
            height: availableHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// 1. IMAGE CAROUSEL
                Container(
                  height: height * 0.01,
                  width: size,
                  color: Colors.white,
                ),
                SizedBox(
                  height: availableHeight * 0.6,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: journeys.length,
                    onPageChanged: _onYearChanged,
                    itemBuilder: (context, index) {
                      final item = journeys[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: selectedIndex == index ? 0 : 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size * 0.04),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          item.imagePath == null
                              ? ""
                              : item.imagePath!.startsWith("/api/")
                              ? "$api${item.imagePath}"
                              : item.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.image)),
                        ),
                      );
                    },
                  ),
                ),

                /// 2. TEXT CONTENT PAGEVIEW
                SizedBox(height: height * 0.02),
                SizedBox(
                  height: availableHeight * 0.25,
                  child: PageView.builder(
                    controller: _textController,
                    itemCount: journeys.length,
                    onPageChanged: _onYearChanged,
                    itemBuilder: (context, index) {
                      final item = journeys[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: size * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            /// Title
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: size * 0.052,
                                letterSpacing: 0.31,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF070707),
                              ),
                            ),
                            SizedBox(height: availableHeight * 0.01),

                            /// Red Line Divider
                            Container(
                              height: height * 0.004,
                              width: size * 0.09,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFB5051),
                              ),
                            ),
                            SizedBox(height: availableHeight * 0.015),

                            /// Description
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: size * 0.04,
                                    color: const Color(
                                      0xFF000000,
                                    ).withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// 3. CIRCULAR TIMELINE PICKER
                SizedBox(
                  height: availableHeight * 0.11,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: size * 0.18,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: const Alignment(0, 0.65),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFE3A31),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      PageView.builder(
                        controller: _timelineController,
                        itemCount: journeys.length,
                        onPageChanged: _onYearChanged,
                        itemBuilder: (context, index) {
                          final isSelected = index == selectedIndex;

                          return Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _onYearChanged(index),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isSelected
                                      ? MediaQuery.textScalerOf(
                                          context,
                                        ).scale(20)
                                      : MediaQuery.textScalerOf(
                                          context,
                                        ).scale(16),
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.w300,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(
                                          0xFF000000,
                                        ).withOpacity(0.4),
                                ),
                                child: Text(journeys[index].year),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
