import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_timeline_selector.dart';

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
      viewportFraction: 0.82, // shows part of adjacent images
    );
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    if (journeys.isEmpty) {
      return const Center(child: Text("No journey available"));
    }
    final journey = journeys[selectedIndex];

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// Image
          SizedBox(
            height: size * 0.8,
            child: PageView.builder(
              controller: _pageController,
              itemCount: journeys.length,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Center(
            child: Text(
              journey.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF070707),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.006,
              width: MediaQuery.of(context).size.width * 0.09,
              decoration: BoxDecoration(color: Color(0xFFFB5051)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            journey.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF000000).withOpacity(0.6)),
          ),
          const SizedBox(height: 40),
          ReusableTimelineSelector(
            items: journeys.map((e) => e.year).toList(),
            selectedIndex: selectedIndex,
            onChanged: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );

              setState(() {
                selectedIndex = index;
              });
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.06),
        ],
      ),
    );
  }
}
