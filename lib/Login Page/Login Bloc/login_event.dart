import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_modal.dart';

class LoginEvent extends Equatable{
  const LoginEvent();
  @override
  List<Object?>get props=>[];
}
///--------------OTP Page-------------------------------------
class NumberFillingForOtpEvent extends LoginEvent{
  final String number;
  const NumberFillingForOtpEvent(this.number);
  @override
  List<Object?>get props=>[number];
}

class SignInButtonEvent extends LoginEvent{}

class OtpFillingEvent extends LoginEvent{
  final String otp;
  const OtpFillingEvent(this.otp);
  @override
  List<Object?>get props=>[otp];
}

class VerifyOtpEvent extends LoginEvent {
  final String otp;

  const VerifyOtpEvent(this.otp);

  @override
  List<Object?> get props => [otp];
}
class ResendOtpEvent extends LoginEvent{}
class StartOtpTimerEvent extends LoginEvent{}
class TimerTickEvent extends LoginEvent{
  final int seconds;
  const TimerTickEvent(this.seconds);
  @override
  List<Object?>get props=>[seconds];
}
class ResetNavigationEvent extends LoginEvent{}
///----------------------------------Sign up------------------
class CreateSignupEvent extends LoginEvent{}

class LoadSignupDataEvent extends LoginEvent{}

class UpdateSignupDataEvent extends LoginEvent{
  final SignUpModal signUpData;
  const UpdateSignupDataEvent(this.signUpData);
  @override
  List<Object?>get props=>[signUpData];
}