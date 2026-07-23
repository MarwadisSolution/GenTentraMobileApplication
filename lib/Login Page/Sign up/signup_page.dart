import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_bloc.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_event.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_state.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/otp_page.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/verify_otp_page.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import '../Login Bloc/login_modal.dart';
import '../login_apis.dart';
import '../login_pages_data.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  bool otpButtonPressed = false;
  int selectedGender = 0;
  String selectedCountryCode = "+91";
  final TextEditingController urlController = TextEditingController(
    text: api,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final signupData = context.read<LoginBloc>().state.signUpData;
    firstNameController.text = signupData.firstName;
    surnameController.text = signupData.surname;
    genderController.text = signupData.gender;
    // numberController.text = signupData.number;
    if (signupData.gender.isEmpty) {
      selectedGender = 0;

      context.read<LoginBloc>().add(
        UpdateSignupDataEvent(
          signupData.copyWith(gender: "Male"),
        ),
      );
    } else {
      genderController.text = signupData.gender;

      if (signupData.gender == "Male") {
        selectedGender = 0;
      } else if (signupData.gender == "Female") {
        selectedGender = 1;
      } else {
        selectedGender = 2;
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    firstNameController.dispose();
    surnameController.dispose();
    genderController.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.navigateToOtp != current.navigateToOtp,
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
          context.read<LoginBloc>().add(ResetNavigationEvent());

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
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.height * 0.035,
                    right: MediaQuery.of(context).size.height * 0.035,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                        ),
                        Text(
                          LoginPageData.youAreUnique,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            letterSpacing: 0.31,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                            right: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Text(
                            LoginPageData.thereOnly,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              letterSpacing: 0.31,
                              color: ColorScheme.of(
                                context,
                              ).onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                        ),
                        CustomTextField(
                          controller: firstNameController,
                          labelText: LoginPageData.firstName,
                          keyboardType: TextInputType.name,
                          onChanged: (value) {
                            context.read<LoginBloc>().add(
                              UpdateSignupDataEvent(
                                state.signUpData.copyWith(firstName: value),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),

                        ///-------surname
                        CustomTextField(
                          controller: surnameController,
                          labelText: LoginPageData.surname,
                          keyboardType: TextInputType.name,
                          onChanged: (value) {
                            context.read<LoginBloc>().add(
                              UpdateSignupDataEvent(
                                state.signUpData.copyWith(surname: value),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  LoginPageData.gender,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: ColorScheme.of(
                                      context,
                                    ).onSurface.withOpacity(0.3),
                                  ),
                                ),
                                SizedBox(width: 30),
                                //------Male
                                InkWell(
                                  onTap: () {
                                    selectedGender = 0;

                                    context.read<LoginBloc>().add(
                                      UpdateSignupDataEvent(
                                        state.signUpData.copyWith(
                                          gender: "Male",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 75,
                                      minHeight: 30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedGender == 0
                                          ? null
                                          : ColorScheme.of(
                                              context,
                                            ).onSurface.withOpacity(0.26),
                                      gradient: selectedGender == 0
                                          ? GradientColors.primaryGradient
                                          : null,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          LoginPageData.male,
                                          style: TextStyle(
                                            color: ColorScheme.of(
                                              context,
                                            ).surface,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            letterSpacing: 0.37,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                ///------Female
                                SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    selectedGender = 1;

                                    context.read<LoginBloc>().add(
                                      UpdateSignupDataEvent(
                                        state.signUpData.copyWith(
                                          gender: "Female",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 75,
                                      minHeight: 30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedGender == 1
                                          ? null
                                          : ColorScheme.of(
                                              context,
                                            ).onSurface.withOpacity(0.26),
                                      gradient: selectedGender == 1
                                          ? GradientColors.primaryGradient
                                          : null,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          LoginPageData.female,
                                          style: TextStyle(
                                            color: ColorScheme.of(
                                              context,
                                            ).surface,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            letterSpacing: 0.37,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    selectedGender = 2;

                                    context.read<LoginBloc>().add(
                                      UpdateSignupDataEvent(
                                        state.signUpData.copyWith(
                                          gender: "Other",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 75,
                                      minHeight: 30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedGender == 2
                                          ? null
                                          : ColorScheme.of(
                                              context,
                                            ).onSurface.withOpacity(0.26),
                                      gradient: selectedGender == 2
                                          ? GradientColors.primaryGradient
                                          : null,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          LoginPageData.other,
                                          style: TextStyle(
                                            color: ColorScheme.of(
                                              context,
                                            ).surface,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            letterSpacing: 0.37,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ///---URL Temp
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        TextField(
                          controller: urlController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: "Server URL",
                            // hintText: "https://example.trycloudflare.com",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorScheme.of(context).onSurface.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorScheme.of(context).onSurface.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        ///-----Number
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        TextField(
                          controller: numberController,
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          cursorColor: ColorScheme.of(context).onSurface,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (value) {
                            context.read<LoginBloc>().add(
                              NumberFillingForOtpEvent(
                                value,
                                selectedCountryCode,
                              ),
                            );
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
                                    numberController.text,
                                    selectedCountryCode,
                                  ),
                                );
                              },
                              initialSelection: 'IN',
                              favorite: const ['+91', 'IN'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black,
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
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: ColorScheme.of(
                                  context,
                                ).onSurface.withOpacity(0.3),
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
                            otpButtonPressed = true;
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) =>
                                  LoginBloc(LoginRepository(LoginApi())),
                              child: const OtpPage(),
                            ),
                          ),
                        );
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
          );
        },
      ),
    );
  }
}
