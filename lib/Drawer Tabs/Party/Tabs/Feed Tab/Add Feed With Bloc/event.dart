// import 'dart:io';
//
// import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
// import 'package:image_picker/image_picker.dart';
//
// abstract class FeedEvent{}
//  //1.----------Add new Feed
// class AddNewFeedEvent extends FeedEvent{
//   final FeedModel feed;
//   final List<File>mediaFiles;
//   final int partyId;
//
//   AddNewFeedEvent({
//     required this.feed,
//     required this.mediaFiles,
//     required this.partyId,
// });
// }
// //2.----------------Update Feed
// class UpdateFeedEvent extends FeedEvent{
//   final FeedModel feed;
//   final List<File>mediaFiles;
//   final List<int>deletedMediaFiles;
//   final int partyId;
//
//   UpdateFeedEvent({
//     required this.feed,
//     required this.mediaFiles,
//     required this.deletedMediaFiles,
//     required this.partyId,
// });
// }
// //3.------------Add remove media
// class AddRemoveMediaEvent extends FeedEvent{
//   final List<XFile>selectedImages;
//   final List<XFile>selectedVideos;
//   AddRemoveMediaEvent({
//     required this.selectedImages,
//     required this.selectedVideos,
// });
// }
//
// // //4. Add or remove tagged peoples
// // class AddRemoveTaggedPeopleEvent extends FeedEvent{
// //   final List<Tagged>added;
// //   final List<dynamic>removed;
// //   AddRemoveTaggedPeopleEvent({
// //     required this.added,
// //     required this.removed,
// // });
// // }
// //5. Add Quote
// class AddQuoteEvent extends FeedEvent{
//   final String quoteText;
//   final String authorName;
//   final XFile? image;
//   final List<Tagged> taggedPeoples;
//   final int partyId;
//   AddQuoteEvent({
//    required this.quoteText,
//    required this.authorName,
//    required this.image,
//    required this.taggedPeoples,
//    required this.partyId,
// });
// }
// //6.--------------Update Quote
// class UpdateQuoteEvent extends FeedEvent{
//   final int feedId;
//   final String quoteText;
//   final String authorName;
//   final XFile? image;
//   final List<Tagged>taggedPeople;
//   final List<int>deletedMediaIds;
//   final int partyId;
//   UpdateQuoteEvent({
//     required this.feedId,
//     required this.quoteText,
//     required this.authorName,
//      this.image,
//     required this.taggedPeople,
//     required this.deletedMediaIds,
//     required this.partyId,
// });
// }
// //7. ------------------Delete Existing media
// class DeleteExistingMediaEvent extends FeedEvent{
//   final bool isVideo;
//   final int index;
//   final int? mediaId;
//   DeleteExistingMediaEvent({
//     required this.isVideo,
//     required this.index,
//      this.mediaId,
// });
//
// }
// //8.------------Add tagged peoples
// class AddTaggedPeopleEvent extends FeedEvent{
// final List<Tagged>people;
// AddTaggedPeopleEvent({
//   required this.people,
// });
// }
//
// //9.------------------Remove Tagged Peoples
// class RemoveTaggedPeopleEvent extends FeedEvent{
//   final List<int>personIds;
//   RemoveTaggedPeopleEvent({
//    required this.personIds,
// });
// }
// //10---------------Schedule feed
// class ScheduleFeedEvent extends FeedEvent{
//   final DateTime scheduleAt;
//   ScheduleFeedEvent({
//     required this.scheduleAt,
// });
// }
//
