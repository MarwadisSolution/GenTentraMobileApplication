import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';

abstract class PartyEvent {}
class FetchPartiesEvent extends PartyEvent{
  final bool loadMore;
  FetchPartiesEvent({this.loadMore=false});
}
///---------------State
abstract class PartyState{}
class PartyInitial extends PartyState{}
class PartyLoading extends PartyState{}
class PartyLoaded extends PartyState{
  final List<dynamic> parties;
  final bool hasMore;
  final bool isLoadingMore;
  PartyLoaded({
    required this.parties, required this.hasMore,
    this.isLoadingMore=false,
});
}
class PartyError extends PartyState{
  final String message;
  PartyError(this.message);
}
///------------Bloc
class PartyBloc extends Bloc<PartyEvent, PartyState>{
 final PartyPageApis apiService;
 int currentPage=0;
 final int pageSize=20;
 bool hasMore=true;
 bool isFetching=false;
 List<dynamic>parties=[];

 PartyBloc(this.apiService):super(PartyInitial()){
   on<FetchPartiesEvent>(_fetchParties);
 }
 Future<void>_fetchParties(
     FetchPartiesEvent event, Emitter<PartyState>emit,
     )async{
   if(isFetching) return;
   if(event.loadMore && !hasMore)return;
   if(!event.loadMore){
     currentPage=0; hasMore=true; parties=[];
     emit(PartyLoading());
   }else{
     if(state is! PartyLoaded) return;
     emit(
       PartyLoaded(parties: parties,
           hasMore: hasMore,isLoadingMore: true,)

     );
   }
   isFetching=true;
   try{
     final newParties=await apiService.fetchPartiesAlreadyFormed(
         page: currentPage,
         size: pageSize,
     );
     if(newParties.isEmpty){
       hasMore=false;
     }
     else{
       parties=[...parties,...newParties];
       currentPage++;
       if(newParties.length<pageSize)
         {
           hasMore=false;
         }
     }
     emit(
       PartyLoaded(parties: parties,
           hasMore: hasMore,
       isLoadingMore: false,
       )
     );
   }
   catch(e){
    if(parties.isNotEmpty){
      emit(PartyLoaded(parties: parties,
          hasMore: hasMore,
         isLoadingMore: false,
      )
      );
    }
    else{
      emit(PartyError(e.toString()));
    }
   }
   finally{
     isFetching=false;
   }
 }
}