import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/Bottom%20Navigation/bloc_conde_in_one_navigation.dart';
class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, BottomNavState>(
        builder: (context, state){
          return Container(
            margin: EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
          color: ColorScheme.of(context).surface.withOpacity(0.96),
              borderRadius: BorderRadius.circular(30),
              boxShadow:  [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 6),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                navItem(context, ["Assets/appBar&NavBar/homeColored.svg","Assets/appBar&NavBar/home.svg"], 0, state),
                navItem(context, ["Assets/appBar&NavBar/myFavoriteColored.svg","Assets/appBar&NavBar/myFavorite.svg"], 1, state),
                navItem(context, ["Assets/appBar&NavBar/chatColored.svg","Assets/appBar&NavBar/chat.svg"], 2, state),
                navItem(context, ["Assets/appBar&NavBar/eventColored.svg","Assets/appBar&NavBar/event.svg"], 3, state),
                navItem(context, ["Assets/appBar&NavBar/elections.svg","Assets/appBar&NavBar/electionsColored.svg"], 4, state),
              ],
            ),
          );
        }
    );
  }
}

Widget navItem(
    BuildContext context,
  List<String> iconPath,
    int index,
    BottomNavState state,
    ) {
  final isSelected = state.selectedIndex == index;

  return IconButton(
    onPressed: () {
      context.read<BottomNavBloc>().add(
        SelectBottomNavItemEvent(index),
      );
    },
    icon: SvgPicture.asset(isSelected?iconPath[0]:iconPath[1], height: 18.35,)
  );
}