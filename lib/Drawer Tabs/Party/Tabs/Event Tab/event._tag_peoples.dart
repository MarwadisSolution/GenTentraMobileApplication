import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'event_modal.dart';

class EventTaggedPeopleDialog extends StatelessWidget {
  final List<Tagged> taggedPeople;

  const EventTaggedPeopleDialog({
    super.key,
    required this.taggedPeople,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Tagged> taggedPeople,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => EventTaggedPeopleDialog(
        taggedPeople: taggedPeople,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    print("Tagged Ones");
print(taggedPeople);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: w * 0.9,
        height: h * 0.65,
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                12,
                12,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tagged People',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(12, 12, 12, 1),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              color: Color.fromRGBO(215, 215, 220, 1),
              height: 1,
            ),

            // ---------------- CONTENT ----------------
            Expanded(
              child: taggedPeople.isEmpty
                  ? const Center(
                child: Text(
                  'No people tagged',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(101, 101, 121, 1),
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                itemCount: taggedPeople.length,
                separatorBuilder: (_, __) {
                  return const Divider(
                    color: Color.fromRGBO(215, 215, 220, 1),
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  final person = taggedPeople[index];
                    print("Person-> ${person.partyInitial}");
                  return _TaggedPersonTile(
                    person: person,
                  );
                },
              ),
            ),

            // ---------------- CLOSE BUTTON ----------------
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                h * 0.02,
              ),
              child: SizedBox(
                width: double.infinity,
                height: h * 0.05,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFFFF2164),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(
                        color: Color(0xFFFF2164),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
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

class _TaggedPersonTile extends StatelessWidget {
  final Tagged person;

  const _TaggedPersonTile({
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = person.photoUrl;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),

      leading: CircleAvatar(
        radius: 22,
        backgroundImage:
        imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage("$api${imageUrl}")
            : null,
        child: imageUrl == null || imageUrl.isEmpty
            ? Icon(Icons.person,color: Colors.black,):null,
      ),

      title: Text(
        person.name ?? 'Unknown',
        style: const TextStyle(
          color: Color.fromRGBO(46, 46, 56, 1),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      //
      // subtitle: person.type != null
      //     ? Text(
      //   person.type!,
      //   style: const TextStyle(
      //     color: Color.fromRGBO(101, 101, 121, 1),
      //     fontSize: 12,
      //   ),
      // )
      //     : null,
    );
  }

  static String _initial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    return name.trim()[0].toUpperCase();
  }
}