import 'civic_portrait.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';
import 'Country_page_data.dart';
import 'State_model.dart';
import 'reusable_functions.dart';

class StateInfoPage extends StatelessWidget {
  final StateModel state;

  const StateInfoPage({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerGap = screenWidth * (10.0 / 375.0);

    final String stateName = state.name.isNotEmpty ? state.name : '';
    final String descriptionText = state.info?.trim() ?? '';

    // 1. CM Leaders
    final List<NationalLeader> cmLeaders = state.leaders
        .where((l) =>
            ("${l.title} ${l.badge}").toUpperCase().contains('CM') ||
            RegExp(r'ch(?:ie|ei)f', caseSensitive: false).hasMatch(l.title))
        .toList();

    if (cmLeaders.isEmpty && state.chiefMinister?.trim().isNotEmpty == true) {
      cmLeaders.add(
        NationalLeader(
          title: 'CURRENT CM',
          name: state.chiefMinister!.trim(),
          tenure: state.lastElection != null && state.lastElection!.trim().isNotEmpty
              ? '${state.lastElection!.trim()} - Present'
              : 'Present',
          badge: 'Current CM',
          imageUrl: '',
          partyLogo: null,
        ),
      );
    }

    // 2. Deputy CM Leaders (only from API data, no hardcoded fallback)
    final List<NationalLeader> deputyCmLeaders = state.leaders
        .where((l) => ("${l.title} ${l.badge}").toUpperCase().contains('DEPTY') ||
            ("${l.title} ${l.badge}").toUpperCase().contains('DEPUTY'))
        .toList();

    cmLeaders.removeWhere(deputyCmLeaders.contains);
    final otherPosts = state.leaders.where(
      (leader) => !cmLeaders.contains(leader) && !deputyCmLeaders.contains(leader),
    );
    // 3. Current Ministers (only from API data, no hardcoded fallback)
    final String? defaultPartyLogo = cmLeaders.isNotEmpty
        ? cmLeaders.first.partyLogo
        : (deputyCmLeaders.isNotEmpty ? deputyCmLeaders.first.partyLogo : null);

    final List<NationalLeader> currentMinistersList = state.otherCabinets
        .map((m) => NationalLeader(
              title: 'CURRENT MINISTERS',
              name: '${m.firstName} ${m.lastName}'.trim(),
              tenure: 'Present',
              badge: 'Current Minister',
              imageUrl: m.imageUrl,
              partyLogo: defaultPartyLogo,
            ))
        .toList();

    currentMinistersList.addAll(otherPosts);

    // ValueNotifier replaces setState for READ MORE / READ LESS toggle
    final expandedNotifier = ValueNotifier<bool>(false);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
      child: ValueListenableBuilder<bool>(
        valueListenable: expandedNotifier,
        builder: (context, isInfoExpanded, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // 1. Description Text with Read More toggle
          if (descriptionText.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: isInfoExpanded ? null : 4,
                    overflow: isInfoExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: (screenWidth * (15.0 / 375.0)).clamp(14.0, 16.0),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF333333),
                        height: 1.5,
                      ),
                      children: [
                        if (stateName.isNotEmpty)
                          TextSpan(
                            text: '$stateName ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        TextSpan(
                          text: (stateName.isNotEmpty && descriptionText.startsWith(stateName))
                              ? descriptionText.substring(stateName.length).trimLeft()
                              : descriptionText,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  GestureDetector(
                    onTap: () {
                      expandedNotifier.value = !expandedNotifier.value;
                    },
                    child: Text(
                      isInfoExpanded ? 'READ LESS' : 'READ MORE',
                      style: TextStyle(
                        fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFE3A31),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ],

          // 2. State Attribute Rows
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.spokenLanguage?.trim().isNotEmpty == true)
                  _buildStateDetailRow(
                    context,
                    icon: Icon(
                      Icons.translate_rounded,
                      color: const Color(0xFF888888),
                      size: screenWidth * (22.0 / 375.0),
                    ),
                    label: 'SPOKEN LANGUAGE',
                    value: state.spokenLanguage!.trim(),
                  ),
                if (state.governor?.trim().isNotEmpty == true)
                  _buildStateDetailRow(
                    context,
                    icon: Icon(
                      Icons.person_outline_rounded,
                      color: const Color(0xFF888888),
                      size: screenWidth * (24.0 / 375.0),
                    ),
                    label: 'GOVERNOR',
                    value: state.governor!.trim(),
                  ),
                if (state.rulingParty?.trim().isNotEmpty == true)
                  _buildStateDetailRow(
                    context,
                    icon: Icon(
                      Icons.outlined_flag_rounded,
                      color: const Color(0xFF888888),
                      size: screenWidth * (24.0 / 375.0),
                    ),
                    label: 'CURRENT GOVERNMENT',
                    value: state.rulingParty!.trim(),
                  ),
                if (state.electoralFootprint?.trim().isNotEmpty == true)
                  _buildStateDetailRow(
                    context,
                    icon: Icon(
                      Icons.account_balance_outlined,
                      color: const Color(0xFF888888),
                      size: screenWidth * (22.0 / 375.0),
                    ),
                    label: 'ELECTORAL FOOTPRINT',
                    value: state.electoralFootprint!.trim(),
                  ),
                if (state.lastElection?.trim().isNotEmpty == true)
                  _buildStateDetailRow(
                    context,
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: const Color(0xFF888888),
                      size: screenWidth * (20.0 / 375.0),
                    ),
                    label: 'LAST ELECTION',
                    value: state.lastElection!.trim(),
                  ),
                if (state.nextElection?.trim().isNotEmpty == true)
                  _buildStateDetailRow(
                    context,
                    icon: Icon(
                      Icons.calendar_month_outlined,
                      color: const Color(0xFF888888),
                      size: screenWidth * (20.0 / 375.0),
                    ),
                    label: 'NEXT ELECTION',
                    value: state.nextElection!.trim(),
                  ),
              ],
            ),
          ),

          // 3. CURRENT CM SECTION
          if (cmLeaders.isNotEmpty) ...[
            buildSectionDivider(context, bottomMargin: headerGap),
            _buildLeaderHorizontalSection(
              context,
              title: 'CURRENT CM',
              leaders: cmLeaders,
              showPartyLogo: true,
            ),
          ],

          // 4. DEPUTY CM SECTION
          if (deputyCmLeaders.isNotEmpty) ...[
            buildSectionDivider(context, bottomMargin: headerGap),
            _buildLeaderHorizontalSection(
              context,
              title: 'DEPTY CHIEF MINISTER',
              leaders: deputyCmLeaders,
              showPartyLogo: true,
            ),
          ],

          // 5. CURRENT MINISTERS (Exact same size box as Chief Minister & Deputy Chief Minister)
          if (currentMinistersList.isNotEmpty) ...[
            buildSectionDivider(context, bottomMargin: headerGap),
            _buildLeaderHorizontalSection(
              context,
              title: 'CURRENT MINISTERS',
              leaders: currentMinistersList,
              showPartyLogo: true,
              trailingHeaderWidget: SvgPicture.asset(
                CountryPageData.arrow,
                width: screenWidth * 0.055,
                height: screenWidth * 0.055,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFE3A31),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ],
      );
        },
      ),
    );
  }

  Widget _buildStateDetailRow(
    BuildContext context, {
    required Widget icon,
    required String label,
    required String value,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.075,
            height: screenWidth * 0.075,
            child: Center(child: icon),
          ),
          SizedBox(width: screenWidth * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.21,
                    color: const Color(0xFF666666),
                  ),
                ),
                SizedBox(height: screenHeight * 0.003),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.045).clamp(14.0, 16.0),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.31,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderHorizontalSection(
    BuildContext context, {
    required String title,
    required List<NationalLeader> leaders,
    bool showPartyLogo = true,
    Widget? trailingHeaderWidget,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * (280.0 / 375.0);
    final double cardImageHeight = cardWidth * (339.0 / 280.0);
    final double listHeight = cardWidth * (396.0 / 280.0);
    final double cardRadius = cardWidth * (20.0 / 280.0);
    final double cardMarginRight = screenWidth * (16.0 / 375.0);
    final double spacingBelowImage = cardWidth * (10.0 / 280.0);
    final double partyLogoSize = cardWidth * (28.0 / 280.0);
    final double badgeBottom = cardImageHeight * (12.0 / 339.0);
    final double badgeRight = cardWidth * (12.0 / 280.0);
    final double badgeHorizontalPadding = cardWidth * (12.0 / 280.0);
    final double badgeVerticalPadding = cardImageHeight * (5.0 / 339.0);
    final double badgeRadius = cardWidth * (14.0 / 280.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: (screenWidth * (16.0 / 375.0)).clamp(15.0, 18.0),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.38,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              ?trailingHeaderWidget,
            ],
          ),
        ),
        SizedBox(height: screenWidth * (10.0 / 375.0)),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final leader = leaders[index];
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: index == leaders.length - 1 ? 0 : cardMarginRight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(cardRadius),
                          child: leader.imageUrl.isEmpty
                              ? SizedBox(width: cardWidth, height: cardImageHeight)
                              : CivicPortrait(
                                  leader.imageUrl,
                                  width: cardWidth,
                                  height: cardImageHeight,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        if (leader.badge.isNotEmpty)
                          Positioned(
                            bottom: badgeBottom,
                            right: badgeRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: badgeHorizontalPadding,
                                vertical: badgeVerticalPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(badgeRadius),
                              ),
                              child: Text(
                                leader.badge,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: (cardWidth * (11.0 / 280.0)).clamp(10.0, 13.0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: spacingBelowImage),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showPartyLogo && leader.partyLogo != null && leader.partyLogo!.isNotEmpty) ...[
                          ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: leader.partyLogo!,
                              width: partyLogoSize,
                              height: partyLogoSize,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: const Color(0xFFE0E0E0),
                              ),
                              errorWidget: (_, _, _) => Icon(
                                Icons.flag,
                                size: partyLogoSize * 0.6,
                                color: const Color(0xFFFE3A31),
                              ),
                            ),
                          ),
                          SizedBox(width: cardWidth * (8.0 / 280.0)),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leader.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: (cardWidth * (15.0 / 280.0)).clamp(13.0, 16.0),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                              if (leader.tenure.isNotEmpty) ...[
                                SizedBox(height: cardWidth * (2.0 / 280.0)),
                                Text(
                                  leader.tenure,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: (cardWidth * (12.0 / 280.0)).clamp(11.0, 13.0),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
