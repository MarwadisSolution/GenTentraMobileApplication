import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Login%20Page/Login%20Bloc/login_modal.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final bool isVerifyingOtp;
  final bool isError;
  final String errorMessage;

  final bool navigateToOtp;
  final bool navigateToNewUser;
  final bool navigateToOldUser;

  final String phoneNumber;
  final String otp;
  final String verificationToken;
  final int resendTimer;
  final bool canResendOtp;
  final bool isSuccess;

  final SignUpModal signUpData;
  final String firstName;
  final String lastName;
  final String gender;
  final String area;
  final String city;
  final String state;
  final String country;

  const LoginState({
    this.isLoading = false,
    this.isVerifyingOtp=false,
    this.isError = false,
    this.errorMessage = '',
    this.navigateToOtp=false,
    this.navigateToNewUser=false,
    this.navigateToOldUser=false,
    this.phoneNumber = '',
    this.otp = '',
    this.verificationToken='',
    this.resendTimer=60,
    this.canResendOtp=false,
this.isSuccess=false,
    this.signUpData=const SignUpModal(),
    this.firstName = '',
    this.lastName = '',
    this.gender = '',
    this.area = '',
    this.city = '',
    this.state = '',
    this.country = '',
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isVerifyingOtp,
    bool? isError,
    String? errorMessage,
    bool? navigateToOtp,
    bool? navigateToNewUser,
    bool? navigateToOldUser,
    String? phoneNumber,
    String? otp,
    String? verificationToken,
    int? resendTimer,
    bool? canResendOtp,
bool?isSuccess,
    SignUpModal? signUpData,
    String? firstName,
    String? lastName,
    String? gender,
    String? area,
    String? city,
    String? state,
    String? country,

  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      navigateToOtp: navigateToOtp ?? this.navigateToOtp,
      navigateToNewUser: navigateToNewUser ?? this.navigateToNewUser,
      navigateToOldUser: navigateToOldUser ?? this.navigateToOldUser,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      verificationToken: verificationToken ?? this.verificationToken,
      resendTimer: resendTimer ?? this.resendTimer,
      canResendOtp: canResendOtp ?? this.canResendOtp,
      isSuccess: isSuccess ?? this.isSuccess,
      signUpData: signUpData??this.signUpData,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isError,
    isVerifyingOtp,
    errorMessage,
    navigateToOtp,
    navigateToNewUser,
    navigateToOldUser,
    phoneNumber,
    otp,
    verificationToken,
    resendTimer,
    canResendOtp,
    isSuccess,
    signUpData,
    firstName,
    lastName,
    gender,
    area,
    city,
    state,
    country,
  ];
}
