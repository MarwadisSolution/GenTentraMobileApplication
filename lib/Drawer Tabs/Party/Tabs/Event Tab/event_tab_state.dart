import 'dart:io';

import 'package:flutter/material.dart';

import 'event_modal.dart' show Tagged, EventModel;

enum EventStatus{
  initial,loading, success, error,
}

 class EventTabState {
final EventStatus status;
final EventModel? event;
final int selectedTab;
final DateTime? fromDate;
final DateTime? toDate;
final TimeOfDay? fromTime;
final TimeOfDay?toTime;

final String address;
final String locationLink;

final List<File>images;
final bool displayJoiningButton;
final bool hasBackgroundImage;
final File? bgImage;
final List<Tagged> taggedPeople;
final String? errorMessage;

 const EventTabState({
  this.status=EventStatus.initial,
   this.event,
   this.selectedTab=0,
   this.fromDate,
   this.toDate,
   this.fromTime,
   this.toTime,
   this.address="",
   this.locationLink="",
   this.images=const [],
   this.displayJoiningButton = false,
   this.hasBackgroundImage=false,
   this.bgImage,
   this.taggedPeople = const [],
   this.errorMessage,
 });

 EventTabState copyWith({
  EventStatus? status,
   EventModel? event,
   int? selectedTab,
   DateTime? fromDate,
   DateTime? toDate,
   TimeOfDay? fromTime,
   TimeOfDay? toTime,
   String? address,
   String? locationLink,
   List<File>? images,
   bool? displayJoiningButton,
   File? bgImage,
    bool? hasBackgroundImage,
   List<Tagged>? taggedPeople,
   String? errorMessage,
 }){
   return EventTabState(
     status: status ?? this.status,
     event: event ?? this.event,
     selectedTab: selectedTab ?? this.selectedTab,

     fromDate: fromDate ?? this.fromDate,
     toDate: toDate ?? this.toDate,

     fromTime: fromTime ?? this.fromTime,
     toTime: toTime ?? this.toTime,

     address: address ?? this.address,
     locationLink: locationLink ?? this.locationLink,

     images: images ?? this.images,

     displayJoiningButton:
     displayJoiningButton ?? this.displayJoiningButton,
     hasBackgroundImage:
     hasBackgroundImage ?? this.hasBackgroundImage,
     bgImage: bgImage ?? this.bgImage,
     taggedPeople:
     taggedPeople ?? this.taggedPeople,

     errorMessage:
     errorMessage ?? this.errorMessage,
   );
 }
}

