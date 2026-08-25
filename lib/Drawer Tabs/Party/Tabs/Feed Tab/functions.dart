import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'feed_model.dart';

String getTimeAgo(DateTime? timestamp) {
  if (timestamp == null) return "";

  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inSeconds < 60) {
    return "${difference.inSeconds} sec";
  }

  if (difference.inMinutes < 60) {
    return "${difference.inMinutes} min";
  }

  if (difference.inHours < 24) {
    return "${difference.inHours} hr";
  }

  if (difference.inDays < 7) {
    return "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}";
  }

  if (difference.inDays < 30) {
    final weeks = difference.inDays ~/ 7;
    return "$weeks ${weeks == 1 ? 'week' : 'weeks'}";
  }

  if (difference.inDays < 365) {
    final months = difference.inDays ~/ 30;
    return "$months ${months == 1 ? 'month' : 'months'}";
  }

  final years = difference.inDays ~/ 365;
  return "$years ${years == 1 ? 'year' : 'years'}";
}
class ShowingTaggedPersons extends StatelessWidget {
  final List<Tagged>? tagged;

  const ShowingTaggedPersons({
    super.key,
    this.tagged,
  });

  void _showAllTaggedPersons(
      BuildContext context,
      List<Tagged> tagged,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: tagged.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                tagged[index].name ?? "-",
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    if (tagged == null || tagged!.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleTagged = tagged!.take(3).toList();
    final remainingCount = tagged!.length - 3;

    return Padding(
      padding: EdgeInsets.only(
        left: w * 0.044,
        right: w * 0.044,
        bottom: h * 0.008,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...visibleTagged.map((person) {
              return Container(
                margin: EdgeInsets.only(right: w * 0.02),
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.025,
                  vertical: h * 0.006,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFF000000).withOpacity(0.08),
                ),
                child: Text(
                  person.name ?? "-",
                  style: TextStyle(
                    fontSize: (w * 0.032).clamp(12.0, 15.0),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.36,
                    color: const Color(0xFF121212),
                  ),
                ),
              );
            }),

            if (remainingCount > 0)
              InkWell(
                onTap: () {
                  _showAllTaggedPersons(
                    context,
                    tagged!,
                  );
                },
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.025,
                    vertical: h * 0.006,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0xFF000000).withOpacity(0.08),
                  ),
                  child: Text(
                    "+$remainingCount",
                    style: TextStyle(
                      fontSize: (w * 0.032).clamp(12.0, 15.0),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.36,
                      color: const Color(0xFF121212),
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