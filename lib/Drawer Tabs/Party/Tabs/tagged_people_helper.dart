import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/reusable_functions.dart';

import '../../../Reusable Functions/reusable_functions.dart';
import '../party_page_data.dart';
import 'Feed Tab/reusable_functions.dart';

class TaggedPeopleHandler {
  final BuildContext context;
  final FeedApis api;

  TaggedPeopleHandler({
    required this.context,
    required this.api,
  });

  /// Opens the dialog showing currently tagged people.
  Future<void> showTaggedPeopleDialog({
    required List<Tagged> taggedPeople,
    required VoidCallback onChanged,
  }) async {
    await TaggedPeopleDialog.show(
      context: context,
      taggedPeople: taggedPeople,
      onAddMore: () async {
        await addMoreTaggedPeople(
          taggedPeople: taggedPeople,
          onChanged: onChanged,
        );
      },
    );

    if (context.mounted) {
      onChanged();
    }
  }

  /// Opens the picker and adds/removes tagged people.
  Future<void> addMoreTaggedPeople({
    required List<Tagged> taggedPeople,
    required VoidCallback onChanged,
  }) async {
    final result = await LeaderPickerDialog.show(
      context: context,
      searchFunction: (String text) {
        return api.searchBarData(text, null);
      },
      isNew: false,
      single: false,
      existingTagged: taggedPeople,
    );

    if (result == null) {
      return;
    }

    final List<Tagged> added =
        (result['added'] as List<Tagged>?) ?? [];

    final List<dynamic> removed =
        (result['removed'] as List<dynamic>?) ?? [];

    // Remove people
    taggedPeople.removeWhere(
          (person) => removed.contains(person.id),
    );

    // Add people
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

    if (context.mounted) {
      onChanged();
    }
  }
}

///-------------------------
///------------------Search Bar for tagging
class LeaderPickerDialog extends StatefulWidget {
  final Future<List<LeaderModel>> Function(String text) searchFunction;
  final bool isNew;
  final bool single;
  final List<Tagged> existingTagged;

  const LeaderPickerDialog({
    super.key,
    required this.searchFunction,
    required this.isNew,
    required this.single,
    this.existingTagged = const [],
  });

  static Future<Map<String, dynamic>?> show({
    required Future<List<LeaderModel>> Function(String text) searchFunction,
    required bool isNew,
    required bool single,
    required BuildContext context,
    List<Tagged> existingTagged = const [],
  }) {
    return showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          LeaderPickerDialog(
            searchFunction: searchFunction,
            isNew: isNew,
            single: single,
            existingTagged: existingTagged,
          ),
    );
  }

  @override
  State<LeaderPickerDialog> createState() => _LeaderPickerDialogState();
}

class _LeaderPickerDialogState extends State<LeaderPickerDialog> {
  final TextEditingController controller = TextEditingController();

  List<LeaderModel> leaders = [];

  List<LeaderModel> selectedLeaders = [];

  List<LeaderModel> removedExistingLeaders = [];

  bool loading = false;

  Timer? timer;

