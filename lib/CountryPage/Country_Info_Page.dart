import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';
import 'Country_page_data.dart';
import 'reusable_functions.dart';

/// [INFO TAB PAGE] Renders civic information, key details, national leadership,
/// and cabinet ministers for the country.
class CountryInfoPage extends StatefulWidget {
  final CountryModel country;

  const CountryInfoPage({
    super.key,
    required this.country,
  });

  @override
  State<CountryInfoPage> createState() => _CountryInfoPageState();
}

class _CountryInfoPageState extends State<CountryInfoPage> {
  bool _isInfoExpanded = false;

  @override
  Widget build(BuildContext context) {
    final country = widget.country;
    final String countryName = country.name;
    final String descriptionText = country.info?.trim() ?? '';

    final List<NationalLeader> presidents = country.leaders
        .where((l) => (l.title + " " + l.badge).toUpperCase().contains('PRESIDENT'))
        .toList();
    if (presidents.isEmpty && country.president?.trim().isNotEmpty == true) {
      presidents.add(NationalLeader(
        title: 'PRESIDENT',
        name: country.president!.trim(),
        tenure: '',
        badge: 'President',
        imageUrl: '',
      ));
    }

    final List<NationalLeader> primeMinisters = country.leaders
        .where((l) =>
            (l.title + " " + l.badge).toUpperCase().contains('PRIME') ||
            (l.title + " " + l.badge).toUpperCase().contains('PM'))
        .toList();
    if (primeMinisters.isEmpty && country.primeMinister?.trim().isNotEmpty == true) {
      primeMinisters.add(NationalLeader(
        title: 'PRIME MINISTER',
        name: country.primeMinister!.trim(),
        tenure: '',
        badge: 'Prime Minister',
        imageUrl: '',
      ));
    }

    final List<NationalLeader> defenceMinisters = country.leaders
        .where((l) => (l.title + " " + l.badge).toUpperCase().contains('DEFEN'))
        .toList();
    if (defenceMinisters.isEmpty && country.defenceMinister?.trim().isNotEmpty == true) {
      defenceMinisters.add(NationalLeader(
        title: 'DEFENCE MINISTER',
        name: country.defenceMinister!.trim(),
        tenure: '',
        badge: 'Defence Minister',
        imageUrl: '',
      ));
    }

    final List<NationalLeader> homeMinisters = country.leaders
        .where((l) => (l.title + " " + l.badge).toUpperCase().contains('HOME'))
        .toList();
    if (homeMinisters.isEmpty && country.homeMinister?.trim().isNotEmpty == true) {
      homeMinisters.add(NationalLeader(
        title: 'HOME MINISTER',
        name: country.homeMinister!.trim(),
        tenure: '',
        badge: 'Home Minister',
        imageUrl: '',
      ));
    }

    final List<CabinetMinister> cabinets = country.otherCabinets;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.016,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (descriptionText.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: _isInfoExpanded ? null : 4,
                    overflow:
                        _isInfoExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF333333),
                        height: 1.5,
                      ),
                      children: [
                        if (countryName.isNotEmpty)
                          TextSpan(
                            text: '$countryName, ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        TextSpan(
                          text: (countryName.isNotEmpty && descriptionText.startsWith(countryName))
                              ? descriptionText.substring(countryName.length).trimLeft()
                              : descriptionText,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isInfoExpanded = !_isInfoExpanded);
                    },
                    child: Text(
                      _isInfoExpanded ? 'READ LESS' : 'READ MORE',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFE3A31),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCivicDetailRow(
                  context,
                  icon: SvgPicture.asset(
                    CountryPageData.capitalIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.capital,
                  value: country.capital?.trim().isNotEmpty == true
                      ? country.capital!.trim()
                      : '-',
                ),
                _buildCivicDetailRow(
                  context,
                  icon: SvgPicture.asset(
                    CountryPageData.nationalAnthemIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.nationalAnthem,
                  value: country.nationalAnthem?.trim().isNotEmpty == true
                      ? country.nationalAnthem!.trim()
                      : '-',
                ),
                _buildCivicDetailRow(
                  context,
                  icon: SvgPicture.asset(
                    CountryPageData.populationIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.population,
                  value: country.population?.trim().isNotEmpty == true
                      ? country.population!.trim()
                      : '-',
                ),
                _buildCivicDetailRow(
                  context,
                  icon: SvgPicture.asset(
                    CountryPageData.presidentIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.president,
                  value: country.president?.trim().isNotEmpty == true
                      ? country.president!.trim()
                      : '-',
                ),
                _buildCivicDetailRow(
                  context,
                  icon: SvgPicture.asset(
                    CountryPageData.primeMinisterIcon,
                    width: screenWidth * 0.058,
                    height: screenWidth * 0.058,
                  ),
                  label: CountryPageData.primeMinister,
                  value: country.primeMinister?.trim().isNotEmpty == true
                      ? country.primeMinister!.trim()
                      : '-',
                ),
                _buildCivicDetailRow(
                  context,
                  icon: SvgPicture.asset(
                    CountryPageData.dateOfIndependenceIcon,
                    width: screenWidth * 0.055,
                    height: screenWidth * 0.055,
                  ),
                  label: CountryPageData.dateOfIndependence,
                  value: country.independenceDay?.trim().isNotEmpty == true &&
                          formatCountryDate(country.independenceDay) != '-'
                      ? formatCountryDate(country.independenceDay)
                      : '-',
                ),
              ],
            ),
          ),
          if (presidents.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              context,
              title: 'PRESIDENT',
              leaders: presidents,
              showPartyLogo: false,
            ),
          ],

