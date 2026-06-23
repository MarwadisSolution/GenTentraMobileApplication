import '../login_apis.dart';

class OtpVerificationResponse {
final bool isNewUser;
final String verificationToken;
    OtpVerificationResponse({
  required this.isNewUser,
      required this.verificationToken,
});

    factory OtpVerificationResponse.fromJson(
        Map<String, dynamic>json
        ){
      return OtpVerificationResponse(
          isNewUser: json["isNewUser"],
          verificationToken: json["verificationToken"],
      );
    }
}
class LoginRepository {

  final LoginApi loginApi;

  LoginRepository(this.loginApi);

  Future<void> sendOtp(String number) async {
    await loginApi.otpRequest(number);
  }

  Future<OtpVerificationResponse> verifyOtp(
      String number,
      String otp,
      ) async {

    final response = await loginApi.otpVerify(
      number,
      otp,
    );

    return OtpVerificationResponse.fromJson(
      response,
    );
  }
}
class SignUpModal{
final String firstName;
final String surname;
final String gender;
final String number;
const SignUpModal({
this.firstName='',
  this.surname='',
  this.gender='',
  this.number='',
});
SignUpModal copyWith({
  String? firstName,
  String? surname,
  String?gender,
  String? number,
}){
  return SignUpModal(
    firstName: firstName??this.firstName,
surname: surname??this.surname,
    gender: gender??this.gender,
    number: number??this.number,
  );
}
factory SignUpModal.fromJson(Map<String, dynamic>json){
  return SignUpModal(
firstName: json['firstName']??'',
    surname: json['surname']??'',
    gender: json['gender']??'',
    number: json['number']??'',
  );
}
}