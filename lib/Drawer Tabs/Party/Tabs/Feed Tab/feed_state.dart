import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';

class FeedState extends Equatable{
  final bool isLoading;
  final bool isError;
  final bool isPosting;
  final bool isPostSuccess;
  final String errorMessage;
  final int selectYearFeed;
  final List<FeedModel> feeds;
  const FeedState({
    this.isLoading=true,
    this.isError=false,
    this.isPosting=false,
    this.isPostSuccess = false,
    this.errorMessage='',
    this.selectYearFeed=2026,
     this.feeds=const[],
});
  FeedState copyWith({
    bool? isLoading,
    bool? isError,
     bool? isPosting,
    bool? isPostSuccess,
    String? errorMessage,
    int? selectYearFeed,
    List<FeedModel>? feeds,
}){
    return FeedState(
      isLoading: isLoading??this.isLoading,
      isError: isError??this.isError,
      isPosting: isPosting??this.isPosting,
      isPostSuccess: isPostSuccess ?? this.isPostSuccess,
      errorMessage: errorMessage??this.errorMessage,
      selectYearFeed: selectYearFeed??this.selectYearFeed,
      feeds: feeds??this.feeds,
    );
  }
  factory FeedState.initial()=> FeedState();
  @override
  List<Object?>get props=>
      [
        isLoading,
        isError,
        isPosting,
        isPostSuccess,
        errorMessage,
        selectYearFeed,
        feeds,
      ];
}