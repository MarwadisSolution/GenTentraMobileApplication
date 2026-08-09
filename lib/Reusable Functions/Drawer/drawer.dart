import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/Drawer/bloc_code_in_one.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Login Page/Login Bloc/login_bloc.dart';
import '../../Login Page/Login Bloc/login_modal.dart';
import '../../Login Page/Sign up/signup_page.dart';
import '../../Login Page/login_apis.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  final LoginApi api = LoginApi();

  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    profile = await api.profileData();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.06,
                    right: MediaQuery.of(context).size.width * 0.06,
                    left: MediaQuery.of(context).size.width * 0.06,
                    bottom: MediaQuery.of(context).size.height * 0.03,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage: profile?["avatarUrl"] != null
                            ? NetworkImage("$api${profile!["avatarUrl"]}")
                            : null,
                        child: profile?["avatarUrl"] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            profile == null ? "-" : profile!["firstName"] ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  (MediaQuery.of(context).size.width * 0.06)
                                      .clamp(14.0, 18.0),
                              letterSpacing: 0.31,
                              color: ColorScheme.of(context).surface,
                            ),
                          ),
                          subtitle: Text(
                            profile == null ? "-" : profile!["city"] ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              letterSpacing: 0.31,
                              color: ColorScheme.of(context).surface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).surface,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.01,
                        ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PartyPage(),
                                  ),
                                );
                              },
                            ),
                            drawerItem(
                              "Start Campaign", // "Start Campaign",
                              isBold: state.selectedIndex == 3,
                              onTapping: () {
                                context.read<DrawerBloc>().add(
                                  SelectDrawerItemEvent(3),
                                );
                              },
                            ),
                            Divider(
                              color: Color(0xFFBCBCBC),
                              indent:
                                  MediaQuery.of(context).size.width * 0.042,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.09,
                            ),
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
                            Divider(
                              color: Color(0xFFBCBCBC),
                              indent:
                                  MediaQuery.of(context).size.width * 0.042,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.09,
                            ),
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
                            Divider(
                              color: Color(0xFFBCBCBC),
                              indent:
                                  MediaQuery.of(context).size.width * 0.042,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.09,
                            ),

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
                            Divider(
                              color: Color(0xFFBCBCBC),
                              indent:
                                  MediaQuery.of(context).size.width * 0.042,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.09,
                            ),

                            drawerItem(
                              "Settings",
                              isBold: state.selectedIndex == 10,
                              onTapping: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                print(
                                  "Saved accessToken = ${prefs.getString("accessToken")}",
                                );
                                print(
                                  "Saved refreshToken = ${prefs.getString("refreshToken")}",
                                );
                                await prefs.clear();

                                print(
                                  "After accessToken = ${prefs.getString("accessToken")}",
                                );
                                print(
                                  "After refreshToken = ${prefs.getString("refreshToken")}",
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => LoginBloc(
                                        LoginRepository(LoginApi()),
                                      ),
                                      child: const SignupPage(),
                                    ),
                                  ),
                                );
                                // context.read<DrawerBloc>().add(
                                //   SelectDrawerItemEvent(10),
                                // );
                              },
                            ),
                            Divider(
                              color: Color(0xFFBCBCBC),
                              indent:
                                  MediaQuery.of(context).size.width * 0.042,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.09,
                            ),
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
    title: isBold
        ? ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => GradientColors.primaryGradient
                .createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height)),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.31,
              ),
            ),
          )
        : Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
              letterSpacing: 0.31,
            ),
          ),
    onTap: onTapping,
  );
}
