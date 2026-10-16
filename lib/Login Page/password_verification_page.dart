import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_state.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/login_pages_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Reusable Functions/reusable_functions.dart';
import '../Reusable Functions/Bottom Navigation/bloc_conde_in_one_navigation.dart';
import '../Reusable Functions/Bottom Navigation/main_page.dart';
import '../Reusable Functions/Drawer/bloc_code_in_one.dart';
import 'Login Bloc/login_bloc.dart';
import 'Login Bloc/login_event.dart';
import 'Login Bloc/login_modal.dart';
import 'login_apis.dart';

class PasswordVerificationPage extends StatefulWidget {
  final String verificationToken;

  const PasswordVerificationPage({required this.verificationToken,super.key});

  @override
  State<PasswordVerificationPage> createState() => _PasswordVerificationPageState();
}

class _PasswordVerificationPageState extends State<PasswordVerificationPage> {

  final TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
  @override

  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => LoginBloc(LoginRepository(LoginApi())),
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) {
          return (!previous.isError && current.isError) ||
              (!previous.isSuccess && current.isSuccess);
        },
        listener: (context, state) {
          if (state.isError && state.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                    state.errorMessage.contains("has a status code of 400")
                        ? "Please enter correct password"
                        : state.errorMessage.contains("has a status code of 530")?"Please contact the owner":
                    state.errorMessage.contains("Failed host lookup:")?"Please start the server":
                    state.errorMessage.contains("The connection errored")
                        ? "You are offline":
                    state.errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          if (state.isSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => BottomNavBloc(),
                    ),
                    BlocProvider(
                      create: (_) => DrawerBloc(),
                    ),
                  ],
                  child: MainPage(),
                ),
              ),
            );
          }
        },

        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return
                        Card(
                          elevation: 2,
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 309,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                    LoginPageData.password,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize:  MediaQuery.textScalerOf(context).scale(14),
                                      color: const Color(0xFF656579),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
                                  child: TextField(

                                    controller: passwordController,
                                    onChanged: (value) {
                                      context.read<LoginBloc>().add(
                                        PasswordEvent(value),
                                      );

                                    },
                                    onSubmitted: (_)async{
                                      if(!state.isLoading) {
                                        context.read<LoginBloc>().passwordLogin( widget.verificationToken,
                                          passwordController.text,);
                                      }
                                    },
                                    keyboardType:
                                    TextInputType.visiblePassword,
                                    obscureText: state.obscureText,

                                    obscuringCharacter: '●',
                                    cursorColor: ColorScheme.of(
                                      context,
                                    ).onSurface,

                                    style: TextStyle(
                                      letterSpacing: state.obscureText
                                          ? 4
                                          : 2,
                                      color: ColorScheme.of(
                                        context,
                                      ).onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: MediaQuery.textScalerOf(context).scale(14),
                                    ),
                                    decoration: InputDecoration(
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          context.read<LoginBloc>().add(
                                            EyeButtonEvent(),
                                          );
                                        },

                                        child: Padding(
                                          padding: const EdgeInsets.all(12),

                                          child: SvgPicture.asset(
                                            color: ColorScheme.of(context).onSurface,
                                            state.obscureText
                                                ? LoginPageData.eyesOpen
                                                : LoginPageData.eyesClosed,
                                            height: 16,
                                            width: 16,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          4,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFC3C3CB),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          4,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFC3C3CB),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Center(
                                    child: InkWell(
                                      onTap:state.isLoading?null: () async {
                                        await context.read<LoginBloc>().passwordLogin(
                                          widget.verificationToken,
                                          passwordController.text,
                                        );
                                      },
                                      child: Container(
                                        height: MediaQuery.of(context).size.height * 0.054,
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          gradient:passwordController.text.isNotEmpty?
                                          GradientColors.primaryGradient:null,
                                          color: passwordController.text.isNotEmpty?null:ColorScheme.of(context).onSurface.withOpacity(0.3)
                                        ),
                                        child: Center(
                                          child: state.isLoading?
                                              SizedBox(
                                                //height: 22,width: 22,
                                                height:  MediaQuery.of(context).size.width*0.06,
                                                width:   MediaQuery.of(context).size.width*0.06,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(ColorScheme.of(context).surface),
                                                ),
                                              )
                                              :Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                LoginPageData.login,
                                                style: TextStyle(
                                                  fontSize:MediaQuery.textScalerOf(context).scale(14),
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                  color: ColorScheme.of(context).surface,
                                                ),
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                                              Transform.rotate(
                                                  angle: math.pi/180,
                                                  child: SvgPicture.asset(
                                                    LoginPageData.arrowIcon,
                                                    color: Colors.white,)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
