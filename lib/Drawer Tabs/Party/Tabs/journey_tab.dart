import 'package:flutter/cupertino.dart';
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
  @override
  void initState() {
    super.initState();

    journeys = List.from(widget.journeys);

    journeys.sort(
          (a, b) =>
          (int.tryParse(a.year) ?? 0)
              .compareTo(int.tryParse(b.year) ?? 0),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size.width;
    if (journeys.isEmpty) {
      return const Center(
        child: Text("No journey available"),
      );
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
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.network(
              journey.imagePath == null
                  ? ""
                  : journey.imagePath!.startsWith("/api/")
                  ? "$api${journey.imagePath}"
                  : journey.imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.05),
          Center(
            child: Text(
              journey.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF070707)
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: MediaQuery.of(context).size.height*0.006,
              width: MediaQuery.of(context).size.width*0.09,
              decoration: BoxDecoration(
                color: Color(0xFFFB5051),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.02),
          Text(
            journey.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF000000).withOpacity(0.6)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: journeys.length,
              itemBuilder: (context, index) {

                final item = journeys[index];
                final itemYear = item.year;

                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        isSelected ?  Container(
                          width:  74 ,
                          height: 74 ,
                          decoration: BoxDecoration(
                            color:  Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                itemYear,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.31
                                ),
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ):
                        Text(
                          itemYear,
                          style: TextStyle(
                            color: ColorScheme.of(context).onSurface.withOpacity(0.4),
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.textScalerOf(context).scale(16)
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.06),
        ],
      ),
    );
  }
}
