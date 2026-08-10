import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/member_directory.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

class LeadershipTab extends StatefulWidget {
  final List<LeaderGroupModel> leaders;
  final List<MemberDirectoryModel> members;
  final Map<String, List<MemberDirectoryModel>> membersByRegion;
  const LeadershipTab({super.key, required this.leaders,   required this.members,
    required this.membersByRegion,});

  @override
  State<LeadershipTab> createState() => _LeadershipTabState();
}

class _LeadershipTabState extends State<LeadershipTab> {
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
    print("H- $h ---- W- $w");
    final isMobile = w < 600;
    final isTablet = w >= 600 && w < 900;
    final isDesktop = w >= 900;

    final gridCount = isDesktop
        ? 3
        : isTablet
        ? 2
        : 1;

    final imageWidth = isDesktop
        ? 220.0
        : isTablet
        ? 180.0
        : w * 0.45;
    if (widget.leaders.isEmpty) {
      return const Center(
        child: Text("No Groups Present",
            style: TextStyle(color: Colors.black)
        ),
      );
    }
    // final firstGroup=widget.leaders[0];
    final firstGroupLeaders = widget.leaders.first;
    final firstVisibleCount =
    firstGroupLeaders.leaders.length > 3
        ? 3
        : firstGroupLeaders.leaders.length;
    // print(firstGroupLeaders.imagePath);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
        children: [
          SizedBox(
            height: h * 0.62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: w * 0.012),
              separatorBuilder: (_, __) => SizedBox(width: w * 0.025),
              itemCount: firstVisibleCount,
              itemBuilder: (context, index) {
                final leader = firstGroupLeaders.leaders[index];
                final isViewMore =
                    firstGroupLeaders.leaders.length > 4 && index == 3;
                return SizedBox(
                  width: w * 0.8, // adjust as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: isViewMore
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberDirectory(
                                leaders: [firstGroupLeaders],
                                members: widget.members,
                                membersByRegion: widget.membersByRegion,
                              ),
                            ),
                          );
                        }
                            : null,
                        child: Stack(
                          children: [
                            Container(
                              height: h * 0.42,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: buildImageWidget(
                                  leader.imagePath!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            if (isViewMore)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),

                            if (isViewMore)
                              Positioned.fill(
                                child: Center(
                                  child: SvgPicture.asset(PartyPageData.arrow, height: h*0.02,),

                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.012),

                      Center(
                        child: Text(
                          leader.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: MediaQuery.textScalerOf(context).scale(16),
                            letterSpacing: 0.35,
                            color: const Color(0xFF0E0E0E),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.003),

                      Center(
                        child: Text(
                          leader.designation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.textScalerOf(context).scale(14),
                            letterSpacing: 0.29,
                            color: ColorScheme.of(context).onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          ///------Different Groups-----
          ...List.generate(widget.leaders.length - 1, (groupIndex) {
            final group = widget.leaders[groupIndex + 1];
            if (group.leaders.isEmpty) {
              return SizedBox.shrink();
            }
            final visibleCount=group.leaders.length>3?3:group.leaders.length;
            return Padding(
              padding: EdgeInsets.only(top: h * 0.01),
              child: SizedBox(
                height: h * 0.24,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,

                  separatorBuilder: (_, _) => SizedBox(width: w * 0.025),
                  itemCount: visibleCount,
                  itemBuilder: (context, leaderIndex) {
                    final leader = group.leaders[leaderIndex];
                    final isViewMore =
                        group.leaders.length > 3 && leaderIndex == 2;
                    return SizedBox(
                      width: w * 0.28,
                      height: h * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: isViewMore
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MemberDirectory(
                                    leaders: [group], // Only this group
                                    members: widget.members,
                                    membersByRegion: widget.membersByRegion,
                                  ),
                                ),
                              );
                            }
                                : null,
                            child: Stack(
                              children: [
                                Container(
                                  height: h * 0.16,
                                  width: w * 0.28,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: buildImageWidget(
                                      leader.imagePath!,
                                      height: h * 0.16,
                                      width: w * 0.28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isViewMore)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                if (isViewMore)
                                  Positioned.fill(
                                    child: Center(
                                      child: SvgPicture.asset(PartyPageData.arrow, height: h*0.02,),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.008),
                          Text(
                            leader.name,
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ColorScheme
                                  .of(context)
                                  .onSurface,
                              fontSize: MediaQuery.textScalerOf(
                                context,
                              ).scale(14),
                              letterSpacing: 0.22,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }),
          Container(
            height: h * 0.008,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorScheme
                  .of(context)
                  .onSurface
                  .withOpacity(0.08),
            ),
          ),
          SizedBox(height: h * 0.02),
          ?widget.members.isNotEmpty? Material(
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
                    ),
                  ),
                );
              },
              leading: buildMembersPreview(widget.members),
              title: Text(
                "Members",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: MediaQuery.textScalerOf(context).scale(16),
                ),
              ),
              trailing: SizedBox(
                width: MediaQuery.of(context).size.width*0.06,   // Hit area
                height: MediaQuery.of(context).size.height*0.048,  // Hit area
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
          ):null,
          SizedBox(height: h * 0.05),
        ],
      )
      )
    );
  }
}


Widget buildMembersPreview(List<MemberDirectoryModel> members) {
  final previewMembers = members.take(3).toList();

  return SizedBox(
    width: 90,
    height: 46,
    child: Stack(
      children: List.generate(previewMembers.length, (index) {
        return Positioned(
          left: index * 22,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
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