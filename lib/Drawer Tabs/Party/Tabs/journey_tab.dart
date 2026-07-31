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
  late List<JourneyModel> journeys;
  late PageController _pageController;
  late PageController _timelineController;
  late PageController _textController; // Added missing controller

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
      viewportFraction: 0.82,
    );

    _timelineController = PageController(
      initialPage: selectedIndex,
      viewportFraction: 0.25,
    );

    _textController = PageController(
      initialPage: selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timelineController.dispose();
    _textController.dispose(); // Added missing disposal
    super.dispose();
  }

  // Helper to keep all 3 PageView controllers synchronized
  void _onYearChanged(int newIndex) {
    if (selectedIndex == newIndex) return;

    setState(() {
      selectedIndex = newIndex;
    });

    void animateIfNeeded(PageController controller) {
      if (controller.hasClients && controller.page?.round() != newIndex) {
        controller.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    animateIfNeeded(_pageController);
    animateIfNeeded(_timelineController);
    animateIfNeeded(_textController);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    if (journeys.isEmpty) {
      return Center(
        child: Text(
          "No journey available",
          style: TextStyle(color: ColorScheme.of(context).onSurface),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView(
        children: [
          /// 1. IMAGE CAROUSEL
          SizedBox(
            height: size * 0.7,
            child: PageView.builder(
              controller: _pageController,
              itemCount: journeys.length,
              onPageChanged: _onYearChanged,
              itemBuilder: (context, index) {
                final item = journeys[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: selectedIndex == index ? 0 : 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
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
                    const Center(child: Icon(Icons.broken_image)),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height*0.02),

          /// 2. TEXT CONTENT PAGEVIEW (Title, Red Line, Description)
          SizedBox(
            height: MediaQuery.of(context).size.height*0.27,
            child: PageView.builder(
              controller: _textController,
              itemCount: journeys.length,
              onPageChanged: _onYearChanged,
              itemBuilder: (context, index) {
                final item = journeys[index];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Column(
                    children: [
                      /// Title
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                          fontSize: MediaQuery.textScalerOf(context).scale(20),
                          letterSpacing: 0.31,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF070707),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),

                      /// Red Line Divider
                      Container(
                        height: MediaQuery.of(context).size.height * 0.006,
                        width: MediaQuery.of(context).size.width * 0.09,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFB5051),
                        ),
                      ),
                      SizedBox(height:  MediaQuery.of(context).size.height*0.02),

                      /// Description
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.textScalerOf(context).scale(14),
                          color: const Color(0xFF000000).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          /// 3. CIRCULAR TIMELINE PICKER
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.09,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center Spotlight Circle with Red Indicator Dot
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: const Alignment(0, 0.65),
                    child: Container(
                      width:6 ,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFE3A31),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Horizontal Timeline PageView
                PageView.builder(
                  controller: _timelineController,
                  itemCount: journeys.length,
                  onPageChanged: _onYearChanged,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedIndex;

                    return Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isSelected ? MediaQuery.textScalerOf(context).scale(20) : MediaQuery.textScalerOf(context).scale(16),
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w300,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF000000).withOpacity(0.4),
                        ),
                        child: Text(journeys[index].year),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
        ],
      ),
    );
  }
}