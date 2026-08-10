import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';

import '../../../Reusable Functions/reusable_functions.dart';
import 'info_tab.dart';

class SymbolTab extends StatefulWidget {
  final SymbolModel symbol;

  const SymbolTab({super.key, required this.symbol});

  @override
  State<SymbolTab> createState() => _SymbolTabState();
}

class _SymbolTabState extends State<SymbolTab> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isMobile = w < 600;
    final isTablet = w >= 600 && w < 900;
    final isDesktop = w >= 900;

    final gridCount = isDesktop
        ? 3
        : isTablet
        ? 2
        : 1;
    final size=MediaQuery.of(context).size.width;
    final String label = widget.symbol.logoDescription ?? "";
    return Padding(
      padding:  EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.05),
     child: Column(
      children: [

        ExpandableQuillContent(
          content: label
        ),
        GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            //padding:  EdgeInsets.all(MediaQuery.sizeOf(context).width *0.012),
            padding: EdgeInsets.symmetric(
              horizontal: size * 0.02,
              vertical: size * 0.03,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              crossAxisSpacing: isMobile ? 12 : 20,
              mainAxisSpacing: isMobile ? 20 : 30,
              childAspectRatio: isMobile ? 1.95 : 2.05,
            ),
            itemCount: widget.symbol.partyLogo.length,
            itemBuilder: (context, index){
              final logo = widget.symbol.partyLogo[index];
              final double radius = isDesktop
                  ? 100
                  : isTablet
                  ? 85
                  : 70;

              return Center(
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: logo.isNotEmpty
                        ? buildImageWidget(
                      logo,
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                ),
              );
              // return  Container(
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //
              //   ),
              //
              //   // child: ClipRRect(
              //   //   borderRadius: BorderRadius.circular(12),
              //   //   child: CircleAvatar(
              //   //     radius: 166,
              //   //     backgroundColor: Colors.transparent,
              //   //     child:logo.isNotEmpty?
              //   //     buildImageWidget(logo,fit: BoxFit.cover):null
              //   //   ),
              //   // ),
              // );
            }),
        SizedBox(height: MediaQuery.of(context).size.width * 0.06),
        ?widget.symbol.partyLogo.length!=0?   Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () async {
              if (widget.symbol.downloadEnabled == true ||
                  widget.symbol.downloadEnabled== "YES" ) {
                for (final logo in widget.symbol.partyLogo){
                  await downloadImage(
                    logo.startsWith("/api/")
                        ? "$api$logo"
                        : logo,
                    context
                  );
                }
              }
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 37, maxWidth: 200),
              decoration: BoxDecoration(
                color: (widget.symbol.downloadEnabled == true ||
                    widget.symbol.downloadEnabled== "YES")
                    ? null
                    : const Color(0xFF666666),
                gradient: (widget.symbol.downloadEnabled == true ||
                    widget.symbol.downloadEnabled == "YES")
                    ? GradientColors.primaryGradient
                    : null,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child:  Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.symbol.partyLogo.length==1?
                      "Download Logo":"Download Logos",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.textScalerOf(context).scale(14),
                        letterSpacing: 0.37,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.006,),
                    Transform.rotate(angle: 1.57 ,child: SvgPicture.asset(PartyPageData.arrow,height: MediaQuery.of(context).size.height*0.015,),)
                  ],
                ),
              ),
            ),
          ),
        ):null,
        SizedBox(height: MediaQuery.of(context).size.width * 0.06),
      ],
     )
    );
  }
}
