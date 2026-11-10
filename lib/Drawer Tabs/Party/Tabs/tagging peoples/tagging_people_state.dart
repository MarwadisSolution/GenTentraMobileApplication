import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_modal.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_modal.dart';

class TaggingPeopleState extends Equatable{
  final String searchQuery;
  final List<TaggingPersonModel>searchResults;
  final List<SelectedTaggingPersonModel>selectedPeople;
  final bool isSearching;
  final bool isSaving;
  final bool saveCompleted;
  final String? errorMessage;
  const TaggingPeopleState({
    this.searchQuery='',
    this.searchResults=const [],
    this.selectedPeople = const [],
    this.isSearching = false,
    this.isSaving = false,
    this.saveCompleted = false,
    this.errorMessage,
});
  factory TaggingPeopleState.initial({
    List<SelectedTaggingPersonModel> selectedPeople = const [],
  }) {
    return TaggingPeopleState(
      selectedPeople: selectedPeople,
    );
  }
  TaggingPeopleState copyWith({
    String? searchQuery,
    List<TaggingPersonModel>? searchResults,
    List<SelectedTaggingPersonModel>? selectedPeople,
    bool? isSearching,
    bool? isSaving,
    bool? saveCompleted,
    String? errorMessage,
    bool clearError = false,
  }){
    return TaggingPeopleState(
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      selectedPeople: selectedPeople ?? this.selectedPeople,
      isSearching: isSearching ?? this.isSearching,
      isSaving: isSaving ?? this.isSaving,
      saveCompleted: saveCompleted ?? this.saveCompleted,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
  @override
  List<Object?> get props => [
    searchQuery,
    searchResults,
    selectedPeople,
    isSearching,
    isSaving,
    saveCompleted,
    errorMessage,
  ];
}