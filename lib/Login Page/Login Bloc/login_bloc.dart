import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_event.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_state.dart';

import 'login_modal.dart';

Timer? _timer;

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repository;

  LoginBloc(this.repository) : super(const LoginState()) {
    //print("LOGIN BLOC CREATED ${identityHashCode(this)}");
    on<NumberFillingForOtpEvent>(_phoneChanged);
    on<SignInButtonEvent>(_sendOtp);
    on<OtpFillingEvent>(_otpChanged);
    on<VerifyOtpEvent>(_verifyOtp);
    on<ResendOtpEvent>(_resendOtp);
    on<StartOtpTimerEvent>(_startTimer);
    on<TimerTickEvent>(_timerTick);
    on<ResetNavigationEvent>(_resetNavigation);
    ///----Signup---------
    on<CreateSignupEvent>(_onCreateSignupDetails);
    on<LoadSignupDataEvent>(_onLoadFirstAndSurnameDetails);
    on<UpdateSignupDataEvent>(_onUpdateSignUpData);
  }

  Future<void> _phoneChanged(
    NumberFillingForOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(phoneNumber: event.number));
  }

  Future<void> _sendOtp(
    SignInButtonEvent event,
    Emitter<LoginState> emit,
  ) async {
    final mobileNumber = state.signUpData.number.isNotEmpty
        ? state.signUpData.number
        : state.phoneNumber;
    print("Mobile Number: ${mobileNumber.toString()}");
    if (mobileNumber.isEmpty) {
      emit(
        state.copyWith(
          isError: false,
          errorMessage: '',
        ),
      );
      emit(
        state.copyWith(
          isError: true,
          errorMessage: "Please fill the mobile number",
        ),
      );
      return;
    }
    if (mobileNumber.length != 10) {
      emit(
        state.copyWith(
          isError: false,
          errorMessage: '',
        ),
      );
      emit(
        state.copyWith(
          isError: true,
          errorMessage: "Enter valid mobile number",
        ),
      );
      return;
    }
    try {
      emit(state.copyWith(isLoading: true));

      ///--------api
      await repository.sendOtp(state.phoneNumber);
      emit(state.copyWith(isLoading: false, navigateToOtp: true));
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

  Future<void>_verifyOtp(
      VerifyOtpEvent event,
      Emitter<LoginState> emit,
      )async{
    if(event.otp.length!=6){
      emit(state.copyWith(
        isError: true,
        errorMessage: "Enter valid OTP",
      )
      );
      return;
    }
    try{
      emit(
          state.copyWith(
            isVerifyingOtp: true,
            isError: false,
            errorMessage: "",
        )
      );
      final response=await repository.verifyOtp(state.phoneNumber,
          event.otp,);
      emit(
        state.copyWith(
          isVerifyingOtp: false,
          isSuccess: true,
          isError: false,
          errorMessage: "",
          verificationToken: response.verificationToken,
          navigateToNewUser: response.isNewUser,
          navigateToOldUser: !response.isNewUser,
        ),
      );
    }
    catch(e){
      emit(
        state.copyWith(
          isVerifyingOtp: false,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }
  Future<void>_resendOtp(
      ResendOtpEvent event,
      Emitter<LoginState> emit,
      )async{
    await repository.sendOtp(state.phoneNumber,);
    add(StartOtpTimerEvent());
  }
  void _startTimer(
      StartOtpTimerEvent event,
      Emitter<LoginState> emit,
      ) {
    _timer?.cancel();

    int seconds = 60;

    emit(
      state.copyWith(
        resendTimer: seconds,
        canResendOtp: false,
      ),
    );

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        seconds--;

        add(TimerTickEvent(seconds));

        if (seconds <= 0) {
          timer.cancel();
        }
      },
    );
  }
  void _timerTick(
      TimerTickEvent event,
      Emitter<LoginState> emit,
      ){
    emit(
    state.copyWith(
    resendTimer: event.seconds,
  canResendOtp: event.seconds==0,
    )
    );
  }
  void _resetNavigation(
  ResetNavigationEvent event,
  Emitter<LoginState> emit,
  ){
    emit(
    state.copyWith(
    navigateToOtp: false,
    navigateToNewUser: false,
    navigateToOldUser: false,
    )
    );
  }
  @override
  Future<void> close() {
    //print("LOGIN BLOC CLOSED ${identityHashCode(this)}");
  _timer?.cancel();
  return super.close();
  }

  ///-----------Sign up
void _onCreateSignupDetails(
    CreateSignupEvent event,
    Emitter<LoginState>emit,
    ){
    emit(
      LoginState(signUpData: const SignUpModal()),
    );
 }
 Future<void> _onLoadFirstAndSurnameDetails(
     LoadSignupDataEvent event,
     Emitter<LoginState> emit,
     )async{
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try{
      await Future.delayed(const Duration(seconds: 1));
      final signUpData=SignUpModal(
        ///-----Replace karna ka api ke response se
        firstName: "Riddesh",
        surname: "Kankariya",
        gender: "Male",
        number: "9552936422",
      );
      emit(state.copyWith(isLoading: false, signUpData: signUpData));
    }
    catch(e){
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
 }
 void _onUpdateSignUpData(
     UpdateSignupDataEvent event,
     Emitter<LoginState>emit,
     ){
    emit(
      state.copyWith(
        signUpData: event.signUpData,
      )
    );
 }
}
