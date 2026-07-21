import '../../Reusable Functions/reusable_functions.dart';
import '../login_apis.dart';

class OtpVerificationResponse {
final bool isNewUser;
final bool requirePassword;
final String verificationToken;

    OtpVerificationResponse({
  required this.isNewUser,
      required this.requirePassword,
      required this.verificationToken,

});

factory OtpVerificationResponse.fromJson(
    Map<String, dynamic> json,
    ) {
  return OtpVerificationResponse(
    isNewUser: json["isNewUser"] ?? false,
    requirePassword: json["requirePassword"] ?? false,
    verificationToken: json["verificationToken"] ?? "",
  );
}
}
class LoginRepository {

  final LoginApi loginApi;

  LoginRepository(this.loginApi);
///------Remove temporary Saving otp as till now we have not taken message system so using it
  Future<void> sendOtp(String number) async {

     temporarySavingOtp= await loginApi.otpRequest(number);

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
final String coverUrl;
final String area;
final String city;
final String state;
final String country;

const SignUpModal({
this.firstName='',
  this.surname='',
  this.gender='',
  this.coverUrl='',
  this.area='',
  this.city='',
  this.state='',
  this.country='',
});
SignUpModal copyWith({
  String? firstName,
  String? surname,
  String?gender,
 String? coverUrl,
  String?area,
  String?city,
  String? state,
  String? country,

}){
  return SignUpModal(
    firstName: firstName??this.firstName,
surname: surname??this.surname,
    gender: gender??this.gender,
    coverUrl: coverUrl??this.coverUrl,
    area: area??this.area,
    city: city??this.city,
    state: state??this.state,
    country: country??this.country,
  );
}
factory SignUpModal.fromJson(Map<String, dynamic>json){
  return SignUpModal(
firstName: json['firstName']??'',
    surname: json['surname']??'',
    gender: json['gender']??'',
    coverUrl: json['coverUrl']??'',
    area: json['area']??'',
    city: json['city']??'',
    state: json['state']??'',
    country: json['country']??'',
  );
}
Map<String, dynamic>toJson(){
  return {
    'firstName':firstName,
    'surname':surname,
    'gender':gender,
    'coverUrl':coverUrl,
    'area':area,
    'city':city,
    'state':state,
    'country':country,
  };
}
}