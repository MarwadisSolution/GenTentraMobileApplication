import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/login_pages_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/Drawer/bloc_code_in_one.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
    shape:  const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
      child: BlocBuilder<DrawerBloc, DrawerState>(
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              gradient: GradientColors.primaryGradient,
              //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight:Radius.circular(20) )
            ),
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.only(top: 40.0, right:28, left: 20,bottom: 30),
                  child: Row(
                    children: [

                      CircleAvatar(
                        backgroundColor: Colors.grey,
                       // backgroundImage: SvgPicture.asset(LoginPageData.arrowIcon),
                        radius: 25,
                      ),
                      Expanded(
                        child: ListTile(
                          title:Text( "Riddesh Kankariya"),
                          subtitle: Text("Malegaon"),
                        ),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(

                      decoration: BoxDecoration(
                          color: ColorScheme.of(context).surface,
                        borderRadius: BorderRadius.only( topRight: Radius.circular(20),topLeft: Radius.circular(20))
                      ),
                      child: Padding(
                        padding:  EdgeInsets.only(left: 10.0),
                        child: ListView(
                          children: [
                            drawerItem(
                              "Home",
                              isBold: state.selectedIndex == 0,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(0),
                                );
                              },
                            ),
                            drawerItem(
                              "Country/State",
                              isBold: state.selectedIndex == 1,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(1),
                                );
                              },
                            ),
                            drawerItem(
                              "Partys",
                              isBold: state.selectedIndex == 2,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(2),
                                );
                              },
                            ),
                            drawerItem(
                              "Start Campaign",
                              isBold: state.selectedIndex == 3,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(3),
                                );
                              },
                            ),
                             Divider(color: Color(0xFFBCBCBC),indent: MediaQuery.of(context).size.width*0.042,endIndent: MediaQuery.of(context).size.width*0.09,),
                            drawerItem(
                              "Public Pole",
                              isBold: state.selectedIndex == 4,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(4),
                                );
                              },
                            ),
                            drawerItem(
                              "Birthdays",
                              isBold: state.selectedIndex == 5,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(5),
                                );
                              },
                            ),
                            Divider(color: Color(0xFFBCBCBC),indent: MediaQuery.of(context).size.width*0.042,endIndent: MediaQuery.of(context).size.width*0.09,),
                            drawerItem(
                              "Brand Consulting",
                              isBold: state.selectedIndex == 6,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(6),
                                );
                              },
                            ),
                            drawerItem(
                              "Make a Donation",
                              isBold: state.selectedIndex == 7,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(7),
                                );
                              },
                            ),
                            Divider(color: Color(0xFFBCBCBC),indent: MediaQuery.of(context).size.width*0.042,endIndent: MediaQuery.of(context).size.width*0.09,),

                            drawerItem(
                              "Privacy Policy",
                              isBold: state.selectedIndex == 8,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(8),
                                );
                              },
                            ),
                            drawerItem(
                              "Make a Donation",
                              isBold: state.selectedIndex == 9,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(9),
                                );
                              },
                            ),
                            Divider(color: Color(0xFFBCBCBC),indent: MediaQuery.of(context).size.width*0.042,endIndent: MediaQuery.of(context).size.width*0.09,),

                            drawerItem(
                              "Settings",
                              isBold: state.selectedIndex == 10,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(10),
                                );
                              },
                            ),
                            Divider(color: Color(0xFFBCBCBC),indent: MediaQuery.of(context).size.width*0.042,endIndent: MediaQuery.of(context).size.width*0.09,),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
Widget drawerItem(
  String title, {
  bool isBold = false,
      VoidCallback? onTapping,
}) {
  return ListTile(
    dense: true,
    title:isBold? ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => GradientColors.primaryGradient.createShader(
        Rect.fromLTRB(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight:FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.31,
        ),
      ),
    ): Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontWeight:FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0.31,
      ),
    ),
    onTap:onTapping,
  );
}
