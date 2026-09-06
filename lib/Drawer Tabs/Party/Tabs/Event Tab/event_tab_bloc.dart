import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_state.dart';

import 'apis.dart';
import 'event_tab_event.dart' show RemoveTaggedPeopleEvent, TaggedPeopleEvent, EventsEvent, AddNewEvent, EditEvent, DeleteEvent, ChangeTabEvent, DateEvent, TimeEvent, AddressEvent, AddImageEvent, RemoveImageEvent, JoiningButtonEvent, GetEventEvent, BackgroundImageEvent, BackgroundImageFileEvent, RemoveBackgroundImageEvent;


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
  }

  // ==========================================================
  // GET EVENT
  // ==========================================================

  Future<void> _getEvent(
      GetEventEvent event,
      Emitter<EventTabState> emit,
      ) async {
    emit(
      state.copyWith(
        status: EventStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final eventData = await api.getTheEvent(
        partyId: event.partyId,
      );

      emit(
        state.copyWith(
          status: EventStatus.success,
          event: eventData,
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
}