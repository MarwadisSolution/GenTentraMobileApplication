import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {
  final int page;
  final int size;
  const LoadFeedEvent({
    this.page=0,
    this.size=20,
});
  @override
  List<Object?>get props=>[page, size];
}

class YearWiseFeedEvent extends FeedEvent {
  final int year;
  const YearWiseFeedEvent(this.year);
  @override
  List<Object?>get props=>[year];
}

class AddNewFeedEvent extends FeedEvent {
  final FeedModel feed;
  final List<File>mediaFiles;
  const AddNewFeedEvent({
    required this.feed,
    required this.mediaFiles,
});
  @override
  List<Object?>get props=>[feed, mediaFiles];
}

class EditFeedEvent extends FeedEvent {
  final int id;
  final FeedModel feed;
  final List<File>mediaFiles;
  const EditFeedEvent({
    required this.id,
    required this.feed,
    required this.mediaFiles,
});
  @override
  List<Object?> get props=>[id, feed, mediaFiles];
}

class DeleteFeedEvent extends FeedEvent {
  final int id;
  const DeleteFeedEvent(this.id);
  @override
  List<Object?>get props=>[id];
}

