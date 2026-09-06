import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart' hide Tagged;
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_modal.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/reusable_functions.dart';

import '../../../../Reusable Functions/reusable_functions.dart';

class EventTaggedPeopleHandler {
  final BuildContext context;
  final FeedApis api;

  EventTaggedPeopleHandler({
    required this.context,
    required this.api,
  });

  Future<void> showTaggedPeopleDialog({
    required List<Tagged> taggedPeople,
    required VoidCallback onChanged,
  }) async {
    await EventLeaderPickerDialog.show(
      context: context,
      searchFunction: (String text) {
        return api.searchBarData(text, null);
      },
      existingTagged: taggedPeople,
    );

    if (context.mounted) {
      onChanged();
    }
  }

  Future<List<Tagged>?> addMoreTaggedPeople({
    required List<Tagged> taggedPeople,
  }) async {
    final result = await EventLeaderPickerDialog.show(
      context: context,
      searchFunction: (String text) {
        return api.searchBarData(text, null);
      },
      existingTagged: taggedPeople,
    );

    if (result == null) {
      return null;
    }

    final added = result['added'] as List<Tagged>? ?? [];
    final removed = result['removed'] as List<dynamic>? ?? [];

    taggedPeople.removeWhere(
          (person) => removed.contains(person.id),
    );

    for (final newPerson in added) {
      final alreadyTagged = taggedPeople.any(
            (person) =>
        person.id == newPerson.id &&
            person.type == newPerson.type,
      );

      if (!alreadyTagged) {
        taggedPeople.add(newPerson);
      }
    }

    return taggedPeople;
  }
}


class EventLeaderPickerDialog extends StatefulWidget {
  final Future<List<LeaderModel>> Function(String text) searchFunction;
  final List<Tagged> existingTagged;

  const EventLeaderPickerDialog({
    super.key,
    required this.searchFunction,
    required this.existingTagged,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required Future<List<LeaderModel>> Function(String text) searchFunction,
    required List<Tagged> existingTagged,
  }) {
    return showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EventLeaderPickerDialog(
        searchFunction: searchFunction,
        existingTagged: existingTagged,
      ),
    );
  }

  @override
  State<EventLeaderPickerDialog> createState() =>
      _EventLeaderPickerDialogState();
}

