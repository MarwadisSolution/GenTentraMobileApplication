import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_model.dart';


abstract class TaggingPeopleEvent extends Equatable {
  const TaggingPeopleEvent();

  @override
  List<Object?> get props => [];
}

class SearchPeopleEvent extends TaggingPeopleEvent {
  final String query;

  const SearchPeopleEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends TaggingPeopleEvent {
  const ClearSearchEvent();
}

class TogglePersonSelectionEvent extends TaggingPeopleEvent {
  final TaggingPersonModel person;

  const TogglePersonSelectionEvent(this.person);

  @override
  List<Object?> get props => [person.politicianId];
}

class SaveTaggedPeopleEvent extends TaggingPeopleEvent {
  const SaveTaggedPeopleEvent();
}

class ClearTaggingErrorEvent extends TaggingPeopleEvent {
  const ClearTaggingErrorEvent();
}