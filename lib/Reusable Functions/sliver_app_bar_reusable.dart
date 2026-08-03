import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/login_pages_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/Drawer/drawer.dart';

import 'reusable_functions.dart';
class ReusableSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final bool automaticallyImplyLeading;
  final double height;
  final Widget? child;
  final VoidCallback? onMenuTap;
  const ReusableSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.automaticallyImplyLeading=false,
    this.height=200,
    this.child,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      titleSpacing: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      forceElevated: false,

      // automaticallyImplyActions:automaticallyImplyLeading,
      leading: automaticallyImplyLeading
          ? IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Transform.rotate(
          angle: 3.14,
          child: SvgPicture.asset(
            "Assets/arrow.svg",
            width: MediaQuery.of(context).size.width*.018,
            height: MediaQuery.of(context).size.height*.023,
          ),
        ),
      )
          : IconButton(
        onPressed: onMenuTap,
        icon: const Icon(
          Icons.menu,
          color: Color(0xFFE3E3E3),
        ),
      ),
      // actions: [
      //  IconButton(
      //      onPressed: (){},
      //      icon: SvgPicture.asset("Assets/appBar&NavBar/plusIcon.svg"),
      //  ),
      //   IconButton(
      //       onPressed: (){},
      //       icon: SvgPicture.asset("Assets/appBar&NavBar/bellIcon.svg"),
      //   )
      // ],
      title:titleWidget?? Text(
        title??'',
        textAlign: TextAlign.left,
        style:  TextStyle(
          color: ColorScheme.of(context).surface,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),

    //  backgroundColor: Colors.black,
      //automaticallyImplyLeading: true,

      iconTheme: IconThemeData
        (color: ColorScheme.of(context).secondary),
      expandedHeight: height,
      floating: false,
      snap: false,
      pinned: true,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: GradientColors.primaryGradient,
        // borderRadius: BorderRadius.vertical(
        //   bottom: Radius.circular(20),
        // ),
      ),

      child: FlexibleSpaceBar(
        background: child,
      ),
    ),
    );
  }
}

class SliverSections extends StatelessWidget {
  final Widget child;
  const SliverSections({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: child,
    );
  }
}