import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_state.dart';

import 'apis.dart';
import 'event_modal.dart';
import 'event_tab_event.dart';class EventsBloc extends Bloc<EventsEvent, EventTabState> {
  final EventApis api;

  EventsBloc(this.api) : super(const EventTabState()) {
    on<GetEventEvent>(_getEvent);
    on<AddNewEvent>(_addNewEvent);
    on<EditEvent>(_editEvent);
    on<DeleteEvent>(_deleteEvent);
    on<InitializeEditEvent>(_initializeEditEvent);
    on<ChangeTabEvent>(_changeTab);
    on<DateEvent>(_dateEvent);
    on<TimeEvent>(_timeEvent);
    on<AddressEvent>(_addressEvent);

    on<AddImageEvent>(_addImage);
    on<RemoveImageEvent>(_removeImage);

    on<JoiningButtonEvent>(_joiningButton);
    on<BackgroundImageEvent>(_backgroundImage);
    on<RemoveBackgroundImageEvent>(_removeBackgroundImage);
    on<BackgroundImageFileEvent>(_backgroundImageFile);
    on<TaggedPeopleEvent>(_taggedPeople);

    on<joinUnJoinButtonEvent>(_joinUnjoinButton);
    on<ResetEventForm>(_onResetEventForm);

    on<GetAttendanceEvent>(_getAttendance);

    on<SearchAttendanceEvent>(_searchAttendance);
    on<RemovedTaggedPeopleEvent>(_removedTaggedPeople);
    on<RemoveExistingMediaEvent>(_removeExistingMedia);
    on<ClearJoinMessageEvent>(_clearJoinMessage);
  }

  // ==========================================================
  // GET EVENT
  // ==========================================================

  Future<void> _getEvent(
      GetEventEvent event,
      Emitter<EventTabState> emit,
      ) async {
    final bool isFirstPage = event.page == 0;

    // First page
    if (isFirstPage) {
      emit(
        state.copyWith(
          status: EventStatus.loading,
          errorMessage: null,
        ),
      );
    }
    // Next pages
    else {
      emit(
        state.copyWith(
          isLoadingMore: true,
          errorMessage: null,
        ),
      );
    }

    try {
      final response = await api.getTheEvents(
        partyId: event.partyId,
        page: event.page,
        size: event.size,
      );

      final List<EventModel> updatedEvents;

      if (isFirstPage) {
        // First API call
        updatedEvents = response.items;
      } else {
        // Pagination API call
        updatedEvents = [
          ...state.events,
          ...response.items,
        ];
      }

      emit(
        state.copyWith(
          status: EventStatus.success,
          events: updatedEvents,
          currentPage: response.page,
          pageSize: response.size,
          totalItems: response.totalItems,
          totalPages: response.totalPages,
          hasMore: response.hasNext,

          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EventStatus.error,
          errorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  // ==========================================================
  // ADD EVENT
  // ==========================================================

  Future<void> _addNewEvent(
      AddNewEvent event,
      Emitter<EventTabState> emit,
      ) async {

    print("========== ADD NEW EVENT HANDLER HIT ==========");

    print("Event title: ${event.eventData.title}");
    print("Party ID: ${event.partyId}");
    print("Media count: ${event.mediaFiles.length}");
    print("Background image: ${event.bgImage?.path}");

    emit(
      state.copyWith(
        status: EventStatus.loading,
        errorMessage: null,
      ),
    );

    try {

      print("========== CALLING POST EVENT API ==========");

      final createdEvent = await api.postTheEvent(
        event: event.eventData,
        partyId: event.partyId,
        mediaFiles: event.mediaFiles,
        bgImage: event.bgImage,
      );

      print("========== POST EVENT API COMPLETED ==========");

      emit(
        state.copyWith(
          status: EventStatus.success,
          event: createdEvent,
          isEventCreated: true,
        ),
      );

// Reset the Add Event form after successful creation.
      add(ResetEventForm());
    } catch (e) {

      print("========== ADD EVENT ERROR ==========");
      print(e);

      emit(
        state.copyWith(
          status: EventStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // EDIT EVENT
  // ==========================================================

  Future<void> _editEvent(
      EditEvent event,
      Emitter<EventTabState> emit,
      ) async {

    emit(
      state.copyWith(
        status: EventStatus.loading,
        errorMessage: null,
        isEventUpdated: false,
      ),
    );

    try {
      print("========== EDIT EVENT HANDLER HIT ==========");
      print("Event ID: ${event.eventData.id}");
      print("Party ID: ${event.partyId}");
      print("New media count: ${event.mediaFiles.length}");
      print("New BG image: ${event.bgImage?.path}");
      print("Deleted media IDs: ${event.deletedMediaIds}");

      // ----------------------------------------------------------
      // EVENT ID CHECK
      // ----------------------------------------------------------

      final int? eventId = event.eventData.id;

      if (eventId == null) {
        throw Exception("Event ID is missing");
      }

      // ----------------------------------------------------------
      // CALL UPDATE API
      // ----------------------------------------------------------
      print("Remove tags: ${event.removeTags.map((tag) => tag.toJson()).toList()}");

      final updatedEvent = await api.updateTheEvent(
        eventId: eventId,
        event: event.eventData,
        mediaFiles: event.mediaFiles,
        bgImage: event.bgImage,
        deletedMediaIds: event.deletedMediaIds,
        removeTags: event.removeTags,
        removeBackgroundImage: event.removeBackgroundImage,
      );
      print("========== EVENT UPDATED SUCCESSFULLY ==========");

      // ----------------------------------------------------------
      // UPDATE EVENT IN LOCAL LIST
      // ----------------------------------------------------------

      final updatedEvents =
      List<EventModel>.from(state.events);

      final eventIndex = updatedEvents.indexWhere(
            (eventData) => eventData.id == eventId,
      );

      if (eventIndex != -1) {
        updatedEvents[eventIndex] = updatedEvent;
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      emit(
        state.copyWith(
          status: EventStatus.success,
          event: updatedEvent,
          events: updatedEvents,
          isEventUpdated: true,
          errorMessage: null,
        ),
      );

    } catch (e) {

      print("========== EDIT EVENT ERROR ==========");
      print(e);

      emit(
        state.copyWith(
          status: EventStatus.error,
          isEventUpdated: false,
          errorMessage: e
              .toString()
              .replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // ==========================================================
  // DELETE EVENT
  // ==========================================================

  Future<void> _deleteEvent(
      DeleteEvent event,
      Emitter<EventTabState> emit,
      ) async {
    emit(
      state.copyWith(
        status: EventStatus.loading,
        errorMessage: null,
        isEventDeleted: false,
      ),
    );

    try {
      await api.deleteEvent(event.eventId);

      // Remove deleted event locally
      final updatedEvents = List<EventModel>.from(state.events)
        ..removeWhere(
              (eventData) => eventData.id == event.eventId,
        );

      emit(
        state.copyWith(
          status: EventStatus.success,
          events: updatedEvents,
          isEventDeleted: true,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EventStatus.error,
          isEventDeleted: false,
          errorMessage: e
              .toString()
              .replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // ==========================================================
  // CHANGE TAB
  // ==========================================================

  void _changeTab(
      ChangeTabEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        selectedTab: event.tabEvent,
      ),
    );
  }

  // ==========================================================
  // DATE
  // ==========================================================

  void _dateEvent(
      DateEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        fromDate: event.fromDate,
        toDate: event.toDate,
      ),
    );
  }

  // ==========================================================
  // TIME
  // ==========================================================

  void _timeEvent(
      TimeEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        fromTime: event.fromTime,
        toTime: event.toTime,
      ),
    );
  }

  // ==========================================================
  // ADDRESS
  // ==========================================================

  void _addressEvent(
      AddressEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        address: event.address,
        locationLink: event.locationLink,
      ),
    );
  }

  // ==========================================================
  // ADD IMAGE
  // ==========================================================

  void _addImage(
      AddImageEvent event,
      Emitter<EventTabState> emit,
      ) {
    final updatedImages = [
      ...state.images,
      ...event.images,
    ];

    emit(
      state.copyWith(
        images: updatedImages,
      ),
    );
  }

  // ==========================================================
  // REMOVE IMAGE
  // ==========================================================

  void _removeImage(
      RemoveImageEvent event,
      Emitter<EventTabState> emit,
      ) {
    final updatedImages = [
      ...state.images,
    ];

    if (event.index >= 0 &&
        event.index < updatedImages.length) {
      updatedImages.removeAt(event.index);
    }

    emit(
      state.copyWith(
        images: updatedImages,
      ),
    );
  }

  // ==========================================================
  // JOINING BUTTON
  // ==========================================================

  void _joiningButton(
      JoiningButtonEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        displayJoiningButton:
        event.displayJoiningButton,
      ),
    );
  }
  void _backgroundImage(
      BackgroundImageEvent event,
      Emitter<EventTabState> emit,
      ) {
    if (!event.hasBackgroundImage) {
      emit(
        state.copyWith(
          hasBackgroundImage: false,
          bgImage: null,
          existingBgImage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasBackgroundImage: true,
      ),
    );
  }
  void _backgroundImageFile(
      BackgroundImageFileEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        bgImage: event.image,

        // A newly selected image replaces the old server background.
        existingBgImage: null,

        hasBackgroundImage: true,
      ),
    );
  }
  void _removeBackgroundImage(
      RemoveBackgroundImageEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        bgImage: null,
        existingBgImage: null,
        hasBackgroundImage: false,
        removeBackgroundImage: true,
      ),
    );
  }
  // ==========================================================
  // TAGGED PEOPLE
  // ==========================================================

  void _taggedPeople(
      TaggedPeopleEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        taggedPeople: event.taggedPeople,
      ),
    );
  }

  // ==========================================================
  // REMOVE TAGGED PERSON
  // ==========================================================

  Future<void> _joinUnjoinButton(
      joinUnJoinButtonEvent event,
      Emitter<EventTabState> emit,
      ) async {
    // ----------------------------------------------------------
    // FIND THE EVENT
    // ----------------------------------------------------------
    final currentEventIndex = state.events.indexWhere(
          (eventData) => eventData.id == event.eventId,
    );

    if (currentEventIndex == -1) {
      emit(
        state.copyWith(
          isSuccessInJoining: false,
          isErrorInJoining: true,
          errorMessage: "Event not found",
        ),
      );
      return;
    }

    final currentEvent = state.events[currentEventIndex];

    // ----------------------------------------------------------
    // CURRENT JOIN STATUS
    // ----------------------------------------------------------
    final bool wasAttending =
        currentEvent.isRequestorAttending == true;

    // ----------------------------------------------------------
    // CLEAR PREVIOUS MESSAGE
    // ----------------------------------------------------------
    emit(
      state.copyWith(
        joiningEventId: event.eventId,
        isSuccessInJoining: false,
        isErrorInJoining: false,
        errorMessage: '',
      ),
    );

    try {
      debugPrint("=================================");
      debugPrint("JOIN / UNJOIN EVENT");
      debugPrint("Event ID: ${event.eventId}");
      debugPrint("Was attending: $wasAttending");
      debugPrint("=================================");

      // --------------------------------------------------------
      // CALL API
      // --------------------------------------------------------
      await api.joinUnJoinEvent(event.eventId);

      // --------------------------------------------------------
      // NEW ATTENDANCE STATUS
      // --------------------------------------------------------
      final bool newAttendingStatus = !wasAttending;

      // --------------------------------------------------------
      // UPDATE ATTENDEE COUNT
      // --------------------------------------------------------
      final int oldCount = currentEvent.attendeeCount ?? 0;

      final int newCount = newAttendingStatus
          ? oldCount + 1
          : (oldCount > 0 ? oldCount - 1 : 0);

      // --------------------------------------------------------
      // UPDATE EVENT
      // --------------------------------------------------------
      final updatedEvent = currentEvent.copyWith(
        isRequestorAttending: newAttendingStatus,
        attendeeCount: newCount,
      );

      // --------------------------------------------------------
      // UPDATE EVENT LIST
      // --------------------------------------------------------
      final updatedEvents = List<EventModel>.from(state.events);

      updatedEvents[currentEventIndex] = updatedEvent;

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------
      emit(
        state.copyWith(
          clearJoiningEventId: true,
          events: updatedEvents,
          isSuccessInJoining: true,
          isErrorInJoining: false,
          errorMessage: '',
          joiningActionMessage: newAttendingStatus
              ? "Event joined successfully"
              : "Event unjoined successfully",
        ),
      );
    } catch (e) {
      debugPrint("Join/Unjoin error: $e");

      // --------------------------------------------------------
      // ERROR
      // --------------------------------------------------------
      emit(
        state.copyWith(
          clearJoiningEventId: true,
          isSuccessInJoining: false,
          isErrorInJoining: true,
          errorMessage:
          'Please try again, failed to join the event',
        ),
      );
    }
  }
  void _onResetEventForm(
      ResetEventForm event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        selectedTab: 0,

        fromDate: null,
        toDate: null,

        fromTime: null,
        toTime: null,

        hasBackgroundImage: false,
        bgImage: null,

        displayJoiningButton: false,

        taggedPeople: [],

        images: [],

        // Reset other temporary form values if you have them
        address: '',
        locationLink: '',

        status: EventStatus.initial,
      ),
    );
  }
  // ==========================================================
// GET ATTENDANCE
// ==========================================================

  Future<void> _getAttendance(
      GetAttendanceEvent event,
      Emitter<EventTabState> emit,
      ) async {
    final bool isFirstPage = event.page == 0;

    if (isFirstPage) {
      emit(
        state.copyWith(
          isLoadingAttendance: true,
          isLoadingMoreAttendance: false,
          attendanceError: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoadingMoreAttendance: true,
          attendanceError: null,
        ),
      );
    }

    try {
      final response = await api.attendanceData(
        event.eventId,
        event.page,
        event.size,
      );

      final List<AttendeePreview> updatedAllAttendees;

      if (isFirstPage) {
        updatedAllAttendees = [
          ...response.items,
        ];
      } else {
        updatedAllAttendees = [
          ...state.allAttendees,
          ...response.items,
        ];
      }

      emit(
        state.copyWith(
          allAttendees: updatedAllAttendees,

          // If there is no active search,
          // visible attendees = all loaded attendees.
          attendees: state.attendanceSearch.isEmpty
              ? updatedAllAttendees
              : _filterAttendees(
            updatedAllAttendees,
            state.attendanceSearch,
          ),

          attendanceCurrentPage: response.page,
          attendancePageSize: response.size,

          attendanceTotalItems: response.totalItems,
          attendanceTotalPages: response.totalPages,

          attendanceHasMore: response.hasNext,

          isLoadingAttendance: false,
          isLoadingMoreAttendance: false,

          attendanceError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingAttendance: false,
          isLoadingMoreAttendance: false,
          attendanceError: e
              .toString()
              .replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
  List<AttendeePreview> _filterAttendees(
      List<AttendeePreview> attendees,
      String search,
      ) {
    final query = search.trim().toLowerCase();

    if (query.isEmpty) {
      return attendees;
    }

    return attendees.where((attendee) {
      final user = attendee.user;

      final name =
          user?.name?.toLowerCase() ?? '';

      return name.contains(query);
    }).toList();
  }
  // ==========================================================
// SEARCH ATTENDANCE
// ==========================================================
  Future<void> _searchAttendance(
      SearchAttendanceEvent event,
      Emitter<EventTabState> emit,
      ) async {
    final String query = event.search.trim();

    // ----------------------------------------------------------
    // CLEAR SEARCH
    // ----------------------------------------------------------

    if (query.isEmpty) {
      emit(
        state.copyWith(
          attendees: state.allAttendees,
          attendanceSearch: '',
          isSearchingAttendance: false,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // START SEARCH
    // ----------------------------------------------------------

    emit(
      state.copyWith(
        isSearchingAttendance: true,
        attendanceSearch: query,
        attendanceError: null,
      ),
    );

    try {
      List<AttendeePreview> allData = [
        ...state.allAttendees,
      ];

      int nextPage = state.attendanceCurrentPage + 1;

      bool hasMore = state.attendanceHasMore;

      // --------------------------------------------------------
      // LOAD EVERY REMAINING PAGE
      // --------------------------------------------------------

      while (hasMore) {
        final response = await api.attendanceData(
          event.eventId,
          nextPage,
          state.attendancePageSize,
        );

        allData.addAll(response.items);

        hasMore = response.hasNext;

        nextPage = response.page + 1;
      }

      // --------------------------------------------------------
      // LOCAL SEARCH
      // --------------------------------------------------------

      final filteredData = _filterAttendees(
        allData,
        query,
      );

      // --------------------------------------------------------
      // UPDATE STATE
      // --------------------------------------------------------

      emit(
        state.copyWith(
          allAttendees: allData,

          attendees: filteredData,

          attendanceSearch: query,

          attendanceCurrentPage:
          hasMore
              ? state.attendanceCurrentPage
              : nextPage - 1,

          attendanceHasMore: false,

          isSearchingAttendance: false,

          isLoadingAttendance: false,

          isLoadingMoreAttendance: false,

          attendanceError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearchingAttendance: false,

          attendanceError: e
              .toString()
              .replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
  void _initializeEditEvent(
      InitializeEditEvent event,
      Emitter<EventTabState> emit,
      ) {
    final existingEvent = event.event;

    int selectedTab = 0;

    switch (existingEvent.kind.toUpperCase()) {
      case 'PRIVATE':
        selectedTab = 1;
        break;

      case 'SELECTIVE':
        selectedTab = 2;
        break;

      case 'PUBLIC':
      default:
        selectedTab = 0;
        break;
    }

    emit(
      state.copyWith(
        selectedTab: selectedTab,

        fromDate: existingEvent.eventFrom,
        toDate: existingEvent.eventTo,

        fromTime: existingEvent.timeFrom,
        toTime: existingEvent.timeTo,

        address: existingEvent.address?.addressText ?? '',
        locationLink: existingEvent.address?.addressLink ?? '',

        displayJoiningButton:
        existingEvent.displayJoinButton ?? false,

        hasBackgroundImage:
        existingEvent.bgImage != null &&
            existingEvent.bgImage!.isNotEmpty,

        existingBgImage: existingEvent.bgImage,

        bgImage: null,

        existingMedia:
        List<MediaModel>.from(existingEvent.medias ?? const []),

        images: const [],

        deletedMediaIds: const [],
        removeTags: const [],
        removeBackgroundImage: false,

        taggedPeople:
        List<Tagged>.from(existingEvent.tags ?? const []),

        isEventUpdated: false,
        isEventCreated: false,
        errorMessage: null,
      ),
    );
  }
  void _removedTaggedPeople(
      RemovedTaggedPeopleEvent event,
      Emitter<EventTabState> emit,
      ) {
    final updatedRemoveTags = [
      ...state.removeTags,
    ];

    for (final removedTag in event.removedTags) {
      final alreadyInRemoveTags = updatedRemoveTags.any(
            (tag) =>
        tag.id == removedTag.id &&
            tag.type == removedTag.type,
      );

      if (!alreadyInRemoveTags) {
        updatedRemoveTags.add(removedTag);
      }
    }

    emit(
      state.copyWith(
        removeTags: updatedRemoveTags,
      ),
    );
  }
  void _removeExistingMedia(
      RemoveExistingMediaEvent event,
      Emitter<EventTabState> emit,
      ) {
    final updatedMedia = [
      ...state.existingMedia,
    ];

    final updatedDeletedIds = [
      ...state.deletedMediaIds,
    ];

    if (event.index >= 0 &&
        event.index < updatedMedia.length) {
      final removedMedia = updatedMedia.removeAt(event.index);

      if (removedMedia.id != null &&
          !updatedDeletedIds.contains(removedMedia.id)) {
        updatedDeletedIds.add(removedMedia.id!);
      }
    }

    emit(
      state.copyWith(
        existingMedia: updatedMedia,
        deletedMediaIds: updatedDeletedIds,
      ),
    );
  }
  void _clearJoinMessage(
      ClearJoinMessageEvent event,
      Emitter<EventTabState> emit,
      ) {
    emit(
      state.copyWith(
        isSuccessInJoining: false,
        isErrorInJoining: false,
        joiningActionMessage: null,
        errorMessage: null,
      ),
    );
  }
}