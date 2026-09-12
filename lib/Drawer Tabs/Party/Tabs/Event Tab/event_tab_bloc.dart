import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_state.dart';

import 'apis.dart';
import 'event_modal.dart';
import 'event_tab_event.dart' show RemoveTaggedPeopleEvent, TaggedPeopleEvent, EventsEvent, AddNewEvent, EditEvent, DeleteEvent, ChangeTabEvent, DateEvent, TimeEvent, AddressEvent, AddImageEvent, RemoveImageEvent, JoiningButtonEvent, GetEventEvent, BackgroundImageEvent, BackgroundImageFileEvent, RemoveBackgroundImageEvent, joinUnJoinButtonEvent;


class EventsBloc extends Bloc<EventsEvent, EventTabState> {
  final EventApis api;

  EventsBloc(this.api) : super(const EventTabState()) {
    on<GetEventEvent>(_getEvent);
    on<AddNewEvent>(_addNewEvent);
    on<EditEvent>(_editEvent);
    on<DeleteEvent>(_deleteEvent);

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
    on<RemoveTaggedPeopleEvent>(_removeTaggedPeople);

    on<joinUnJoinButtonEvent>(_joinUnjoinButton);
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
        ),
      );

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
      ),
    );

    try {
      // Add your actual update API here.
      //
      // final updatedEvent = await api.updateTheEvent(
      //   event: event.eventData,
      //   mediaFiles: event.mediaFiles,
      //   bgImage: event.bgImage,
      // );

      emit(
        state.copyWith(
          status: EventStatus.success,
          event: event.eventData,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EventStatus.error,
          errorMessage: e.toString(),
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
      ),
    );

    try {
      // Add your actual delete API here.
      //
      // await api.deleteTheEvent(
      //   eventId: event.eventId,
      // );

      emit(
        state.copyWith(
          status: EventStatus.success,
          event: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EventStatus.error,
          errorMessage: e.toString(),
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
    emit(
      state.copyWith(
        hasBackgroundImage: event.hasBackgroundImage,
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

  void _removeTaggedPeople(
      RemoveTaggedPeopleEvent event,
      Emitter<EventTabState> emit,
      ) {
    final updatedPeople = [
      ...state.taggedPeople,
    ];

    if (event.index >= 0 &&
        event.index < updatedPeople.length) {
      updatedPeople.removeAt(event.index);
    }

    emit(
      state.copyWith(
        taggedPeople: updatedPeople,
      ),
    );
  }
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
}