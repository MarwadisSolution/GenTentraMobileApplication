import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import '../member_directory.dart';

class LeadershipTab extends StatefulWidget {
  final List<LeaderGroupModel> leaders;
  final List<MemberDirectoryModel> members;
  final Map<String, List<MemberDirectoryModel>> membersByRegion;

  const LeadershipTab({
    super.key,
    required this.leaders,
    required this.members,
    required this.membersByRegion,
  });

  @override
  State<LeadershipTab> createState() => _LeadershipTabState();
}

class _LeadershipTabState extends State<LeadershipTab> {
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
      return  Padding(
        padding:  EdgeInsets.only(top: h*0.05),
        child: Center(
          child: Text(
            'No Groups Present',
            style: TextStyle(color: Colors.black, fontSize: w*0.045),
          ),
        ),
      );
    }

    // Display leaders from the first group.
    final firstGroupLeaders = widget.leaders.first;
    final leaders = firstGroupLeaders.leaders;
    final List<LeaderModel> secondLeaders =
    widget.leaders.length > 1
        ? widget.leaders[1].leaders
        : [];

    if (leaders.isEmpty) {
      return Center(
        child: Text(
          'No Leaders Present',
          style: TextStyle(color: Colors.black, fontSize: w * 0.016),
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
                              : buildImageWidget(imagePath, fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.008),

                    Text(
                      leader.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: w * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.22,
                      ),
                    ),
                    Text(
                      leader.designation,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                        letterSpacing: 0.22,
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
            vertical: w * 0.01,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 127,
            mainAxisExtent: (MediaQuery.sizeOf(context).width * 0.58).clamp(
              175.0,
              220.0,
            ),
            crossAxisSpacing: MediaQuery.sizeOf(context).width * 0.025,
            mainAxisSpacing: MediaQuery.sizeOf(context).height * 0.016,
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
                          leaders: widget.leaders,
                          members: widget.members,
                          membersByRegion: widget.membersByRegion,
                          title: "INDIA PRESENCE",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: (w * 0.353).clamp(80.0, 110.0),
                    height: h * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w * 0.03),
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
                SizedBox(
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
                SizedBox(height: w * 0.007),
                Text(
                  leader.name,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  leader.designation,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: w * 0.04,
                    color: Color(0xFF666666),
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
            color: ColorScheme.of(context).onSurface.withOpacity(0.08),
          ),
        ),
        SizedBox(height: h * 0.02),
        ?widget.members.isNotEmpty
            ? Material(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberDirectory(
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
                      fontWeight: FontWeight.w300,
                      fontSize: w * 0.04,
                      letterSpacing: 0.5,
                    ),
                  ),
                  subtitle: Text(
                    '${widget.members.length}',
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.06, // Hit area
                    height:
                        MediaQuery.of(context).size.height * 0.048, // Hit area
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
              )
            : null,
        if (widget.members.isNotEmpty) ...[
          Container(
            height: h * 0.008,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorScheme.of(context).onSurface.withOpacity(0.08),
            ),
          ),
          SizedBox(height: h * 0.02),
        ],
        // Show all groups except group 1 and group 2.
        ...widget.leaders.skip(2).map((group) {
          if (group.leaders.isEmpty) {
            return const SizedBox.shrink();
          }

          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(

              onTap: () {
                final groupPoliticianIds = group.leaders
                    .map((leader) => leader.politicianId)
                    .toSet();

                final groupMembers = widget.members
                    .where((member) => groupPoliticianIds.contains(member.politicianId))
                    .toList();


                final groupMembersByRegion = <String, List<MemberDirectoryModel>>{};

                for (final member in groupMembers) {
                  groupMembersByRegion
                      .putIfAbsent(member.region, () => [])
                      .add(member);
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberDirectory(
                      leaders: [group],
                      members: groupMembers,
                      membersByRegion: groupMembersByRegion,
                      title: group.title,
                    ),
                  ),
                );
              },

              leading: buildMembersPreview(
                widget.members
                    .where(
                      (member) => group.leaders.any(
                        (leader) => leader.politicianId == member.politicianId,
                  ),
                )
                    .toList(),
                context,
              ),
              title: Text(
                group.title, // Replace with your actual group-name field.
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: w * 0.04,
                  letterSpacing: 0.5,
                ),
              ),
              subtitle: Text(
                '${group.leaders.length}',
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
          );

        }),
      ],
    );
  }
}


Widget buildMembersPreview(
  List<MemberDirectoryModel> members,
  BuildContext context,
) {
  final previewMembers = members.take(3).toList();

  return SizedBox(
    width: 90,
    height: 46,
    child: Stack(
      children: List.generate(previewMembers.length, (index) {
        return Positioned(
          left: index * 22,
          child: Container(
            width: 50,
            height: MediaQuery.of(context).size.height * 0.065,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: buildImageWidget(
                previewMembers[index].imagePath,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }),
    ),
  );
}