          if (primeMinisters.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              context,
              title: 'PRIME MINISTER',
              leaders: primeMinisters,
              showPartyLogo: true,
            ),
          ],

          if (defenceMinisters.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              context,
              title: 'DEFENCE MINISTER',
              leaders: defenceMinisters,
              showPartyLogo: true,
            ),
          ],

          if (homeMinisters.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              context,
              title: 'HOME MINISTER',
              leaders: homeMinisters,
              showPartyLogo: true,
            ),
          ],

          if (cabinets.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildOtherCabinetsSection(context, cabinets),
          ],

          buildSectionDivider(context),
        ],
      ),
    );
  }
  Widget _buildCivicDetailRow(
    BuildContext context, {
    required Widget icon,
    required String label,
    required String value,
    Widget? trailing,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.21,
                    color: Color(0xFF666666),
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }
  Widget _buildLeaderHorizontalSection(
    BuildContext context, {
    required String title,
    required List<NationalLeader> leaders,
    bool showPartyLogo = true,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.016),
        SizedBox(
          height: listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final leader = leaders[index];
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: cardMarginRight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Image with rounded corners and translucent pill badge
                    Container(
                      height: cardImageHeight,
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(cardRadius),
                            child: leader.imageUrl.isNotEmpty
                                ? buildImageWidget(
                                    leader.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: const Color(0xFFF5F5F5),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "Assets/PartyPage/personIcon.svg",
                                        width: cardWidth * 0.25,
                                        height: cardWidth * 0.25,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFBDBDBD),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacingBelowImage),
                    // Below image: Party Logo (if applicable) and Name + Tenure
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showPartyLogo &&
                            leader.partyLogo != null &&
                            leader.partyLogo!.isNotEmpty) ...[
                          ClipOval(
                            child: Container(
                              width: partyLogoSize,
                              height: partyLogoSize,
                              color: Colors.white,
                              child: buildImageWidget(
                                leader.partyLogo!,
                                fit: BoxFit.cover,
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
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              if (leader.tenure.isNotEmpty) ...[
                                SizedBox(height: screenHeight * 0.003),
                                Text(
                                  leader.tenure,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4CAF50),
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
  Widget _buildOtherCabinetsSection(
    BuildContext context,
    List<CabinetMinister> cabinets,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OTHER CABINATE',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              SvgPicture.asset(
                CountryPageData.arrow,
                width: screenWidth * 0.046,
                height: screenWidth * 0.046,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFE3A31),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.003),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: screenWidth * 0.026,
              mainAxisSpacing: screenHeight * 0.016,
              childAspectRatio: 0.68,
            ),
            itemCount: cabinets.length,
            itemBuilder: (context, index) {
              final minister = cabinets[index];
              final double ministerRadius = screenWidth * 0.04;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: minister.backgroundColor,
                        borderRadius: BorderRadius.circular(ministerRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ministerRadius),
                        child: minister.imageUrl.isNotEmpty
                            ? buildImageWidget(
                                minister.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFF5F5F5),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "Assets/PartyPage/personIcon.svg",
                                    width: screenWidth * 0.1,
                                    height: screenWidth * 0.1,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFBDBDBD),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.007),
                  Text(
                    minister.firstName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  Text(
                    minister.lastName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

