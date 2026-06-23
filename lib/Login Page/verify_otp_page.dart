import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Home%20Page/home_page.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_bloc.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_state.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/otp_page.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Sign%20up/signup_page.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import 'Login Bloc/login_event.dart';
import 'login_pages_data.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  late final List<TextEditingController> otpControllers;
  @override
  void initState() {
    super.initState();
    // print("VERIFY PAGE INIT ${identityHashCode(this)}");
    otpControllers = List.generate(
      6,
          (_) => TextEditingController(),
    );
  }
  @override
  void dispose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  // final List<TextEditingController> otpControllers = List.generate(
  //   6,
  //       (_) => TextEditingController(),
  // );
  @override
  Widget build(BuildContext context) {
   // print("VERIFY PAGE BUILD");
    return BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
    previous.isError != current.isError ||
        previous.navigateToNewUser != current.navigateToNewUser ||
        previous.navigateToOldUser != current.navigateToOldUser,
        listener: (context, state) {

          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state.navigateToNewUser) {
            context.read<LoginBloc>().add(
              ResetNavigationEvent(),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const SignupPage(),
              ),
            );
          }

          if (state.navigateToOldUser) {
            context.read<LoginBloc>().add(
              ResetNavigationEvent(),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
            );
          }
        },
      child: BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            // print(
            //     "BUILDER CALLED => "
            //         "${previous.resendTimer} -> ${current.resendTimer}"
            // );

            return previous.isVerifyingOtp != current.isVerifyingOtp ||
                previous.isSuccess != current.isSuccess ||
                previous.isError != current.isError ||
                previous.navigateToNewUser != current.navigateToNewUser ||
                previous.navigateToOldUser != current.navigateToOldUser;
          },
          builder: (context,state){
            return GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                body: LayoutBuilder(
                    builder: (context, constraint){
                      return SingleChildScrollView(
                        child: Padding(
                          padding:  EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                            right: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Transform.rotate(angle:3.14159,
                                  child:InkWell(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: SvgPicture.asset(LoginPageData.arrowIcon,color: Colors.black,width: MediaQuery.of(context).size.width*0.05,)) ,),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                              ),
                              Text(
                                LoginPageData.safetyStartHere,
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
                                LoginPageData.weSentDigit,
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
                              OtpInputFields(
                                key: const ValueKey("otp_fields"),
                                otpControllers: otpControllers,
                              ),
                              SizedBox(height: 10,),
                              if (state.isVerifyingOtp)
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: CircularProgressIndicator(),
                                ),
                              if(state.isSuccess)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Success",style: TextStyle(
                                      color: Color(0xFF6DBE45),
                                      fontWeight: FontWeight.w600,
                                    ),),
                                    SizedBox(width: 6),
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6DBE45),
                                      size: 16,
                                    ),
                                  ],
                                ),
                                if (state.isError)
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      "Please enter a valid code",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 20),

                              BlocBuilder<LoginBloc, LoginState>(
                                buildWhen: (p, c) =>
                                p.resendTimer != c.resendTimer ||
                                    p.canResendOtp != c.canResendOtp,
                                builder: (context, state) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Didn't get a code?",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8B8B8B),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: state.canResendOtp
                                                ? () {
                                              context.read<LoginBloc>().add(
                                                ResendOtpEvent(),
                                              );
                                            }
                                                : null,
                                            child: Text(
                                              state.canResendOtp
                                                  ? "Request new code "
                                                  : "Request new code in ",
                                            ),
                                          ),
                                          if (!state.canResendOtp)
                                            Text(state.resendTimer.toString(),style: TextStyle(color: Colors.red),),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
SizedBox(height: MediaQuery.of(context).size.height*0.04,),
InkWell(
  onTap: (){
    if(state.isSuccess){
      context.read<LoginBloc>().add(ResetNavigationEvent());
    }
  },
  child:Container(
    constraints: BoxConstraints(
      maxWidth: 122,
      minHeight: 40,
    ),
    decoration: BoxDecoration(
      color:state.isSuccess?null:ColorScheme.of(context).onSurface.withOpacity(0.3) ,
      gradient: state.isSuccess?GradientColors.primaryGradient:null,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Next",style: TextStyle(color: ColorScheme.of(context).surface),),
        SizedBox(width: MediaQuery.of(context).size.width*0.02,),
        SvgPicture.asset(LoginPageData.arrowIcon)
      ],
    ),
  ),
)
                            ],
                          ),
                        ),
                      );
                }),
              ),
            );
          }
      )
    );
  }
}

class OtpInputFields extends StatefulWidget {
  final List<TextEditingController> otpControllers;

  const OtpInputFields({
    super.key,
    required this.otpControllers,
  });

  @override
  State<OtpInputFields> createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<OtpInputFields>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // print("OTP FIELDS REBUILD ${DateTime.now()}");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
            (index) => SizedBox(
          width: 35,
          child: TextField(
            controller: widget.otpControllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: const InputDecoration(
              counterText: "",
            ),
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                FocusScope.of(context).nextFocus();
              }

              if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }

              bool allFilled = widget.otpControllers.every(
                    (controller) => controller.text.isNotEmpty,
              );

              if (allFilled) {
                final enteredOtp =
                widget.otpControllers.map((e) => e.text).join();

                context.read<LoginBloc>().add(
                  VerifyOtpEvent(enteredOtp),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}