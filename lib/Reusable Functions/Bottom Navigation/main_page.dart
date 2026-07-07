import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Home Page/home_page.dart';
import '../Drawer/drawer.dart';
import 'bloc_conde_in_one_navigation.dart';
import 'bottom_navigation_page.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey =
  GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const DrawerPage(),

      body: BlocBuilder<BottomNavBloc, BottomNavState>(
        builder: (context, state) {
          return IndexedStack(
            index: state.selectedIndex,
            children:  [
              HomePage(  scaffoldKey: scaffoldKey,),
              // FavoritePage(),
              // ChatPage(),
              // CalendarPage(),
              // InboxPage(),
            ],
          );
        },
      ),

      bottomNavigationBar: const BottomNavigationPage(),
    );
  }
}