import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {
  final int partyId;
  final int page;
  final int size;
  const LoadFeedEvent({
    required this.partyId,
    this.page=0,
    this.size=20,
});
  @override
  List<Object?>get props=>[partyId,page, size];
}

class YearWiseFeedEvent extends FeedEvent {
  final int year;
  const YearWiseFeedEvent(this.year);
  @override
  List<Object?>get props=>[year];
}

class AddNewFeedEvent extends FeedEvent {
  final int partyId;
  final FeedModel feed;
  final List<File>mediaFiles;
  const AddNewFeedEvent({
    required this.partyId,
    required this.feed,
    required this.mediaFiles,
});
  @override
  List<Object?>get props=>[partyId,feed, mediaFiles];
}

class EditFeedEvent extends FeedEvent {
  final int id;
  final int partyId;
  final List<Tagged> tagged;
  final FeedModel feed;
  final List<File>mediaFiles;
  const EditFeedEvent({
    required this.id,
    required this.partyId,
    required this.tagged,
    required this.feed,
    required this.mediaFiles,
});
  @override
  List<Object?> get props=>[id,partyId,feed, tagged, mediaFiles];
}

class DeleteFeedEvent extends FeedEvent {
  final int id;
  final int partyId;

  const DeleteFeedEvent( this.id, this.partyId );
  @override
  List<Object?>get props=>[id,partyId];
}

class UpdateFeedEvent extends FeedEvent {
  final FeedModel feed;
  final List<File> mediaFiles;
  final List<int> deletedMediaIds;
  final int partyId;

  const UpdateFeedEvent({
    required this.feed,
    required this.mediaFiles,
    required this.deletedMediaIds,
    required this.partyId,
  });

  @override
  List<Object?> get props => [
    feed,
    mediaFiles,
    deletedMediaIds,
    partyId,
  ];
}

