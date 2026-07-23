import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_bloc.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_event.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_state.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/verify_otp_page.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'Login Bloc/login_modal.dart';
import 'Sign up/signup_page.dart';
import 'login_apis.dart';
import 'login_pages_data.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool otpButtonPressed=false;
  String selectedCountryCode = "+91";
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController urlController =
  TextEditingController(
    text: ApiConfig.baseUrl,
  );
  @override
  Widget build(BuildContext context) {

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isError && otpButtonPressed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(state.errorMessage),
            ),
          );
          otpButtonPressed = false;
        }
        if (state.navigateToOtp) {
          print("NAVIGATING TO VERIFY PAGE");
          context.read<LoginBloc>().add(
            ResetNavigationEvent(),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<LoginBloc>(),
                child: const VerifyOtpPage(),
              ),
            ),
          );
        }
      },
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.height * 0.03,
                    right: MediaQuery.of(context).size.height * 0.03,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                        ),
                        Text(
                          LoginPageData.welcomeBack,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            letterSpacing: 0.31,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005,
                        ),
                        Text(
                          LoginPageData.wereGlad,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            letterSpacing: 0.31,
                            color: ColorScheme.of(
                              context,
                            ).onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        ),
                        TextField(
                          controller: urlController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: "Server URL",
                            //hintText: "https://example.trycloudflare.com",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorScheme.of(
                                  context,
                                ).onSurface.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorScheme.of(
                                  context,
                                ).onSurface.withOpacity(0.3),

                                width: 1,
                              ),
                            ),
                          ),
                        ),
                       SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                        TextField(
                          controller: phoneController,
                          maxLength: 10,

                          keyboardType: TextInputType.number,
                          cursorColor: ColorScheme.of(context).onSurface,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (value) {
                            context.read<LoginBloc>().add(
                              NumberFillingForOtpEvent(value, selectedCountryCode,),
                            );
                          },
                          onSubmitted: (value) {
                            context.read<LoginBloc>().add(SignInButtonEvent());
                          },
                          decoration: InputDecoration(
                            counterText: "",
                            prefixIcon: CountryCodePicker(
                              onChanged: (country) {
                                setState(() {
                                  selectedCountryCode = country.dialCode!;
                                });

                                context.read<LoginBloc>().add(
                                  NumberFillingForOtpEvent(
                                    phoneController.text,
                                    selectedCountryCode,
                                  ),
                                );
                              },
                              initialSelection: 'IN',
                              favorite: ['+91','IN'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black
                              ),
                            ),
                            labelText: LoginPageData.mobileNo,
                            labelStyle: TextStyle(
                              color: ColorScheme.of(
                                context,
                              ).onSurface.withOpacity(0.3),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorScheme.of(
                                  context,
                                ).onSurface.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorScheme.of(
                                  context,
                                ).onSurface.withOpacity(0.3),

                                width: 1,
                              ),
                            ),
                          ),
                        ),

                        ///----------------Generate OTP----------
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                        ),
                        InkWell(
                          onTap: () {
                            api = urlController.text.trim();
                            otpButtonPressed=true;
                            context.read<LoginBloc>().add(SignInButtonEvent());
                          },
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.054,
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: GradientColors.primaryGradient,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    LoginPageData.generateOtp,
                                    style: TextStyle(
                                      color: ColorScheme.of(context).surface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.02,
                                  ),
                                  SvgPicture.asset(LoginPageData.arrowIcon),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.06,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LoginPageData.alreadyHaveAnAccount,
                      style: TextStyle(
                        color: ColorScheme.of(
                          context,
                        ).onSurface.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
                            BlocProvider(create: (_) => LoginBloc(LoginRepository(LoginApi()),
                            ),
                              child: const SignupPage(),
                            )
                        ));
                      },
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) =>
                            GradientColors.primaryGradient.createShader(
                              Rect.fromLTRB(0, 0, bounds.width, bounds.height),
                            ),
                        child: Text(
                          LoginPageData.signIn,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

    );
  }
}
