import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_modal.dart';

abstract class EventsEvent{}
//1. Add new event
class AddNewEvent extends EventsEvent{
  final EventModel eventData;
  final List<File>mediaFiles;
  final File? bgImage;
  final int partyId;

  AddNewEvent({
    required this.eventData,
    required this.mediaFiles,
    this.bgImage,
    required this.partyId,
});
}
//2.  Edit Event
class EditEvent extends EventsEvent{
  final EventModel eventData;
  final List<File>mediaFiles;
  final File? bgImage;
  final int partyId;

  EditEvent({
    required this.eventData,
    required this.mediaFiles,
    this.bgImage,
    required this.partyId,
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

  GetEventEvent(this.partyId);
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
class RemoveTaggedPeopleEvent extends EventsEvent{
  final int index;
  RemoveTaggedPeopleEvent(this.index);
}

class BackgroundImageFileEvent extends EventsEvent {
  final File image;

  BackgroundImageFileEvent(this.image);
}
class RemoveBackgroundImageEvent extends EventsEvent {}
