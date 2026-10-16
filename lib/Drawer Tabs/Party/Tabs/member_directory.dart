import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../../Reusable Functions/reusable_functions.dart';
import '../party_page_modal.dart';

class MemberDirectory extends StatefulWidget {
  final List<LeaderGroupModel> leaders;
  final List<MemberDirectoryModel> members;
  final Map<String, List<MemberDirectoryModel>> membersByRegion;
  final String title;
  const MemberDirectory({
    super.key,
    required this.leaders,
    required this.members,
    required this.membersByRegion,
    required this.title,
  });

  @override
  State<MemberDirectory> createState() => _MemberDirectoryState();
}

class _MemberDirectoryState extends State<MemberDirectory> {
  String _formatCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }
  final ValueNotifier<String> selectedRegion =
  ValueNotifier<String>('All');
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<String> _appliedSearch = ValueNotifier<String>('');
  @override
  void dispose() {
    selectedRegion.dispose();
    _searchController.dispose();
    _appliedSearch.dispose();
    super.dispose();
  }
  List<MemberDirectoryModel> _filterMembers(
      String region,
      String query,
      ) {
    final members = getDisplayedMembers(region);
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return members;

    return members.where((member) {
      return member.personName.toLowerCase().contains(search) ||
          member.region.toLowerCase().contains(search);
    }).toList(growable: false);
  }
  List<MemberDirectoryModel> getDisplayedMembers(String region) {
    if (region == 'All') return widget.members;
    return widget.membersByRegion[AutofillHints.addressCityAndState] ?? [];
  }

  List<String> get regions {
    return ["All", ...widget.membersByRegion.keys];
  }
  bool get isIndiaPresence =>
      widget.title.toUpperCase() == 'INDIA PRESENCE';

  List<LeaderModel> get topLeaders {
    if (!isIndiaPresence || widget.leaders.isEmpty) {
      return [];
    }

    return widget.leaders.first.leaders;
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
              title:widget.title,
              automaticallyImplyLeading: false,

              isMenuNeeded: false,
              height: h*0.07,
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SvgPicture.asset(
                        PartyPageData.crossIcon,
                        height: h * 0.023,
                      ),
                    ),
                  ),
                ),
              ],

            ),

            SliverToBoxAdapter(
              child: Container(
                height: h * 0.065,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient:
                  GradientColorsForBellowAppbar.gradientBelowAppbar,
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  height: h * 0.06,
                  child: ValueListenableBuilder<String>(
                    valueListenable: selectedRegion,
                    builder: (context, selected, _) {
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                        itemCount: regions.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: w * 0.025),
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          final isSelected = selected == region;

                          // Count members belonging to this region.
                          final count = region == 'All'
                              ? widget.members.length
                              : (widget.membersByRegion[region]?.length ?? 0);

                          return GestureDetector(
                            onTap: () {
                              if (selectedRegion.value == region) return;

                              selectedRegion.value = region;

                              // Clear the previous region's search.
                              _searchController.clear();
                              _appliedSearch.value = '';
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.045,
                                vertical: h * 0.008,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF000000).withOpacity(0.26),
                                borderRadius: BorderRadius.circular(w*0.14),
                              ),
                              child: Text(
                                '${region.toUpperCase()} - ${_formatCount(count)}',
                                maxLines: 1,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFFFE3A31)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: w * 0.04,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
///-----------------------------Search bar


            SliverToBoxAdapter(
              child: SizedBox(
                height: h * 0.12,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Gradient background behind the overlapping search bar.
                    Container(
                      height: h * 0.067,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient:
                        GradientColorsForBellowAppbar.gradientBelowAppbar,
                      ),
                    ),

                    // Search bar overlaps the bottom of the gradient.
                    Positioned(
                      top: h * 0.025,
                      left: w * 0.025,
                      right: w * 0.025,
                      child: Container(
                        height: h * 0.068,
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.035,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(w * 0.04),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              PartyPageData.searchPersonIcon,
                              width: w * 0.055,
                              height: w * 0.055,
                            ),
                            SizedBox(width: w * 0.025),

                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onChanged: (value) {
                                  _appliedSearch.value = value.trim();
                                },
                                style: TextStyle(
                                  fontSize: w * 0.038,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search for MP, MLA',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: w * 0.038,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            SizedBox(width: w * 0.02),

                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _appliedSearch.value =
                                    _searchController.text.trim();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: h * 0.012,
                                  horizontal: w * 0.01,
                                ),
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: w * 0.033,
                                    fontWeight: FontWeight.w600,
                                  ),
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
            ),

            ///---------------------------------------------------------------

            if (isIndiaPresence && topLeaders.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:  EdgeInsets.only(left: w*0.025,right: w*0.025),
                  child: Container(
                    height: w*0.4,
decoration: BoxDecoration(
    color: Colors.white,
  borderRadius: BorderRadius.circular(w*0.04)
),

                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.025,

                    ),
                    child: SizedBox(
                      height: h * 0.2,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: topLeaders.length,
                        separatorBuilder: (_, __) => SizedBox(width: w * 0.025),

                        itemBuilder: (context, index) {
                          final leader = topLeaders[index];

                          return SizedBox(
                            width: w * 0.2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Fixed circle position and size.
                                SizedBox(
                                  width: w * 0.2,
                                  height: w * 0.2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: leader.imagePath == null ||
                                          leader.imagePath!.isEmpty
                                          ? ColoredBox(
                                        color: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: w * 0.08,
                                        ),
                                      )
                                          : buildImageWidget(
                                        leader.imagePath!,
                                        width: w * 0.2,
                                        height: w * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: h * 0.008),

                                // Name stays below the circle.
                                SizedBox(
                                  width: w * 0.2,
                                  height: h * 0.04, // Space for up to 2 lines
                                  child: Text(
                                    leader.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: (w * 0.029).clamp(9.0, 11.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },

                      ),
                    ),
                  ),
                ),
              ),


            ValueListenableBuilder<String>(
              valueListenable: selectedRegion,
              builder: (context, region, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: _appliedSearch,
                  builder: (context, query, _) {
                    final members = _filterMembers(region, query);

                    if (members.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: w * 0.06,
                            vertical: h * 0.04,
                          ),
                          child: Center(
                            child: Text(
                              query.isNotEmpty
                                  ? 'No leaders found for "$query"'
                                  : 'No members found in ${region == 'All' ? 'this directory' : region}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: w * 0.038,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final member = members[index];

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.01,
                            ),
                            child: Card(
                              color: Colors.white,
                              elevation: 0,
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: w * 0.07,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child: SizedBox.expand(
                                      child: buildImageWidget(
                                        member.imagePath,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  member.personName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: w * 0.039,
                                    letterSpacing: 0.31,
                                    color: ColorScheme.of(context).onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  member.designation,
                                  style: TextStyle(
                                    color: ColorScheme.of(context)
                                        .onSurface
                                        .withOpacity(0.6),
                                    fontSize: w * 0.039,
                                    letterSpacing: 0.31,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: members.length,
                      ),
                    );
                  },
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
