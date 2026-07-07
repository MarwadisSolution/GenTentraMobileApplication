import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_bloc.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_state.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/login_pages_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import '../Login Bloc/login_modal.dart';
import '../login_apis.dart';
class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  TextEditingController areaController=TextEditingController();
  TextEditingController cityController=TextEditingController();
  TextEditingController stateController=TextEditingController();
  TextEditingController countryController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(LoginRepository(LoginApi())),
      child: BlocListener<LoginBloc, LoginState>(
        listener: ((context, state) {
          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                  style: TextStyle(color: ColorScheme.of(context).onPrimary),
                ),
              ),
            );
          }
        }
        ),
        child:Scaffold(
          body: SafeArea(
              child: GestureDetector(
                onTap: (){
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.height * 0.035,
                    right: MediaQuery.of(context).size.height * 0.035,
                  ),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          LoginPageData.everyPlaceMatter,
                          style: TextStyle(
                            fontSize: MediaQuery.textScalerOf(context).scale(22),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.31,
                            color: ColorScheme.of(context).onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          LoginPageData.everyPlaceHasA,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: MediaQuery.textScalerOf(context).scale(15),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.31,
                            color: ColorScheme.of(context).onSurface.withOpacity(0.6),

                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.06,),

                     CustomTextField(
                       textStyle: TextStyle(
                         fontWeight: FontWeight.w500,
                         fontSize: MediaQuery.textScalerOf(context).scale(14),
                         letterSpacing: 0.5,
                         color: ColorScheme.of(context).onSurface,
                       ),
                       controller: areaController,
                       labelText: LoginPageData.area,
                       isRequired: true,
                         suffixIcon: Icon(Icons.arrow_drop_down,size: 25,)
                     ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      CustomTextField(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.textScalerOf(context).scale(14),
                          letterSpacing: 0.5,
                          color: ColorScheme.of(context).onSurface,
                        ),
                        controller: cityController, labelText: LoginPageData.city,
                        isRequired: true,
                          suffixIcon: Icon(Icons.arrow_drop_down,size: 25,)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      CustomTextField(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.textScalerOf(context).scale(14),
                          letterSpacing: 0.5,
                          color: ColorScheme.of(context).onSurface,
                        ),
                        controller: stateController, labelText: LoginPageData.state,
                        isRequired: true,
                        suffixIcon: Icon(Icons.arrow_drop_down,size: 25,)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      CustomTextField(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.textScalerOf(context).scale(14),
                          letterSpacing: 0.5,
                          color: ColorScheme.of(context).onSurface,
                        ),
                        controller: countryController, labelText: LoginPageData.country,
                        isRequired: true,
                          suffixIcon: Icon(Icons.arrow_drop_down,size: 25,)
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                      Padding(
                        padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*0.017),
                        child: Center(
                          child: InkWell(
                            onTap: () async {

                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.33,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(
                                  30,
                                ),
                                gradient:
                                GradientColors.primaryGradient,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    LoginPageData.signUp,
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
                    ],
                  ),
                ),
              )),
        ) ,
      ),
    );
  }
}
