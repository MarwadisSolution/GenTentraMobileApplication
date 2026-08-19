import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';

class FeedState extends Equatable{
  final bool isLoading;
  final bool isError;
  final bool isPosting;
  final bool isPostSuccess;
  final bool isOfflineQueued;
  final String errorMessage;
  final int selectYearFeed;
  final List<FeedModel> feeds;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  const FeedState({
    this.isLoading=true,
    this.isError=false,
    this.isPosting=false,
    this.isPostSuccess = false,
    this.isOfflineQueued=false,
    this.errorMessage='',
    this.selectYearFeed=2026,
     this.feeds=const[],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
});
  FeedState copyWith({
    bool? isLoading,
    bool? isError,
     bool? isPosting,
    bool? isPostSuccess,
    bool? isOfflineQueued,
    String? errorMessage,
    int? selectYearFeed,
    List<FeedModel>? feeds,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
}){
    return FeedState(
      isLoading: isLoading??this.isLoading,
      isError: isError??this.isError,
      isPosting: isPosting??this.isPosting,
      isPostSuccess: isPostSuccess ?? this.isPostSuccess,
      isOfflineQueued: isOfflineQueued ?? this.isOfflineQueued,
      errorMessage: errorMessage??this.errorMessage,
      selectYearFeed: selectYearFeed??this.selectYearFeed,
      feeds: feeds??this.feeds,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
        isOfflineQueued,
        errorMessage,
        selectYearFeed,
        feeds,
        currentPage,
        hasMore,
        isLoadingMore,
      ];
}