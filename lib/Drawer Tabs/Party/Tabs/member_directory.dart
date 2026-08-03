import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../../Reusable Functions/reusable_functions.dart';
import '../party_page_modal.dart';

class MemberDirectory extends StatefulWidget {
  final List<LeaderGroupModel> leaders;
  final List<MemberDirectoryModel> members;
  final Map<String, List<MemberDirectoryModel>> membersByRegion;

  const MemberDirectory({
    super.key,
    required this.leaders,
    required this.members,
    required this.membersByRegion,
  });

  @override
  State<MemberDirectory> createState() => _MemberDirectoryState();
}

class _MemberDirectoryState extends State<MemberDirectory> {
  String selectedRegion = 'All';

  List<MemberDirectoryModel> get displayedMembers {
    if (selectedRegion == "All") return widget.members;
    return widget.membersByRegion[selectedRegion] ?? [];
  }

  List<String> get regions {
    return ["All", ...widget.membersByRegion.keys];
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.08),
          //gradient: GradientColorsForBellowAppbar.gradientBelowAppbar,
         ),
        child: CustomScrollView(
          slivers: [
            ReusableSliverAppBar(
              title: "Youth Wing",
              automaticallyImplyLeading: true,
              height: h*0.06,
            ),

            SliverToBoxAdapter(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Gradient Banner
                  Container(
                    height: h * 0.08,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: GradientColorsForBellowAppbar.gradientBelowAppbar,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                    child:    SingleChildScrollView(
                              scrollDirection: Axis.horizontal,

                              child: Row(
                                children: regions.map((region) {
                                  final selected = selectedRegion == region;
                                  return Padding(
                                    padding:  EdgeInsets.only(
                                      //right: 10,
                                      left: w*0.06,
                                      top: h*0.02,
                                      bottom: h*0.02,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedRegion = region;
                                        });
                                      },
                                      child: Text(
                                        region.toUpperCase(),
                                        style: TextStyle(
                                          color: selected
                                              ? Color(0xFF000000)
                                              : Color(0xFF666666),
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.w300,
                                          fontSize: MediaQuery.textScalerOf(
                                            context,
                                          ).scale(14),
                                          letterSpacing: 0.26,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                  ),
                ],
              ),
            ),

                      SliverList(
                          delegate: SliverChildBuilderDelegate(
                          (context, index){
                            final member=displayedMembers[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: w*0.01,
                                left: w*0.01,),
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: ListTile(
                                            leading:   CircleAvatar(
                                                radius: MediaQuery.of(context).size.width*0.07,
                                              backgroundColor: Colors.white,
                                                child: ClipOval(
                                                  child: SizedBox.expand(
                                                    child: buildImageWidget(
                                                      member.imagePath,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                member.personName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: MediaQuery.textScalerOf(
                                                    context,
                                                  ).scale(14),
                                                  letterSpacing: 0.31,
                                                  color: ColorScheme.of(context).onSurface,
                                                ),
                                              ),
                                              subtitle: Text(
                                                "${member.region}",
                                                style: TextStyle(
                                                  color: ColorScheme.of(
                                                    context,
                                                  ).onSurface.withOpacity(0.6),
                                                  fontSize: MediaQuery.textScalerOf(
                                                    context,
                                                  ).scale(14),
                                                  letterSpacing: 0.31,
                                                ),
                                              ),
                                ),
                              ),
                            );
                          },
                            childCount: displayedMembers.length,
                      )
                      )
                      //  Container(
                      //   height: h,
                      //   width: w,
                      //   decoration: BoxDecoration(
                      //     color: Colors.black.withOpacity(0.08),
                      //   ),
                      //   child: ListView.builder(
                      //    // shrinkWrap: true,
                      //     physics: const NeverScrollableScrollPhysics(),
                      //     itemCount: displayedMembers.length,
                      //     itemBuilder: (context, index) {
                      //       final member = displayedMembers[index];
                      //       return Padding(
                      //         padding: EdgeInsets.only(
                      //             //top: h*0.01,
                      //             left: w*0.02,
                      //             right: w*0.02
                      //         ),
                      //         child: Card(
                      //           elevation: 0,
                      //           child: ListTile(
                      //           leading:   CircleAvatar(
                      //               radius: MediaQuery.of(context).size.width*0.07,
                      //             backgroundColor: Colors.white,
                      //               child: ClipOval(
                      //                 child: SizedBox.expand(
                      //                   child: buildImageWidget(
                      //                     member.imagePath,
                      //                     width: double.infinity,
                      //                     height: double.infinity,
                      //                     fit: BoxFit.cover,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             title: Text(
                      //               member.personName,
                      //               style: TextStyle(
                      //                 fontWeight: FontWeight.w700,
                      //                 fontSize: MediaQuery.textScalerOf(
                      //                   context,
                      //                 ).scale(14),
                      //                 letterSpacing: 0.31,
                      //                 color: ColorScheme.of(context).onSurface,
                      //               ),
                      //             ),
                      //             subtitle: Text(
                      //               "${member.region}",
                      //               style: TextStyle(
                      //                 color: ColorScheme.of(
                      //                   context,
                      //                 ).onSurface.withOpacity(0.6),
                      //                 fontSize: MediaQuery.textScalerOf(
                      //                   context,
                      //                 ).scale(14),
                      //                 letterSpacing: 0.31,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   ),
            //           // ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
