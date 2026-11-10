import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_event.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_state.dart';

typedef SearchPeopleFunction =
Future<List<TaggingPersonModel>> Function(String query);

class TaggingPeopleBloc
    extends Bloc<TaggingPeopleEvent, TaggingPeopleState>{
  final SearchPeopleFunction searchPeople;
  int _searchRequestId = 0;
  TaggingPeopleBloc({
    required this.searchPeople,
    List<SelectedTaggingPersonModel> initialSelectedPeople = const [],
}): super (TaggingPeopleState.initial(  selectedPeople: initialSelectedPeople,)){
    on<SearchPeopleEvent>(_searchPeopleHandler);
    on<ClearSearchEvent>(_clearSearch);
    on<TogglePersonSelectionEvent>(_togglePersonSelection);
    on<SaveTaggedPeopleEvent>(_saveTaggedPeople);
    on<ClearTaggingErrorEvent>(_clearError);
  }
  /// Search People with debounce
Future<void>_searchPeopleHandler
    (SearchPeopleEvent event, Emitter<TaggingPeopleState>emit,)
async{
  final query = event.query.trim();
  final requestId = ++_searchRequestId;
  if(query.isEmpty){
    emit(
      state.copyWith(
        searchQuery: '',
        searchResults: [],
        isSearching: false,
        clearError: true,
      )
    );
    return;
  }
  emit(
    state.copyWith(
      searchQuery: event.query,
      searchResults: [],
      isSearching: true,
      clearError: true,
    )
  );
  if(emit.isDone || requestId!=_searchRequestId)return;
  try{
    final List<TaggingPersonModel> result = await searchPeople(query);
    if(emit.isDone || requestId!=_searchRequestId)return;
    emit(
      state.copyWith(
        searchResults: result,
        isSearching: false,
        clearError: true,
      )
    );
  }
  catch(e){
if(emit.isDone || requestId!=_searchRequestId)return;
emit(
  state.copyWith(
    searchResults:[],
    isSearching: false,
    errorMessage: e.toString(),
  )
);
  }
}
void _clearSearch(ClearSearchEvent event, Emitter<TaggingPeopleState>emit){
    _searchRequestId++;
    emit(
      state.copyWith(
      searchQuery: '',
      searchResults: [],
      isSearching: false,
      clearError: true,
      )
    );
}
void _togglePersonSelection(TogglePersonSelectionEvent event,
    Emitter<TaggingPeopleState>emit,
    ){
    final updated = List<SelectedTaggingPersonModel>.from(
      state.selectedPeople,
    );
    final index= updated.indexWhere(
        (person)=>person.politicianId==event.person.politicianId,
    );
    if(index!=-1){
      updated.removeAt(index);
    }
    else{
      updated.add(
        SelectedTaggingPersonModel.fromPerson(event.person),
      );
    }
    emit(
     state.copyWith(
       selectedPeople: updated,
     )
    );
}
///------------Save selected people
  void _saveTaggedPeople(
      SaveTaggedPeopleEvent event,
      Emitter<TaggingPeopleState> emit,
      ) {
    if (state.selectedPeople.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please select at least one person.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        saveCompleted: true,
        clearError: true,
      ),
    );
  }
void _clearError(
    ClearTaggingErrorEvent event,
    Emitter<TaggingPeopleState>emit,
    ){
    emit(
      state.copyWith(
        clearError: true,
      )
    );
}
}