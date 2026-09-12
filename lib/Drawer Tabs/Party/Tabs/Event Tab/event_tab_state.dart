import 'dart:io';

import 'package:flutter/material.dart';

import 'event_modal.dart' show Tagged, EventModel;

enum EventStatus{
  initial,loading, success, error,
}

 class EventTabState {


final EventStatus status;
final EventModel? event;
final List<EventModel> events;
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
final int currentPage;
final int pageSize;
final int totalItems;
final int totalPages;
final bool hasMore;
final bool isLoadingMore;
final bool isErrorInJoining;
final bool isSuccessInJoining;
final String? joiningActionMessage;
final int? joiningEventId;
 const EventTabState({
  this.status=EventStatus.initial,
   this.event,
   this.events = const [],
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
   this.currentPage = 0,
   this.pageSize = 20,
   this.totalItems = 0,
   this.totalPages = 0,
   this.hasMore = false,
   this.isLoadingMore = false,
   this.isErrorInJoining=false,
   this.isSuccessInJoining=false,
   this.joiningActionMessage,
   this.joiningEventId,
 });

 EventTabState copyWith({
  EventStatus? status,
   EventModel? event,
   List<EventModel>? events,
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

   int? currentPage,
   int? pageSize,
   int? totalItems,
   int? totalPages,
   bool? hasMore,
   bool? isLoadingMore,
   bool?isErrorInJoining,
   bool?isSuccessInJoining,
   String? joiningActionMessage,
   int? joiningEventId,
   bool clearJoiningEventId = false,
 }){
   return EventTabState(
     status: status ?? this.status,
     event: event ?? this.event,
     events: events ?? this.events,
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

     currentPage:
     currentPage ?? this.currentPage,

     pageSize:
     pageSize ?? this.pageSize,

     totalItems:
     totalItems ?? this.totalItems,

     totalPages:
     totalPages ?? this.totalPages,

     hasMore:
     hasMore ?? this.hasMore,

     isLoadingMore:
     isLoadingMore ?? this.isLoadingMore,
     isErrorInJoining: isErrorInJoining??this.isErrorInJoining,
     isSuccessInJoining: isSuccessInJoining??this.isSuccessInJoining,
     joiningActionMessage:
     joiningActionMessage ?? this.joiningActionMessage,
     joiningEventId: clearJoiningEventId
         ? null
         : joiningEventId ?? this.joiningEventId,
   );
 }
}

