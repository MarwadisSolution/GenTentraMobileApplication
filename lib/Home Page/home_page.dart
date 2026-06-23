import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Home%20Page/home_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../Reusable Functions/Drawer/bloc_code_in_one.dart';
import '../Reusable Functions/Drawer/drawer.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ReusableSliverAppBar(
          titleWidget: SvgPicture.asset(HomePageData.logo),
          onMenuTap: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ],
    );
  }
}