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
    final bool isIndia = country.name.toLowerCase().contains('india') ||
        country.name.isEmpty ||
        country.registrationCode == 'IND';
    final String countryName = country.name.isNotEmpty ? country.name : (isIndia ? 'India' : '');
    final String descriptionText = country.info?.trim().isNotEmpty == true
        ? country.info!.trim()
        : (isIndia
            ? 'officially the Republic of India, is a country in South Asia. It is the seventh-largest country by area; the most populous country since 2023; and, since its independence in 1947, the world\'s most populous democracy.'
            : '');

    // Setup leadership lists with robust backend lookup & rich fallbacks
    final List<NationalLeader> presidents = country.leaders
        .where((l) => (l.title + " " + l.badge).toUpperCase().contains('PRESIDENT'))
        .toList();
    if (presidents.isEmpty) {
      final String presName = country.president?.trim().isNotEmpty == true
          ? country.president!.trim()
          : (isIndia ? 'Droupadi Murmu' : 'President');
      presidents.addAll([
        NationalLeader(
          title: isIndia ? 'PRESIDENTS OF INDIA' : 'PRESIDENT',
          name: presName,
          tenure: '2022 - Present',
          badge: 'Current President',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Droupadi_Murmu_official_portrait_%28cropped%29.jpg/800px-Droupadi_Murmu_official_portrait_%28cropped%29.jpg',
        ),
        if (isIndia) ...const [
          NationalLeader(
            title: 'PRESIDENTS OF INDIA',
            name: 'Ram Nath Kovind',
            tenure: '2017 - 2022',
            badge: 'Former President',
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Ram_Nath_Kovind_official_portrait.jpg/800px-Ram_Nath_Kovind_official_portrait.jpg',
          ),
          NationalLeader(
            title: 'PRESIDENTS OF INDIA',
            name: 'Pranab Mukherjee',
            tenure: '2012 - 2017',
            badge: 'Former President',
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Pranab_Mukherjee_in_2012.jpg/800px-Pranab_Mukherjee_in_2012.jpg',
          ),
        ],
      ]);
    }

    final List<NationalLeader> primeMinisters = country.leaders
        .where((l) =>
            (l.title + " " + l.badge).toUpperCase().contains('PRIME') ||
            (l.title + " " + l.badge).toUpperCase().contains('PM'))
        .toList();
    if (primeMinisters.isEmpty) {
      final String pmName = country.primeMinister?.trim().isNotEmpty == true
          ? country.primeMinister!.trim()
          : (isIndia ? 'Shri Narendra Modi' : 'Prime Minister');
      primeMinisters.addAll([
        NationalLeader(
          title: 'PRIME MINISTER',
          name: pmName,
          tenure: '2014 - Present',
          badge: 'Current PM',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
          partyLogo:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Bharatiya_Janata_Party_logo.svg/800px-Bharatiya_Janata_Party_logo.svg.png',
        ),
        if (isIndia) ...const [
          NationalLeader(
            title: 'PRIME MINISTER',
            name: 'Dr. Manmohan Singh',
            tenure: '2004 - 2014',
            badge: 'Former PM',
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Manmohan_Singh_%28cropped%29.jpg/800px-Manmohan_Singh_%28cropped%29.jpg',
            partyLogo:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
          ),
        ],
      ]);
    }

    final List<NationalLeader> defenceMinisters = country.leaders
        .where((l) => (l.title + " " + l.badge).toUpperCase().contains('DEFEN'))
        .toList();
    if (defenceMinisters.isEmpty) {
      final String defName = country.defenceMinister?.trim().isNotEmpty == true
          ? country.defenceMinister!.trim()
          : (isIndia ? 'Shri Rajnath Singh' : 'Defence Minister');
      defenceMinisters.addAll([
        NationalLeader(
          title: 'DEFENCE MINISTER',
          name: defName,
          tenure: '2019 - Present',
          badge: 'Current DM',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Rajnath_Singh_in_2023.jpg/800px-Rajnath_Singh_in_2023.jpg',
          partyLogo:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Bharatiya_Janata_Party_logo.svg/800px-Bharatiya_Janata_Party_logo.svg.png',
        ),
        if (isIndia) ...const [
          NationalLeader(
            title: 'DEFENCE MINISTER',
            name: 'Shri A. K. Antony',
            tenure: '2006 - 2014',
            badge: 'Former DM',
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
            partyLogo:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Indian_National_Congress_hand_logo.svg/800px-Indian_National_Congress_hand_logo.svg.png',
          ),
        ],
      ]);
    }

    final List<NationalLeader> homeMinisters = country.leaders
        .where((l) => (l.title + " " + l.badge).toUpperCase().contains('HOME'))
        .toList();
    if (homeMinisters.isEmpty) {
      final String hmName = country.homeMinister?.trim().isNotEmpty == true
          ? country.homeMinister!.trim()
          : (isIndia ? 'Shri Amit Shah' : 'Home Minister');
      homeMinisters.addAll([
        NationalLeader(
          title: 'HOME MINISTER',
          name: hmName,
          tenure: '2019 - Present',
          badge: 'Current HM',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
          partyLogo:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Bharatiya_Janata_Party_logo.svg/800px-Bharatiya_Janata_Party_logo.svg.png',
        ),
        if (isIndia) ...const [
          NationalLeader(
            title: 'HOME MINISTER',
            name: 'Shri Rajnath Singh',
            tenure: '2014 - 2019',
            badge: 'Former HM',
            imageUrl:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Rajnath_Singh_in_2023.jpg/800px-Rajnath_Singh_in_2023.jpg',
            partyLogo:
                'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Bharatiya_Janata_Party_logo.svg/800px-Bharatiya_Janata_Party_logo.svg.png',
          ),
        ],
      ]);
    }

    final List<CabinetMinister> cabinets = country.otherCabinets.isNotEmpty
        ? country.otherCabinets
        : const [
            // Row 1
            CabinetMinister(
              firstName: 'H. D.',
              lastName: 'Revana',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
              backgroundColor: Color(0xFFFF5252),
            ),
            CabinetMinister(
              firstName: 'Amit',
              lastName: 'Shah',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
              backgroundColor: Color(0xFFFFB74D),
            ),
            CabinetMinister(
              firstName: 'Kunal',
              lastName: 'Tilak',
              imageUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
              backgroundColor: Color(0xFFCFD8DC),
            ),
            // Row 2
            CabinetMinister(
              firstName: 'Nitin',
              lastName: 'Gadkari',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
              backgroundColor: Color(0xFFFF5252),
            ),
            CabinetMinister(
              firstName: 'Nirmala',
              lastName: 'Sitharaman',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
              backgroundColor: Color(0xFFFFB74D),
            ),
            CabinetMinister(
              firstName: 'S.',
              lastName: 'Jaishankar',
              imageUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
              backgroundColor: Color(0xFFCFD8DC),
            ),
            // Row 3
            CabinetMinister(
              firstName: 'Piyush',
              lastName: 'Goyal',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Prime_Minister_Narendra_Modi_in_February_2023.jpg/800px-Prime_Minister_Narendra_Modi_in_February_2023.jpg',
              backgroundColor: Color(0xFFFF5252),
            ),
            CabinetMinister(
              firstName: 'Dharmendra',
              lastName: 'Pradhan',
              imageUrl:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Amit_Shah_in_2023.jpg/800px-Amit_Shah_in_2023.jpg',
              backgroundColor: Color(0xFFFFB74D),
            ),
            CabinetMinister(
              firstName: 'Ashwini',
              lastName: 'Vaishnaw',
              imageUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
              backgroundColor: Color(0xFFCFD8DC),
            ),
          ];

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
                      style: TextStyle(
                        fontSize: (screenWidth * (15.0 / 375.0)).clamp(14.0, 16.0),
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF333333),
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
                      : (isIndia ? 'New Delhi' : '-'),
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
                      : (isIndia ? 'Jana Gana Mana' : '-'),
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
                      : (isIndia ? '1.4B' : '-'),
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
                      : (isIndia ? 'Droupadi Murmu' : '-'),
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
                      : (isIndia ? 'Shri Narendra Modi' : '-'),
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
                      : (isIndia ? '15 August 1947' : '-'),
                ),
              ],
            ),
          ),
          if (presidents.isNotEmpty) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              context,
              title: isIndia ? 'PRESIDENTS OF INDIA' : 'PRESIDENT',
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
            style: TextStyle(
              fontSize: (screenWidth * (16.0 / 375.0)).clamp(15.0, 18.0),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: const Color(0xFF1E1E1E),
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: (screenWidth * (12.0 / 375.0)).clamp(11.0, 13.0),
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
                                style: TextStyle(
                                  fontSize: (screenWidth * (15.0 / 375.0)).clamp(14.0, 16.0),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                              if (leader.tenure.isNotEmpty) ...[
                                SizedBox(height: screenHeight * 0.003),
                                Text(
                                  leader.tenure,
                                  style: TextStyle(
                                    fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                                    fontWeight: FontWeight.w600,
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
                style: TextStyle(
                  fontSize: (screenWidth * (16.0 / 375.0)).clamp(15.0, 18.0),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFF1E1E1E),
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
                    style: TextStyle(
                      fontSize: (screenWidth * (14.0 / 375.0)).clamp(13.0, 15.0),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  Text(
                    minister.lastName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: (screenWidth * (13.0 / 375.0)).clamp(12.0, 14.0),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
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

