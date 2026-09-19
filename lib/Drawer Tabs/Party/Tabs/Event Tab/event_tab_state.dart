import 'dart:io';

import 'package:flutter/material.dart';

import 'event_modal.dart' show Tagged, EventModel, AttendeePreview, MediaModel;

enum EventStatus{
  initial,loading, success, error,
}

 class EventTabState {

   static const Object _unset = Object();

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
final File? bgImageUrl;
final bool? bgImage;
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
   final bool isEventCreated;
   final bool isEventDeleted;
   ///--------------Attendence
   final List<AttendeePreview> allAttendees;
   final List<AttendeePreview> attendees;

   final int attendanceCurrentPage;
   final int attendancePageSize;
   final int attendanceTotalItems;
   final int attendanceTotalPages;

   final bool attendanceHasMore;
   final bool isLoadingAttendance;
   final bool isLoadingMoreAttendance;

   final bool isSearchingAttendance;
   final String attendanceSearch;
   final String? attendanceError;


   final String? existingBgImage;
   final List<MediaModel> existingMedia;
   final List<int> deletedMediaIds;
   final bool isEventUpdated;
   final List<Tagged> removeTags;
   final bool removeBackgroundImage;
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
   this.bgImageUrl,
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
   this.isEventCreated = false,
   this.isEventDeleted = false,
   // ==========================================================
   // ATTENDANCE
   // ==========================================================
   this.allAttendees = const [],
   this.attendees = const [],

   this.attendanceCurrentPage = 0,
   this.attendancePageSize = 20,
   this.attendanceTotalItems = 0,
   this.attendanceTotalPages = 0,

   this.attendanceHasMore = false,
   this.isLoadingAttendance = false,
   this.isLoadingMoreAttendance = false,

   this.isSearchingAttendance = false,
   this.attendanceSearch = '',
   this.attendanceError,
   this.existingBgImage,
   this.existingMedia = const [],
   this.deletedMediaIds = const [],
   this.isEventUpdated = false,
   this.removeTags = const [],
   this.removeBackgroundImage = false,
 });

EventTabState copyWith({
  EventStatus? status,
  EventModel? event,
  List<EventModel>? events,
  int? selectedTab,

  Object? fromDate = _unset,
  Object? toDate = _unset,
  Object? fromTime = _unset,
  Object? toTime = _unset,

  String? address,
  String? locationLink,
  List<File>? images,
  bool? displayJoiningButton,

  bool? hasBackgroundImage,

  Object? bgImageUrl = _unset,

  List<Tagged>? taggedPeople,
  String? errorMessage,

  int? currentPage,
  int? pageSize,
  int? totalItems,
  int? totalPages,
  bool? hasMore,
  bool? isLoadingMore,

  bool? isErrorInJoining,
  bool? isSuccessInJoining,
  String? joiningActionMessage,
  int? joiningEventId,

  bool clearJoiningEventId = false,

  bool? isEventCreated,
  bool? isEventDeleted,
  List<AttendeePreview>? allAttendees,
  List<AttendeePreview>? attendees,

  int? attendanceCurrentPage,
  int? attendancePageSize,
  int? attendanceTotalItems,
  int? attendanceTotalPages,

  bool? attendanceHasMore,
  bool? isLoadingAttendance,
  bool? isLoadingMoreAttendance,

  bool? isSearchingAttendance,
  String? attendanceSearch,
  String? attendanceError,

  Object? existingBgImage = _unset,
  List<MediaModel>? existingMedia,
  List<int>? deletedMediaIds,
  bool? isEventUpdated,
  List<Tagged>? removeTags,
  bool? removeBackgroundImage,

}) {
  return EventTabState(
    status: status ?? this.status,
    event: event ?? this.event,
    events: events ?? this.events,

    selectedTab: selectedTab ?? this.selectedTab,

    fromDate: identical(fromDate, _unset)
        ? this.fromDate
        : fromDate as DateTime?,

    toDate: identical(toDate, _unset)
        ? this.toDate
        : toDate as DateTime?,

    fromTime: identical(fromTime, _unset)
        ? this.fromTime
        : fromTime as TimeOfDay?,

    toTime: identical(toTime, _unset)
        ? this.toTime
        : toTime as TimeOfDay?,

    address: address ?? this.address,
    locationLink: locationLink ?? this.locationLink,

    images: images ?? this.images,

    displayJoiningButton:
    displayJoiningButton ?? this.displayJoiningButton,

    hasBackgroundImage:
    hasBackgroundImage ?? this.hasBackgroundImage,

    bgImageUrl: identical(bgImageUrl, _unset)
        ? this.bgImageUrl
        : bgImageUrl as File?,
   bgImage: bgImage??this.bgImage,
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

    isErrorInJoining:
    isErrorInJoining ?? this.isErrorInJoining,

    isSuccessInJoining:
    isSuccessInJoining ?? this.isSuccessInJoining,

    joiningActionMessage:
    joiningActionMessage ?? this.joiningActionMessage,

    joiningEventId:
    clearJoiningEventId
        ? null
        : joiningEventId ?? this.joiningEventId,

    isEventCreated:
    isEventCreated ?? this.isEventCreated,
    isEventDeleted:
    isEventDeleted ?? this.isEventDeleted,
    allAttendees:
    allAttendees ?? this.allAttendees,

    attendees:
    attendees ?? this.attendees,

    attendanceCurrentPage:
    attendanceCurrentPage ?? this.attendanceCurrentPage,

    attendancePageSize:
    attendancePageSize ?? this.attendancePageSize,

    attendanceTotalItems:
    attendanceTotalItems ?? this.attendanceTotalItems,

    attendanceTotalPages:
    attendanceTotalPages ?? this.attendanceTotalPages,

    attendanceHasMore:
    attendanceHasMore ?? this.attendanceHasMore,

    isLoadingAttendance:
    isLoadingAttendance ?? this.isLoadingAttendance,

    isLoadingMoreAttendance:
    isLoadingMoreAttendance ??
        this.isLoadingMoreAttendance,

    isSearchingAttendance:
    isSearchingAttendance ??
        this.isSearchingAttendance,

    attendanceSearch:
    attendanceSearch ?? this.attendanceSearch,

    attendanceError:
    attendanceError ?? this.attendanceError,

    existingBgImage: identical(existingBgImage, _unset)
        ? this.existingBgImage
        : existingBgImage as String?,

    existingMedia: existingMedia ?? this.existingMedia,

    deletedMediaIds: deletedMediaIds ?? this.deletedMediaIds,

    isEventUpdated: isEventUpdated ?? this.isEventUpdated,
    removeTags: removeTags ?? this.removeTags,
    removeBackgroundImage:
    removeBackgroundImage ?? this.removeBackgroundImage,
  );
}
}

