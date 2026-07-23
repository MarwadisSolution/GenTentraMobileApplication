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
    return ListView(
      padding:  EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.05),
      children: [

        ExpandableQuillContent(
          content: label
        ),
        GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding:  EdgeInsets.all(MediaQuery.sizeOf(context).width *0.012),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 30,
              childAspectRatio: 1.8,
            ),
            itemCount: widget.symbol.partyLogo.length,
            itemBuilder: (context, index){
              final logo = widget.symbol.partyLogo[index];
              return  Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    child:logo.isNotEmpty?
                    buildImageWidget(logo,fit: BoxFit.cover):null

                  ),
                ),
              );
            }),
        SizedBox(height: MediaQuery.of(context).size.width * 0.06),
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () async {
              if (widget.symbol.downloadEnabled == true ||
                  widget.symbol.downloadEnabled== "YES") {
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

              constraints: const BoxConstraints(minHeight: 37, maxWidth: 150),
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
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.06),
      ],
    );
  }
}
