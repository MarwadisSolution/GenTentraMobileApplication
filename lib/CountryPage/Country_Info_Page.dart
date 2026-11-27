import 'civic_portrait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Reusable Functions/reusable_functions.dart';
import 'Country_model.dart';
import 'Country_page_data.dart';
import 'reusable_functions.dart';

/// [INFO TAB PAGE] Renders civic information, key details, national leadership,
/// and cabinet ministers for the country.
class CountryInfoPage extends StatelessWidget {
  final CountryModel country;

  const CountryInfoPage({
    super.key,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {

    final bool isIndia = country.name.toLowerCase().contains('india') ||
        country.name.isEmpty ||
        country.registrationCode == 'IND';
    final String countryName = country.name.isNotEmpty ? country.name : (isIndia ? 'India' : '');
    final String descriptionText = country.info?.trim().isNotEmpty == true
        ? country.info!.trim()
        : (isIndia
            ? 'officially the Republic of India, is a country in South Asia. It is the seventh-largest country by area; the most populous country since 2023; and, since its independence in 1947, the world\'s most populous democracy.'
            : '');

    final offices = <String, List<NationalLeader>>{};
    final cabinets = [...country.otherCabinets];
    for (final leader in country.leaders) {
      final role = leader.title.toLowerCase();
      if (role.contains('cabinet') || role.contains('cabinate')) {
        cabinets.add(CabinetMinister.fromJson({
          'name': leader.name,
          'imageUrl': leader.imageUrl,
        }));
        continue;
      }
      offices.putIfAbsent(leader.title, () => []).add(leader);
    }
    // Profiles can also supply only the current holder's name.
    for (final entry in {
      'President': country.president,
      'Prime Minister': country.primeMinister,
      'Defence Minister': country.defenceMinister,
      'Home Minister': country.homeMinister,
    }.entries) {
      final name = entry.value?.trim();
      if (name == null || name.isEmpty) continue;
      if (country.leaders.any((leader) => leader.name.toLowerCase() == name.toLowerCase())) continue;
      offices.putIfAbsent(entry.key, () => []).add(
        NationalLeader(title: entry.key, name: name, tenure: '', badge: '', imageUrl: ''),
      );
    }


    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // ValueNotifier replaces setState for READ MORE / READ LESS toggle
    final expandedNotifier = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: expandedNotifier,
      builder: (context, isInfoExpanded, _) {
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
                    maxLines: isInfoExpanded ? null : 4,
                    overflow:
                        isInfoExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
          for (final office in offices.entries) ...[
            buildSectionDivider(context),
            _buildLeaderHorizontalSection(
              context,
              title: office.key.toUpperCase(),
              leaders: office.value,
              showPartyLogo: office.value.any((leader) => leader.partyLogo?.isNotEmpty == true),
            ),
          ],

          if (!offices.keys.any((title) => title.toLowerCase().contains('home'))) ...[
            buildSectionDivider(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HOME MINISTER', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('No Home Minister record available.'),
                ],
              ),
            ),
          ],
          buildSectionDivider(context),
          _buildOtherCabinetsSection(context, cabinets),
        ],
      ),
    );
      }, // end ValueListenableBuilder builder
    );   // end ValueListenableBuilder
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
          ?trailing,
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
                                ? CivicPortrait(
                                    leader.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox.shrink(),
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
                'OTHER CABINET MINISTERS',
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
          if (cabinets.isEmpty)
            const Text('No cabinet members available.')
          else
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
                            ? CivicPortrait(
                                minister.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox.shrink(),
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

