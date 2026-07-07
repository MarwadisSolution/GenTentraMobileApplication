import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Reusable Functions/reusable_functions.dart';

class JourneyTab extends StatefulWidget {
  final Map<String, dynamic> journeyData;
  const JourneyTab({super.key, required this.journeyData});

  @override
  State<JourneyTab> createState() => _JourneyTabState();
}

class _JourneyTabState extends State<JourneyTab> {
  late List<dynamic> journeys;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();

    journeys = widget.journeyData["items"] ?? [];

    journeys.sort((a, b) =>
        DateTime.parse(a["occurredOn"])
            .compareTo(DateTime.parse(b["occurredOn"])));
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size.width;
    final journey = journeys[selectedIndex];

    final year = DateTime.parse(journey["occurredOn"]).year;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
           /// Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.network(
                "$api${journey["mediaUrl"]}",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              journey["title"],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              journey["body"],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: journeys.length,
                itemBuilder: (context, index) {

                  final item = journeys[index];

                  final itemYear =
                      DateTime.parse(item["occurredOn"]).year;

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
                      child: Column(
                        children: [
                          Container(
                            width: isSelected ? 52 : 40,
                            height: isSelected ? 52 : 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "$itemYear",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
