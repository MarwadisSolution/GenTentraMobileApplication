import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_event.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_state.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Sign%20up/signup_apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_apis.dart';
import 'login_modal.dart';

Timer? _timer;

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  ///-----------------Password function
  Future<void> passwordLogin(String verificationToken, String password) async {
    // Prevent multiple simultaneous login requests.
    if (state.isLoading) return;

    // Clear the previous error before a new attempt.
    emit(
      state.copyWith(
        isLoading: false,
        isError: false,
        errorMessage: '',
        isSuccess: false,
      ),
    );

    // Validate only when Login is tapped or the form is submitted.
    if (password.trim().isEmpty) {
      emit(
        state.copyWith(
          isError: true,
          errorMessage: 'Please enter the password',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final result = await LoginApi().passwordVerification(
        verificationToken,
        password,
      );

      final auth = result['auth'];
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('accessToken', auth['accessToken']);
      await prefs.setString('refreshToken', auth['refreshToken']);
      await prefs.setString('userUuid', auth['userUuid']);
      await prefs.setString('role', auth['role']);

      if (auth['role'] == 'ROLE_PARTY_ADMIN') {
        await prefs.setString('AdminOfParty', result['partyId'].toString());
      }

      await prefs.setInt('loginTime', DateTime.now().millisecondsSinceEpoch);

      await prefs.setBool('isLogged', true);

      emit(
        state.copyWith(
          isLoading: false,
          isError: false,
          errorMessage: '',
          isSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }
///-------------------------------------------------------------
  final LoginRepository repository;

  LoginBloc(this.repository) : super(const LoginState()) {
    on<NumberFillingForOtpEvent>(_phoneChanged);
    on<SignInButtonEvent>(_sendOtp);
    on<OtpFillingEvent>(_otpChanged);
    on<VerifyOtpEvent>(_verifyOtp);
    on<ResendOtpEvent>(_resendOtp);
    on<StartOtpTimerEvent>(_startTimer);
    on<TimerTickEvent>(_timerTick);
    on<ResetNavigationEvent>(_resetNavigation);
    on<ClearOtpStatusEvent>(_clearOtpStatusEvent);
    on<ClearOtpResentEvent>(_clearOtpResentEvent);

    ///----Signup---------
    on<CreateSignupEvent>(_onCreateSignupDetails);
    on<LoadSignupDataEvent>(_onLoadFirstAndSurnameDetails);
    on<UpdateSignupDataEvent>(_onUpdateSignUpData);
    on<AddressSignUpEvent>(_onAddressSignUp);

    on<PasswordEvent>((event, emit) {
      emit(
        state.copyWith(
          password: event.password,
          isError: false,
          errorMessage: '',
        ),
      );
    });
    on<PasswordLoginLoadingEvent>((event, emit) {
      emit(
        state.copyWith(
          isLoading: event.isLoading,
          isError: false,
          errorMessage: '',
        ),
      );
    });

    //Eye button
    on<EyeButtonEvent>((event, emit) {
      emit(state.copyWith(obscureText: !state.obscureText));
    });
    //Submit
    on<SubmitButtonEvent>((event, emit) async {
      if (state.password.isEmpty) {
        emit(
          state.copyWith(
            isError: true,
            errorMessage: "Please enter the password",
          ),
        );
        return;
      }
      emit(state.copyWith(isError: false, errorMessage: '', isLoading: true));
      try {
        //Api calling kar na hai-----------------------------
        //String response=await loginApi.otpRequest(state.email, "");
        await Future.delayed(const Duration(seconds: 2));
        emit(state.copyWith(isLoading: false));
      } catch (e) {
        emit(
          state.copyWith(
            isLoading: false,
            isError: false,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }

  Future<void> _phoneChanged(
    NumberFillingForOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(phoneNumber: "${event.countryCode}${event.number}"));
  }

  Future<void> _sendOtp(
      SignInButtonEvent event,
      Emitter<LoginState> emit,
      ) async {
    // Clear the previous error before processing a new request.
    emit(state.copyWith(
      isError: false,
      errorMessage: '',
    ));

    final mobileNumber = state.phoneNumber;

    if (mobileNumber.isEmpty) {
      emit(state.copyWith(
        isError: true,
        errorMessage: 'Please fill the mobile number',
      ));
      return;
    }

    if (!RegExp(r'^\+\d{6,15}$').hasMatch(mobileNumber)) {
      emit(state.copyWith(
        isError: true,
        errorMessage: 'Enter a valid mobile number',
      ));
      return;
    }

    // Keep your existing try/catch and API logic below this point.
    try {
      emit(state.copyWith(isLoading: true));

      ///--------api

      await repository.sendOtp(mobileNumber);
      emit(
        state.copyWith(
          isLoading: false,
          isError: false,
          errorMessage: "",
          navigateToOtp: true,
        ),
      );
      add(StartOtpTimerEvent());
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _otpChanged(OtpFillingEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(otp: event.otp));
  }

  Future<void> _verifyOtp(
      VerifyOtpEvent event,
      Emitter<LoginState> emit,
      ) async {
    // Prevent duplicate verification requests.
    if (state.isVerifyingOtp) return;

    if (event.otp.length != 6) {
      emit(state.copyWith(
        isError: true,
        errorMessage: "Enter valid OTP",
      ));
      return;
    }

    try {
      // Clear the previous error when a new attempt starts.
      emit(state.copyWith(
        isVerifyingOtp: true,
        isError: false,
        errorMessage: "",
      ));

      final response = await repository.verifyOtp(
        state.phoneNumber,
        event.otp,
      );

      print("OTP VERIFIED SUCCESS");
      print("isNewUser = ${response.isNewUser}");

      emit(state.copyWith(
        isVerifyingOtp: false,
        isSuccess: true,
        isError: false,
        errorMessage: "",
        requirePassword: response.requirePassword,
        verificationToken: response.verificationToken,
        navigateToNewUser: response.isNewUser,
        navigateToOldUser: !response.isNewUser,
      ));
    } catch (e) {
      emit(state.copyWith(
        isVerifyingOtp: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _resendOtp(
      ResendOtpEvent event,
      Emitter<LoginState> emit,
      ) async {
    // Clear the previous error before a new resend attempt.
    emit(state.copyWith(
      isError: false,
      errorMessage: '',
    ));

    try {
      await repository.sendOtp(state.phoneNumber);

      print("Resend completed");

      emit(state.copyWith(otpResent: true));

      add(StartOtpTimerEvent());
    } catch (e) {
      emit(state.copyWith(
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  void _startTimer(StartOtpTimerEvent event, Emitter<LoginState> emit) {
    _timer?.cancel();

    int seconds = 30;

    emit(state.copyWith(resendTimer: seconds, canResendOtp: false));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;

      add(TimerTickEvent(seconds));

      if (seconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _timerTick(TimerTickEvent event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        resendTimer: event.seconds,
        canResendOtp: event.seconds == 0,
      ),
    );
  }

  void _resetNavigation(ResetNavigationEvent event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        navigateToOtp: false,
        navigateToNewUser: false,
        navigateToOldUser: false,
        navigateToHome: false,
        isError: false,
        errorMessage: "",
      ),
    );
  }

  @override
  Future<void> close() {
    //print("LOGIN BLOC CLOSED ${identityHashCode(this)}");
    _timer?.cancel();
    return super.close();
  }

  void _clearOtpStatusEvent(
    ClearOtpStatusEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isSuccess: false, isError: false, errorMessage: ""));
  }

  void _clearOtpResentEvent(
    ClearOtpResentEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(otpResent: false));
  }

  ///-----------Sign up
  void _onCreateSignupDetails(
    CreateSignupEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginState(signUpData: const SignUpModal()));
  }

  Future<void> _onLoadFirstAndSurnameDetails(
    LoadSignupDataEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await Future.delayed(const Duration(seconds: 1));
      final signUpData = SignUpModal(
        ///-----Replace karna ka api ke response se
      );
      emit(state.copyWith(isLoading: false, signUpData: signUpData));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onUpdateSignUpData(
    UpdateSignupDataEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(signUpData: event.signUpData));
  }

  Future<void> _onAddressSignUp(
    AddressSignUpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isError: false, errorMessage: ''));

    try {
      final response = await SignupApis().signUp(
        event.verificationToken,
        event.signUpData,
      );

      final auth = response.data["data"]["auth"];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("accessToken", auth["accessToken"]);

      await prefs.setString("refreshToken", auth["refreshToken"]);

      await prefs.setString("userUuid", auth["userUuid"]);
      await prefs.setString("role", auth['role']);
      if (auth['role'] == "ROLE_PARTY_ADMIN") {
        await prefs.setString(
          "AdminOfParty",
          response.data["data"]["partyId"].toString(),
        );
      }
      print("profile1");
      print(prefs.getString("AdminOfParty"));
      print("Roles");
      print(prefs.getString("role"));
      await prefs.setBool("isLogged", true);

      await prefs.setInt("loginTime", DateTime.now().millisecondsSinceEpoch);
      print("===== SIGNUP SAVED =====");
      print("Saved accessToken = ${prefs.getString("accessToken")}");
      print("Saved refreshToken = ${prefs.getString("refreshToken")}");
      print("Saved userUuid = ${prefs.getString("userUuid")}");
      print("Roles: = ${prefs.getString("role")}");
      print("Saved isLogged = ${prefs.getBool("isLogged")}");
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          navigateToHome: true,
          errorMessage:
              response.data["message"] ?? "Account created successfully",
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