  Future<void> search(String text) async {
    if (text.isEmpty) {
      setState(() {
        leaders = [];
      });
      return;
    }

    setState(() => loading = true);

    try {
      leaders = await widget.searchFunction(text);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void debounce(String value) {
    timer?.cancel();

    timer = Timer(const Duration(milliseconds: 300), () => search(value));
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery
        .of(context)
        .size
        .width;
    final h = MediaQuery
        .of(context)
        .size
        .height;
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.9,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.75,
        child: Stack(
          children: [
            if (leaders.isEmpty && controller.text.isEmpty)
              Center(child: Text("Please search")),
            if (leaders.isEmpty && controller.text.isNotEmpty)
              Center(child: Text("No results found")),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Top Leaders",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(12, 12, 12, 1),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    PartyPageData.searchBy,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: h * 0.065,
                    child: TextField(
                      controller: controller,
                      onChanged: debounce,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: PartyPageData.searchBy,
                        hintStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Color.fromRGBO(199, 199, 199, 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Semi-circle
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(199, 199, 199, 0.2),
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(199, 199, 199, 0.2),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(199, 199, 199, 0.2),
                            width: 2,
                          ),
                        ),

                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            height: 30,
                            width: 79,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(194, 193, 193, 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'SEARCH',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Divider(color: Color.fromRGBO(215, 215, 220, 1)),
                  SizedBox(height: h * 0.01),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: h * 0.10),
                      itemCount: leaders.length,
                      itemBuilder: (_, index) {
                        final leader = leaders[index];

                        final alreadyTagged = widget.existingTagged.any(
                              (e) => e.id == leader.id,
                        );

                        final isSelected = selectedLeaders.any(
                              (e) => e.id == leader.id,
                        );

                        final isRemoved = removedExistingLeaders.any(
                              (e) => e.id == leader.id,
                        );

                        final checked =
                            !isRemoved && (alreadyTagged || isSelected);
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                final alreadyTagged = widget.existingTagged.any(
                                      (e) => e.id == leader.id,
                                );

                                setState(() {
                                  // Previously tagged leader
                                  if (alreadyTagged) {
                                    final removedIndex = removedExistingLeaders
                                        .indexWhere((e) => e.id == leader.id);

                                    if (removedIndex != -1) {
                                      // User selected it again
                                      removedExistingLeaders.removeAt(
                                        removedIndex,
                                      );
                                    } else {
                                      // User wants to untag it
                                      removedExistingLeaders.add(leader);
                                    }

                                    return;
                                  }

                                  // Newly selected leader
                                  final index = selectedLeaders.indexWhere(
                                        (e) => e.id == leader.id,
                                  );

                                  if (index != -1) {
                                    selectedLeaders.removeAt(index);
                                  } else {
                                    if (widget.single) {
                                      selectedLeaders.clear();
                                    }

                                    selectedLeaders.add(leader);
                                  }
                                });
                              },
                              leading: CircleAvatar(
                                backgroundImage: leader.image != null
                                    ? NetworkImage('$api${leader.image!}')
                                    : null,
                                child: leader.image == null
                                    ? Text(leader.name[0])
                                    : null,
                              ),
                              title: Text(
                                leader.name,
                                style: TextStyle(
                                  color: Color.fromRGBO(46, 46, 56, 1),
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                "${leader.designation.toUpperCase()}, ${leader
                                    .uniqueId.toUpperCase()}",
                                style: TextStyle(
                                  color: Color.fromRGBO(101, 101, 121, 1),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Icon(
                                Icons.check_circle,
                                color: checked ? Colors.green : Colors.grey,
                              ),
                            ),
                            const Divider(
                              color: Color.fromRGBO(215, 215, 220, 1),
                              height: 1,
                              thickness: 1,
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
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: w * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: h * 0.05,
                            width: w * 0.27,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Color(0xFFFF2164)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: w * 0.015,
                                right: w * 0.01,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    PartyPageData.crossIcon,
                                    color: Color(0xFFFF2164),
                                    height: h * 0.02,
                                  ),
                                  SizedBox(width: w * 0.02),
                                  Text(
                                    'CANCEL',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFFF2164),
                                      fontWeight: FontWeight.w500,
                                      fontSize: (w * 0.04).clamp(14.0, 16.0),
                                    ),
                                  ),
                                ],
                              ),
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
                                  content: Text("Please select a leader"),
                                ),
                              );
                              return;
                            }

                            final List<Tagged> taggedLeaders = selectedLeaders
                                .map((leader) {
                              return Tagged(
                                type: "POLITICIAN",
                                id: leader.id,
                                name: leader.name,
                                photoUrl: leader.image,
                              );
                            })
                                .toList();

                            Navigator.pop(context, {
                              'added': taggedLeaders,
                              'removed': removedExistingLeaders
                                  .map((e) => e.id)
                                  .toList(),
                            });
                          },
                          child: Container(
                            height: h * 0.05,
                            width: w * 0.2,
                            decoration: BoxDecoration(
                              gradient: GradientColors.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Color(0xFFFF2164)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: w * 0.015,
                                right: w * 0.01,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    PartyPageData.addIcon,
                                    color: ColorScheme
                                        .of(context)
                                        .surface,
                                    height: h * 0.02,
                                  ),
                                  SizedBox(width: w * 0.02),
                                  Text(
                                    'ADD',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorScheme
                                          .of(context)
                                          .surface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: (w * 0.04).clamp(14.0, 16.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}