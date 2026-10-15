import 'politician_model.dart';

enum PoliticianProfileStatus { initial, loading, success, failure }

class PoliticianProfileState {
  final PoliticianProfileStatus status;
  final PoliticianModel? politician;
  final String? errorMessage;
  final int? politicianId;

  const PoliticianProfileState({
    this.status = PoliticianProfileStatus.initial,
    this.politician,
    this.errorMessage,
    this.politicianId,
  });

  PoliticianProfileState copyWith({
    PoliticianProfileStatus? status,
    PoliticianModel? politician,
    String? errorMessage,
    int? politicianId,
  }) {
    return PoliticianProfileState(
      status: status ?? this.status,
      politician: politician ?? this.politician,
      errorMessage: errorMessage ?? this.errorMessage,
      politicianId: politicianId ?? this.politicianId,
    );
  }
}
