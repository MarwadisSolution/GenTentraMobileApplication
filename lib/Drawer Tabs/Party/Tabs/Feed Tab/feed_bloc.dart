import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_event.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_state.dart';

import 'apis.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState>{
  final FeedApis api;
  FeedBloc(this.api):super( FeedState.initial()){
    on<LoadFeedEvent> (_loadFeed);
    on<AddNewFeedEvent>(_addNewFeed);
    on<YearWiseFeedEvent>(_yearWiseFeed);
    on<DeleteFeedEvent>(_deleteFeed);
  }
  Future<void>_loadFeed(
      LoadFeedEvent event,
      Emitter<FeedState>emit,
      )async{
    emit(state.copyWith(
      isLoading: true,
      isError: false,
    ));
    try{
      final feed=await api.getFeeds(
        page: event.page,
        size: event.size,
      );
      emit(
        state.copyWith(
          isLoading: false,
          feeds: feed,
        )
      );
    }
    catch(e){
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }
  Future<void>_addNewFeed(
AddNewFeedEvent event,
Emitter<FeedState>emit,
      )async{
    emit(state.copyWith(isPosting: true));
    try{
      await api.postTheFeed(feed: event.feed,
          mediaFiles: event.mediaFiles,
      );
      final feed=await api.getFeeds();
      emit(state.copyWith(
        isPosting: true,
        feeds: feed,
      ));
    }
    catch(e){
      emit(state.copyWith(
        isPosting: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }
  void _yearWiseFeed(
      YearWiseFeedEvent event,
      Emitter<FeedState>emit,
      ){
    emit(state.copyWith(selectYearFeed: event.year));
  }
  void _deleteFeed(
      DeleteFeedEvent event,
      Emitter<FeedState>emit,
      )async{
    ///-----------------Delete Api call karna hai
  }
}