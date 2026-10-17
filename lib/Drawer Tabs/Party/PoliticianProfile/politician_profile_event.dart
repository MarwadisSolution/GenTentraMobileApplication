abstract class PoliticianProfileEvent {
  const PoliticianProfileEvent();
}

class FetchPoliticianProfileEvent extends PoliticianProfileEvent {
  final int politicianId;
  const FetchPoliticianProfileEvent(this.politicianId);
}

class RefreshPoliticianProfileEvent extends PoliticianProfileEvent {
  final int politicianId;
  const RefreshPoliticianProfileEvent(this.politicianId);
}
