import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Home%20Page/home_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Reusable Functions/Drawer/bloc_code_in_one.dart';
import '../Reusable Functions/Drawer/drawer.dart';
class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HomePage({super.key,required this.scaffoldKey,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String accessToken = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadToken();
  }
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      accessToken = prefs.getString("accessToken") ?? '';
    });
  }
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ReusableSliverAppBar(
          titleWidget: SvgPicture.asset(HomePageData.logo),
          height: 70,

          onMenuTap: () {
            widget.scaffoldKey.currentState?.openDrawer();
          },
        ),
       SliverSections(child: SingleChildScrollView(
       child: Column(
       children: [
      ],
    ),
    ),),

      ],

    );
  }
}