class _EventLeaderPickerDialogState
    extends State<EventLeaderPickerDialog> {
  final TextEditingController controller = TextEditingController();

  List<LeaderModel> leaders = [];
  List<LeaderModel> selectedLeaders = [];
  List<LeaderModel> removedExistingLeaders = [];

  bool loading = false;

  Timer? timer;

  Future<void> search(String text) async {
    if (text.trim().isEmpty) {
      setState(() {
        leaders = [];
      });
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await widget.searchFunction(text);

      if (mounted) {
        setState(() {
          leaders = result;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void debounce(String value) {
    timer?.cancel();

    timer = Timer(
      const Duration(milliseconds: 300),
          () => search(value),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: w * 0.9,
        height: h * 0.75,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tag People",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    PartyPageData.searchBy,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: h * 0.065,
                    child: TextField(
                      controller: controller,
                      onChanged: debounce,
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: PartyPageData.searchBy,
                        hintStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        filled: true,
                        fillColor:
                        const Color.fromRGBO(199, 199, 199, 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(9),
                          child: Container(
                            width: 79,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(
                                194,
                                193,
                                193,
                                1,
                              ),
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'SEARCH',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Divider(
                    color: Color.fromRGBO(215, 215, 220, 1),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: loading
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : leaders.isEmpty
                        ? Center(
                      child: Text(
                        controller.text.isEmpty
                            ? "Please search"
                            : "No results found",
                      ),
                    )
                        : ListView.builder(
                      itemCount: leaders.length,
                      itemBuilder: (_, index) {
                        final leader = leaders[index];

                        final alreadyTagged =
                        widget.existingTagged.any(
                              (e) => e.id == leader.id,
                        );

                        final isSelected =
                        selectedLeaders.any(
                              (e) => e.id == leader.id,
                        );

                        final isRemoved =
                        removedExistingLeaders.any(
                              (e) => e.id == leader.id,
                        );

                        final checked =
                            !isRemoved &&
                                (alreadyTagged || isSelected);

                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                setState(() {
                                  if (alreadyTagged) {
                                    final removedIndex =
                                    removedExistingLeaders
                                        .indexWhere(
                                          (e) =>
                                      e.id == leader.id,
                                    );

                                    if (removedIndex != -1) {
                                      removedExistingLeaders
                                          .removeAt(
                                        removedIndex,
                                      );
                                    } else {
                                      removedExistingLeaders
                                          .add(leader);
                                    }

                                    return;
                                  }

                                  final selectedIndex =
                                  selectedLeaders
                                      .indexWhere(
                                        (e) =>
                                    e.id == leader.id,
                                  );

                                  if (selectedIndex != -1) {
                                    selectedLeaders.removeAt(
                                      selectedIndex,
                                    );
                                  } else {
                                    selectedLeaders.add(
                                      leader,
                                    );
                                  }
                                });
                              },

                              leading: CircleAvatar(
                                backgroundImage:
                                leader.image != null
                                    ? NetworkImage(
                                  '$api${leader.image!}',
                                )
                                    : null,
                                child: leader.image == null
                                    ? Text(
                                  leader.name[0],
                                )
                                    : null,
                              ),

                              title: Text(
                                leader.name,
                                style: const TextStyle(
                                  color: Color.fromRGBO(
                                    46,
                                    46,
                                    56,
                                    1,
                                  ),
                                  fontSize: 14,
                                ),
                              ),

                              subtitle: Text(
                                "${leader.designation.toUpperCase()}, "
                                    "${leader.uniqueId.toUpperCase()}",
                                style: const TextStyle(
                                  color: Color.fromRGBO(
                                    101,
                                    101,
                                    121,
                                    1,
                                  ),
                                  fontSize: 14,
                                ),
                              ),

                              trailing: Icon(
                                Icons.check_circle,
                                color: checked
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),

                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color.fromRGBO(
                                215,
                                215,
                                220,
                                1,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: h * 0.08,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: h * 0.05,
                        width: w * 0.27,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFFF2164),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              PartyPageData.crossIcon,
                              color: const Color(0xFFFF2164),
                              height: h * 0.02,
                            ),
                            SizedBox(width: w * 0.02),
                            const Text(
                              'CANCEL',
                              style: TextStyle(
                                color: Color(0xFFFF2164),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: w * 0.07),

                    InkWell(
                      onTap: () {
                        if (selectedLeaders.isEmpty &&
                            removedExistingLeaders.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select a person",
                              ),
                            ),
                          );
                          return;
                        }

                        final taggedPeople =
                        selectedLeaders.map((leader) {
                          return Tagged(
                            type: "POLITICIAN",
                            id: leader.id,
                            name: leader.name,
                            photoUrl: leader.image,
                          );
                        }).toList();

                        Navigator.pop(
                          context,
                          {
                            'added': taggedPeople,
                            'removed':
                            removedExistingLeaders
                                .map((e) => e.id)
                                .toList(),
                          },
                        );
                      },
                      child: Container(
                        height: h * 0.05,
                        width: w * 0.20,
                        decoration: BoxDecoration(
                          gradient:
                          GradientColors.primaryGradient,
                          borderRadius:
                          BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFFF2164),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              PartyPageData.addIcon,
                              color:
                              ColorScheme.of(context).surface,
                              height: h * 0.02,
                            ),
                            SizedBox(width: w * 0.02),
                            Text(
                              'ADD',
                              style: TextStyle(
                                color:
                                ColorScheme.of(context).surface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}