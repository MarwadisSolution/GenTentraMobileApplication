import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import '../../PoliticianProfile/politician_page_data.dart';
import '../member_directory.dart';

class LeadershipTab extends StatefulWidget {
  final String? partyState;
  final List<LeaderGroupModel> leaders;
  final List<MemberDirectoryModel> members;
  final Map<String, List<MemberDirectoryModel>> membersByRegion;
  const LeadershipTab({
    super.key,
    this.partyState,
    required this.leaders,
    required this.members,
    required this.membersByRegion,
  });

  @override
  State<LeadershipTab> createState() => _LeadershipTabState();
}

class _LeadershipTabState extends State<LeadershipTab> {
  String _getLeaderSurname(LeaderModel leader) {
    if (leader.surname != null && leader.surname!.trim().isNotEmpty) {
      return leader.surname!.trim();
    }
    try {
      final matchingMember = widget.members.firstWhere(
        (m) => m.politicianId == leader.politicianId,
      );
      if (matchingMember.surname != null &&
          matchingMember.surname!.trim().isNotEmpty) {
        return matchingMember.surname!.trim();
      }
    } catch (_) {}

    final parts = leader.name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }

    return leader.designation;
  }

  String _getLeaderFirstName(LeaderModel leader) {
    final surname = _getLeaderSurname(leader);
    final name = leader.name.trim();
    if (surname.isNotEmpty &&
        surname != leader.designation &&
        name.toLowerCase().endsWith(surname.toLowerCase()) &&
        name.length > surname.length) {
      return name.substring(0, name.length - surname.length).trim();
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final imageWidth = w >= 900
        ? 220.0
        : w >= 600
        ? 180.0
        : w * (280 / 360);

    if (widget.leaders.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: h * 0.05),
        child: Center(
          child: Text(
            'No Groups Present',
            style: TextStyle(color: Colors.black, fontSize: w * 0.045),
          ),
        ),
      );
    }

    // Display leaders from the first group.
    final firstGroupLeaders = widget.leaders.first;
    final leaders = firstGroupLeaders.leaders;
    final List<LeaderModel> secondLeaders = widget.leaders.length > 1
        ? widget.leaders[1].leaders
        : [];

    if (leaders.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(h * 0.045),
        child: Center(
          child: Text(
            "No leaders found",
            style: TextStyle(
              color: ColorScheme.of(context).onSurface,
              fontSize: w * 0.045,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: h * (480 / 736),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: w * 0.017, vertical: 10),
            itemCount: leaders.length,
            separatorBuilder: (_, __) => SizedBox(width: w * 0.025),
            itemBuilder: (context, index) {
              final leader = leaders[index];
              final imagePath = leader.imagePath;

              return SizedBox(
                width: imageWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leader image.
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(w * 0.05),
                        child: InkWell(
                          onTap: () {
                            PoliticianPageData.navigateTo(
                              context,
                              politicianId: leader.politicianId,
                              photoUrl: leader.imagePath,
                              name: leader.name,
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: imagePath == null || imagePath.isEmpty
                                ? ColoredBox(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        size: w * 0.6,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : buildImageWidget(
                                    imagePath,
                                    fit: BoxFit.cover,
                                  ),
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

        SizedBox(height: h * 0.01),
        //widget.leaders.length>1?
        GridView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.025,
            vertical: w * 0.005,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 127,
            mainAxisExtent: (((w * 0.353).clamp(90.0, 127.0)) * 1.05) + 40.0,
            crossAxisSpacing: w * 0.025,
            mainAxisSpacing: w * 0.025,
          ),

          // Always show up to 14 members + 1 View More card.
          itemCount: secondLeaders.length > 14 ? 15 : secondLeaders.length + 1,

          itemBuilder: (context, index) {
            if (index == 14 || index == secondLeaders.length) {
              return Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberDirectory(
                          partyState: widget.partyState,
                          leaders: widget.leaders,
                          members: widget.members,
                          membersByRegion: widget.membersByRegion,
                          title: "INDIA PRESENCE",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: (w * 0.353).clamp(90.0, 127.0),
                    height: ((w * 0.353).clamp(90.0, 127.0)) * 1.05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w * 0.04),
                      border: Border.all(color: const Color(0xFFFD8454)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          PartyPageData.viewAllIcon,
                          color: Color(0xFFFE3A31),
                        ),
                        SizedBox(height: h * 0.01),
                        Flexible(
                          child: Text(
                            PartyPageData.viewAll,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.22,
                              fontSize: (w * 0.03).clamp(10.0, 12.0),
                              color: const Color(0xFFFE3A31),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Your existing member card code starts here.
            final leader = secondLeaders[index];
            final imagePath = leader.imagePath;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    PoliticianPageData.navigateTo(
                      context,
                      politicianId: leader.politicianId,
                      photoUrl: leader.imagePath,
                      name: leader.name,
                    );
                  },
                  child: SizedBox(
                    width: (w * 0.353).clamp(90.0, 127.0),
                    height: ((w * 0.353).clamp(90.0, 127.0)) * (105 / 100),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(w * 0.04),
                      child: imagePath == null || imagePath.isEmpty
                          ? ColoredBox(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: w * 0.4,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : buildImageWidget(imagePath, fit: BoxFit.fill),
                    ),
                  ),
                ),
                SizedBox(height: w * 0.007),
                Text(
                  _getLeaderFirstName(leader),

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.15,
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _getLeaderSurname(leader),

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.15,
                    fontSize: w * 0.04 - 1,
                    color: Colors.black,
                  ),
                ),
              ],
            );
          },
        ),
        Container(
          height: h * 0.008,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorScheme.of(context).onSurface.withValues(alpha: 0.08),
          ),
        ),
        if (widget.members.isNotEmpty)
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              contentPadding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: 2,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberDirectory(
                          partyState: widget.partyState,
                      leaders: widget.leaders,
                      members: widget.members,
                      membersByRegion: widget.membersByRegion,
                      title: "INDIA PRESENCE",
                    ),
                  ),
                );
              },
              leading: buildMembersPreview(widget.members, context),
              title: Text(
                PartyPageData.indiaPresence,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: w * 0.038,
                  letterSpacing: 0.5,
                ),
              ),
              subtitle: Text(
                '',
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: SizedBox(
                width: w * 0.06,
                height: h * 0.048,
                child: Center(
                  child: SvgPicture.asset(
                    "Assets/arrow.svg",
                    color: const Color(0xFFFE3A31),
                    width: 18,
                    height: 18,
                  ),
                ),
              ),
            ),
          ),
        // Show all groups except group 1 and group 2.
        ...widget.leaders.skip(2).map((group) {
          if (group.leaders.isEmpty) {
            return const SizedBox.shrink();
          }

          final previewLeaders = group.leaders.isNotEmpty
              ? group.leaders
              : widget.members;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1,
                thickness: 1,
                color: ColorScheme.of(context)
                    .onSurface
                    .withValues(alpha: 0.08),
              ),
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: 2,
                  ),
                  onTap: () {
                    final groupPoliticianIds = group.leaders
                        .map((leader) => leader.politicianId)
                        .toSet();

                    final groupMembers = widget.members
                        .where(
                          (member) =>
                              groupPoliticianIds.contains(member.politicianId),
                        )
                        .toList();

                    final groupMembersByRegion =
                        <String, List<MemberDirectoryModel>>{};

                    for (final member in groupMembers) {
                      groupMembersByRegion
                          .putIfAbsent(member.region, () => [])
                          .add(member);
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberDirectory(
                          partyState: widget.partyState,
                          leaders: [group],
                          members: groupMembers,
                          membersByRegion: groupMembersByRegion,
                          title: group.title,
                        ),
                      ),
                    );
                  },

                  leading: buildMembersPreview(previewLeaders, context),
                  title: Text(
                    group.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: w * 0.038,
                      letterSpacing: 0.5,
                    ),
                  ),
                  subtitle: Text(
                    '',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: SizedBox(
                    width: w * 0.06,
                    height: h * 0.048,
                    child: Center(
                      child: SvgPicture.asset(
                        'Assets/arrow.svg',
                        color: const Color(0xFFFE3A31),
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

Widget buildMembersPreview(
  List<dynamic> members,
  BuildContext context, {
  double size = 42.0,
}) {
  final previewMembers = members.take(3).toList();
  if (previewMembers.isEmpty) {
    return SizedBox(width: size, height: size);
  }

  final double overlap = size * 0.48;
  final double totalWidth = (previewMembers.length - 1) * overlap + size;

  return SizedBox(
    width: totalWidth,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: List.generate(previewMembers.length, (index) {
        final item = previewMembers[index];
        String imagePath = '';
        if (item is MemberDirectoryModel) {
          imagePath = item.imagePath;
        } else if (item is LeaderModel) {
          imagePath = item.imagePath ?? '';
        } else if (item is String) {
          imagePath = item;
        }

        return Positioned(
          left: index * overlap,
          top: 0,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAEAEA),
              ),
              child: ClipOval(
                child: imagePath.isNotEmpty
                    ? buildImageWidget(
                        imagePath,
                        width: size - 4,
                        height: size - 4,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 24,
                      ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}