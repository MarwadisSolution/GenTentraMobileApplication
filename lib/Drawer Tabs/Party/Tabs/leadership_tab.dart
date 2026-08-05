import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/member_directory.dart';
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
    // print(firstGroupLeaders.imagePath);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView(
        padding: EdgeInsets.all(w * 0.05),
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(w * 0.012),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 0,
              childAspectRatio: w < 600 ? 0.7 : 0.8,
            ),
            itemCount: firstGroupLeaders.leaders.length,
            itemBuilder: (context, index) {
              final leader = firstGroupLeaders.leaders[index];
              return widget.leaders.length == 0
                  ? Center(
                child: Text(
                  "No Groups Present",
                  style: TextStyle(color: Colors.black),
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //SizedBox(height: 20,),
                  SizedBox(
                    height: isDesktop
                        ? h * 0.60   // 50% of screen height
                        : isTablet
                        ? h * 0.52   // 45% of screen height
                        : h * 0.45,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: buildImageWidget(
                        leader.imagePath!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
SizedBox(height:h*0.02),
                  Text(
                    leader.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: MediaQuery.textScalerOf(
                        context,
                      ).scale(16),
                      letterSpacing: 0.35,
                      color: Color(0xFF0E0E0E),
                    ),
                  ),
                  SizedBox(height:h*0.006),
                  Text(
                    leader.designation,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: MediaQuery.textScalerOf(
                        context,
                      ).scale(14),
                      letterSpacing: 0.29,
                      color: ColorScheme
                          .of(context)
                          .onSurface,
                    ),
                  ),
                ],
              );
            },
          ),

          ///------Different Groups-----
          ...List.generate(widget.leaders.length - 1, (groupIndex) {
            final group = widget.leaders[groupIndex + 1];
            if (group.leaders.isEmpty) {
              return SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: h * 0.01),
              child: SizedBox(
                height: h * 0.24,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,

                  separatorBuilder: (_, _) => SizedBox(width: w * 0.025),
                  itemCount: group.leaders.length,
                  itemBuilder: (context, leaderIndex) {
                    final leader = group.leaders[leaderIndex];
                    return SizedBox(
                      width: w * 0.28,
                      height: h * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: h * 0.16,
                            width: w * 0.28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
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
      ),
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