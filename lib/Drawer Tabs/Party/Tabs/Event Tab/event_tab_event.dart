import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_modal.dart';

abstract class EventsEvent{}
//1. Add new event
class AddNewEvent extends EventsEvent{
  final EventModel eventData;
  final List<File>mediaFiles;
  final File? bgImageUrl;
  final bool? bgImage;
  final int partyId;

  AddNewEvent({
    required this.eventData,
    required this.mediaFiles,
    this.bgImageUrl,
    this.bgImage,
    required this.partyId,
});
}
//2.  Edit Event
class EditEvent extends EventsEvent {
  final EventModel eventData;
  final List<File> mediaFiles;
  final File? bgImageUrl;
  final bool?bgImage;
  final int partyId;

  final List<int> deletedMediaIds;

  // NEW
  final List<Tagged> removeTags;
  final bool removeBackgroundImage;
  EditEvent({
    required this.eventData,
    required this.mediaFiles,
    this.bgImageUrl,
    this.bgImage,
    required this.partyId,
    this.deletedMediaIds = const [],

    // NEW
    this.removeTags = const [],
    this.removeBackgroundImage = false,
  });
}
//3. Delete Event
class DeleteEvent extends EventsEvent{
  final int eventId;
  DeleteEvent(this.eventId);
}
//13. Get Event
class GetEventEvent extends EventsEvent {
  final int partyId;
  final int page;
  final int size;

  GetEventEvent({
    required this.partyId,
    this.page = 0,
    this.size = 20,
  });
}

//4. ------------tabs (private, public, selective)
class ChangeTabEvent extends EventsEvent{
  final int tabEvent;
  ChangeTabEvent(this.tabEvent);
}
//5. -------From date to to date
class DateEvent extends EventsEvent{
  final DateTime fromDate;
  final DateTime toDate;
  DateEvent(this.fromDate, this.toDate);
}
//6. -----Time From to to
class TimeEvent extends EventsEvent{
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  TimeEvent(this.fromTime, this.toTime);
}
//7. Address
class AddressEvent extends EventsEvent{
  final String address;
  final String locationLink;
  AddressEvent(this.address, this.locationLink);
}

//8.  Add Image
class AddImageEvent extends EventsEvent{
  final List<File>images;
  AddImageEvent(this.images);
}
//12 Remove Image
class RemoveImageEvent extends EventsEvent{
  final int index;
  RemoveImageEvent(this.index);
}

//9. Joining button
class JoiningButtonEvent extends EventsEvent{
  final bool displayJoiningButton;
  JoiningButtonEvent(this.displayJoiningButton);
}
//10 Background Image
class BackgroundImageEvent extends EventsEvent {
  final bool hasBackgroundImage;

  BackgroundImageEvent(this.hasBackgroundImage);
}

//11 Tagged Peoples
class TaggedPeopleEvent extends EventsEvent{
  final List<Tagged>taggedPeople;
  TaggedPeopleEvent(this.taggedPeople);
}
//12 Remove tagged person
class RemovedTaggedPeopleEvent extends EventsEvent {
  final List<Tagged> removedTags;

  RemovedTaggedPeopleEvent(this.removedTags);
}

class BackgroundImageFileEvent extends EventsEvent {
  final File image;

  BackgroundImageFileEvent(this.image);
}
class RemoveBackgroundImageEvent extends EventsEvent {}

class joinUnJoinButtonEvent extends EventsEvent{
  final int eventId;
  joinUnJoinButtonEvent({
    required this.eventId,
  });
  @override
  List<Object?>get props=>[
    eventId,
  ];
}
class ResetEventForm extends EventsEvent {}


// ============================================================
// ATTENDANCE
// ============================================================

// ============================================================
// GET ATTENDANCE PAGE
// ============================================================

class GetAttendanceEvent extends EventsEvent {
  final int eventId;
  final int page;
  final int size;

  GetAttendanceEvent({
    required this.eventId,
    this.page = 0,
    this.size = 20,
  });
}


// ============================================================
// LOCAL SEARCH ATTENDANCE
// ============================================================

class SearchAttendanceEvent extends EventsEvent {
  final int eventId;
  final String search;

  SearchAttendanceEvent({
    required this.eventId,
    required this.search,
  });
}

class InitializeEditEvent extends EventsEvent {
  final EventModel event;

  InitializeEditEvent(this.event);
}
class RemoveExistingMediaEvent extends EventsEvent {
  final int index;

  RemoveExistingMediaEvent(this.index);
}

class ClearJoinMessageEvent extends EventsEvent {}
class ClearDeleteMessageEvent extends EventsEvent {}