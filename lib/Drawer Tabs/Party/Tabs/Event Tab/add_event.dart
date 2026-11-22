import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_event.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../../../Reusable Functions/image_video_compressor.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import '../../reusable_functions.dart';
import '../Feed Tab/apis.dart';
import '../Feed Tab/reusable_functions.dart';
import 'event_modal.dart';
import 'event_tagged_people_helper.dart';
import 'full_event_desc.dart';
import 'package:intl/intl.dart';
class AddEvent extends StatefulWidget {
  final int partyId;
  final EventModel? eventToEdit;
  final String fromWhichPage;
  final bool isPolitician;
  const AddEvent({super.key, required this.partyId, this.eventToEdit, required this.fromWhichPage,required this.isPolitician});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  bool _showLocationLinkField = false;
  bool get isEditMode => widget.eventToEdit != null;

  int? get editingEventId => widget.eventToEdit?.id;
  List<Tagged> taggedPeople = [];
  final FeedApis api = FeedApis();
  late EventTaggedPeopleHandler taggedPeopleHandler;

  final TextEditingController titleController = TextEditingController();

  final TextEditingController aboutEventController = TextEditingController();

  final TextEditingController dateController = TextEditingController();

  final TextEditingController timeController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController locationLinkController = TextEditingController();

  final TextEditingController scheduleController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;

  TimeOfDay? fromTime;
  TimeOfDay? toTime;

  List<MediaModel> _getPreviewMedia(EventTabState state) {
    final List<MediaModel> media = [
      ...state.existingMedia,
    ];

    for (final file in state.images) {
      final extension =
      file.path.split('.').last.toLowerCase();

      final isVideo = [
        'mp4',
        'mov',
        'avi',
        'mkv',
        'webm',
        '3gp',
      ].contains(extension);

      media.add(
        MediaModel(
          url: file.path,
          mediaType: isVideo ? "VIDEO" : "IMAGE",
        ),
      );
    }

    return media;
  }
  void _previewEvent() {
    final state = context.read<EventsBloc>().state;

    final previewMedia = _getPreviewMedia(state);

    final event = EventModel(
      // Existing event information when editing
      id: widget.eventToEdit?.id,
      uuid: widget.eventToEdit?.uuid,

      // Current form values
      kind: getEventKind(state.selectedTab),

      title: titleController.text.trim(),

      aboutEvent: aboutEventController.text.trim(),

      eventFrom: state.fromDate,
      eventTo: state.toDate,

      timeFrom: state.fromTime,
      timeTo: state.toTime,

      displayJoinButton:
      state.displayJoiningButton,

      address: Address(
        addressText: addressController.text.trim(),
        addressLink: locationLinkController.text.trim(),
      ),

      tags: state.taggedPeople,

      schedule: scheduleController.text.trim(),

      // Background image
      bgImageUrl: state.bgImageUrl != null
          ? state.bgImageUrl!.path
          : state.existingBgImage,
       bgImage:state.bgImage,
      // Existing + newly selected media
      medias: previewMedia,

      // Keep existing data in edit mode
      author: widget.eventToEdit?.author,
      authorUserId: widget.eventToEdit?.authorUserId,
      authorPartyId: widget.fromWhichPage=="Party"?widget.eventToEdit?.authorPartyId:null,
      authorType: widget.eventToEdit?.authorType,

      statusOfPublishment:
      widget.eventToEdit?.statusOfPublishment,

      isRequestorAttending:
      widget.eventToEdit?.isRequestorAttending,

      attendeesPreview:
      widget.eventToEdit?.attendeesPreview,

      attendeeCount:
      widget.eventToEdit?.attendeeCount,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (previewContext) {
        return BlocProvider.value(
          value: context.read<EventsBloc>(),
          child: FullEventDesc(
            eventData: event,
            partyId: widget.partyId,
            isAdmin: false,
            fromWhichPage: widget.fromWhichPage,
            isPolitician: widget.isPolitician,
          ),
        );
      },
    );
  }


  void _initializeForm() {
    final event = widget.eventToEdit;

    if (event == null) {
      return;
    }

    titleController.text = event.title;

    aboutEventController.text =
        event.aboutEvent ?? '';

    addressController.text =
        event.address?.addressText ?? '';

    locationLinkController.text =
        event.address?.addressLink ?? '';

    scheduleController.text =
        event.schedule ?? '';

    context.read<EventsBloc>().add(
      InitializeEditEvent(event),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<EventsBloc>().add(ClearEventDateTime());
    taggedPeopleHandler = EventTaggedPeopleHandler(
      api: api,
      context: context,
    );
    _initializeForm();
  }

  @override
  void dispose() {
    titleController.dispose();
    aboutEventController.dispose();
    dateController.dispose();

    addressController.dispose();
    locationLinkController.dispose();
    scheduleController.dispose();
    super.dispose();
  }

  DateTime? getScheduleDateTime() {
    final text = scheduleController.text.trim();

    if (text.isEmpty) {
      return null;
    }

    try {
      final parts = text.split(' ');

      if (parts.length < 2) {
        return null;
      }

      final dateParts = parts[0].split('-');

      if (dateParts.length != 3) {
        return null;
      }

      final timeString = parts[1];

      final timeParts = timeString.split(':');

      if (timeParts.length != 2) {
        return null;
      }

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length >= 3) {
        final meridiem = parts[2].toUpperCase();

        if (meridiem == 'PM' && hour != 12) {
          hour += 12;
        }

        if (meridiem == 'AM' && hour == 12) {
          hour = 0;
        }
      }

      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }
  String getEventKind(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return "PUBLIC";
      case 1:
        return "PRIVATE";
      case 2:
        return "SELECTIVE";
      default:
        return "PUBLIC";
    }
  }
  void _publishEvent() {

    final eventState = context.read<EventsBloc>().state;

    final event = EventModel(
      id: widget.eventToEdit?.id,
      uuid: widget.eventToEdit?.uuid,

      kind: getEventKind(eventState.selectedTab),

      title: titleController.text.trim(),

      aboutEvent: aboutEventController.text.trim(),

      eventFrom: eventState.fromDate,

      eventTo: eventState.toDate,

      timeFrom: eventState.fromTime,

      timeTo: eventState.toTime,

      displayJoinButton:
      eventState.displayJoiningButton,

      address: Address(
        addressText: addressController.text.trim(),
        addressLink: locationLinkController.text.trim(),
      ),

      tags: eventState.taggedPeople,

      schedule: scheduleController.text.trim(),
      bgImageUrl: eventState.hasBackgroundImage
          ? eventState.bgImageUrl?.path ?? eventState.existingBgImage
          : null,
      bgImage: eventState.hasBackgroundImage,
      medias: eventState.existingMedia,
      author: widget.eventToEdit?.author,
      authorUserId: widget.eventToEdit?.authorUserId,
      authorPartyId: widget.fromWhichPage=="Party"?widget.eventToEdit?.authorPartyId:null,
      authorType: widget.eventToEdit?.authorType,

      statusOfPublishment:
      widget.eventToEdit?.statusOfPublishment,

      isRequestorAttending:
      widget.eventToEdit?.isRequestorAttending,

      attendeesPreview:
      widget.eventToEdit?.attendeesPreview,

      attendeeCount:
      widget.eventToEdit?.attendeeCount,
    );

    if (isEditMode) {
      context.read<EventsBloc>().add(
        EditEvent(
          eventData: event,
          mediaFiles: eventState.images,
          bgImageUrl: eventState.hasBackgroundImage
              ? eventState.bgImageUrl
              : null,
          bgImage: eventState.hasBackgroundImage,
          partyId: widget.partyId,
          deletedMediaIds: eventState.deletedMediaIds,
          removeTags: eventState.removeTags,
          removeBackgroundImage: eventState.removeBackgroundImage,
        ),
      );
    } else {
      context.read<EventsBloc>().add(
        AddNewEvent(
          eventData: event,
          mediaFiles: eventState.images,
          bgImageUrl: eventState.hasBackgroundImage
              ? eventState.bgImageUrl
              : null,
          bgImage: eventState.hasBackgroundImage,
          partyId: widget.partyId,
          fromWhichPage: widget.fromWhichPage,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocConsumer<EventsBloc, EventTabState>(
      listener: (context, state) {
        // CREATE SUCCESS
        if (state.status == EventStatus.success &&
            state.isEventCreated) {

          titleController.clear();
          aboutEventController.clear();
          dateController.clear();
          timeController.clear();
          addressController.clear();
          locationLinkController.clear();
          scheduleController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Event created successfully",
                style: TextStyle(
                  color: ColorScheme.of(context).surface,
                ),
              ),
            ),
          );
          Navigator.pop(context,true);
        }

        // UPDATE SUCCESS
        if (state.status == EventStatus.success &&
            state.isEventUpdated &&
            isEditMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Event updated successfully",
                style: TextStyle(
                  color: ColorScheme.of(context).surface,
                ),
              ),
            ),
          );
          Navigator.pop(context,true);
        }

        // ERROR
        if (state.status == EventStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorScheme.of(context).error,
              content: Text(
                state.errorMessage ?? "Something went wrong",
                style: TextStyle(
                  color: ColorScheme.of(context).surface,
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                ReusableSliverAppBar(
                  title: isEditMode
                      ? "Edit Event"
                      : PartyPageData.addEvents,
                  automaticallyImplyLeading: false,
                  height: h * 0.06,
                  isMenuNeeded: false,
                  actions: [
                    ///--------Schedule Button
                    FeedQuoteTab(
                      title: PartyPageData.schedule,
                      textStyle: TextStyle(
                        fontSize:   MediaQuery.of(context).size.width * 0.035,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      isSelected: false,
                      onTap: () async {
                        final schedule = await showDialog<Map<String, String>>(
                          context: context,
                          builder: (_) => AddSchedule(
                            initialDateTime: getScheduleDateTime(),
                          ),
                        );

                        if (schedule != null) {
                          setState(() {
                            scheduleController.text =
                                "${schedule['date']} ${schedule['time']}";
                          });
                        }
                      },
                      iconName: PartyPageData.scheduleIcon,
                      iconColor: Colors.white,
                      height: h * 0.05,
                      width: w * 0.35,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: w*0.15,
                        height: w*0.15,
                        child: Center(
                          child: SvgPicture.asset(
                            PartyPageData.crossIcon,
                            height: h * 0.023,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SliverFillRemaining(
                  child: Stack(
                    children: [
                      Container(
                        height: h * 0.08,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient:
                              GradientColorsForBellowAppbar.gradientBelowAppbar,
                        ),
                      ),
                      Positioned.fill(
                        top: h * 0.02,
                        child: Container(
                          height: h,
                          width: w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.03,
                              right: MediaQuery.of(context).size.width * 0.04,
                              left: MediaQuery.of(context).size.width * 0.04,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ///--Public
                                        FeedQuoteTab(
                                          title: PartyPageData.public,
                                          textStyle: TextStyle(
                                            fontSize:   MediaQuery.of(context).size.width * 0.04,
                                            letterSpacing: 0.37,
                                            fontWeight: FontWeight.w400,
                                            color: state.selectedTab == 0?ColorScheme.of(context).surface:ColorScheme.of(context).onSurface,
                                          ),
                                          isSelected: state.selectedTab == 0,
                                          onTap: (){
                                            context.read<EventsBloc>().add(
                                              ChangeTabEvent(0),
                                            );
                                          },
                                          iconName: PartyPageData.globalIcon,
                                          iconColor: state.selectedTab == 0?ColorScheme.of(context).surface:ColorScheme.of(context).onSurface,
                                          height: h * 0.05,
                                          width: w * 0.35,
                                        ),
                                        SizedBox(width: w * 0.03),
                                        ///---Private
                                        FeedQuoteTab(
                                          title: PartyPageData.private,
                                          textStyle: TextStyle(
                                            fontSize:   MediaQuery.of(context).size.width * 0.04,
                                            fontWeight: FontWeight.w400,
                                            color:state.selectedTab == 1?ColorScheme.of(context).surface:ColorScheme.of(context).onSurface,
                                          ),
                                          isSelected:  state.selectedTab == 1,
                                          onTap: (){
                                            context.read<EventsBloc>().add(
                                              ChangeTabEvent(1),
                                            );
                                          },
                                          iconName: PartyPageData.lockIcon,
                                          iconColor: state.selectedTab == 1?ColorScheme.of(context).surface:ColorScheme.of(context).onSurface,
                                          height: h * 0.05,
                                          width: w * 0.35,
                                        ),
                                        SizedBox(width: w * 0.03),
                                        ///--Selective
                                        FeedQuoteTab(
                                          title: PartyPageData.selective,
                                          textStyle: TextStyle(
                                            fontSize:   MediaQuery.of(context).size.width * 0.04,
                                            fontWeight: FontWeight.w400,
                                            color: state.selectedTab == 2?ColorScheme.of(context).surface:ColorScheme.of(context).onSurface,
                                          ),
                                          isSelected:  state.selectedTab == 2,
                                          onTap: (){
                                            context.read<EventsBloc>().add(
                                              ChangeTabEvent(2),
                                            );
                                          },
                                          iconName: PartyPageData.tagPeopleIcon,
                                          iconColor: state.selectedTab == 2?ColorScheme.of(context).surface:ColorScheme.of(context).onSurface,
                                          iconHeight: w*0.04,
                                          height: h * 0.05,
                                          width: w * 0.35,
                                        ),

                                      ],
                                    ),
                                  ),
                                  SizedBox(height: h*0.04,),
                                  ///----Event name and title
                                  CustomTextField(
                                      controller:titleController,
                                      labelText: PartyPageData.eventNameTitle,
                                    isRequired: true,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: ColorScheme.of(context).onSurface,
                                    ),
                                  ),
                                  SizedBox(height: h*0.04,),
                                  ///----About event
                                  CustomTextField(
                                    height: MediaQuery.of(context).size.height * 0.15,
                                    maxLines: 5,
                                    keyboardType: TextInputType.multiline,
                                    controller:aboutEventController,
                                    labelText: PartyPageData.aboutEvent,
                                    isRequired: true,
                                    textStyle: TextStyle(
                                      //fontWeight: FontWeight.w600,
                                      color: ColorScheme.of(context).onSurface,
                                    ),
                                  ),
                                  SizedBox(height: h*0.04,),
                                  ///------- Add From Date To Date



                                  EventDateRangeField(
                                    fromDate: state.fromDate,
                                    toDate: state.toDate,

                                    onFromDateSelected: (date) {
                                      DateTime? updatedToDate = state.toDate;

                                      if (updatedToDate != null &&
                                          updatedToDate.isBefore(date)) {
                                        updatedToDate = null;
                                      }

                                      context.read<EventsBloc>().add(
                                        DateEvent(date, updatedToDate),
                                      );
                                    },

                                    onToDateSelected: (date) {
                                      if (state.fromDate == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please select the start date first.'),
                                          ),
                                        );
                                        return;
                                      }

                                      if (date.isBefore(state.fromDate!)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('End date cannot be before start date.'),
                                          ),
                                        );
                                        return;
                                      }

                                      context.read<EventsBloc>().add(
                                        DateEvent(state.fromDate, date),
                                      );
                                    },
                                  ),



                                  SizedBox(height: h*0.04,),
                                  ///------- Add From Time To Time

                                  EventTimeRangeField(
                                    fromTime: state.fromTime,
                                    toTime: state.toTime,

                                    onFromTimeSelected: (time) {
                                      TimeOfDay? updatedToTime = state.toTime;

                                      // Clear end time if it is earlier than the new start time.
                                      if (updatedToTime != null &&
                                          (updatedToTime.hour * 60 + updatedToTime.minute) <=
                                              (time.hour * 60 + time.minute)) {
                                        updatedToTime = null;
                                      }

                                      context.read<EventsBloc>().add(
                                        TimeEvent(time, updatedToTime),
                                      );
                                    },

                                    onToTimeSelected: (time) {
                                      if (state.fromTime == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please select the start time first.'),
                                          ),
                                        );
                                        return;
                                      }

                                      final fromMinutes =
                                          state.fromTime!.hour * 60 + state.fromTime!.minute;

                                      final toMinutes = time.hour * 60 + time.minute;

                                      if (toMinutes <= fromMinutes) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('End time must be later than start time.'),
                                          ),
                                        );
                                        return;
                                      }

                                      context.read<EventsBloc>().add(
                                        TimeEvent(state.fromTime, time),
                                      );
                                    },
                                  ),
                                  SizedBox(height: h*0.0015,),
                                  Text(PartyPageData.youCannotChange,style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: h*0.017,
                                    color: Color(0xFF020202),
                                  ),),
                                  SizedBox(height: h*0.03,),
                                  CustomTextField(
                                    controller: addressController,
                                    labelText: PartyPageData.address,
                                    isRequired: true,

                                    onChanged: (value) {
                                      context.read<EventsBloc>().add(
                                        AddressEvent(
                                          value,
                                          locationLinkController.text,
                                        ),
                                      );
                                    },

                                    textStyle: TextStyle(
                                      color: ColorScheme.of(context).onSurface,
                                    ),

                                    suffixIcons: [
                                      InkWell(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();

                                          setState(() {
                                            _showLocationLinkField =
                                            !_showLocationLinkField;
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          PartyPageData.locationIcon,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (_showLocationLinkField)
                                    Padding(
                                      padding: EdgeInsets.only(top: h * 0.02),
                                      child: CustomTextField(
                                        controller: locationLinkController,
                                        labelText: "Location Link",
                                        keyboardType: TextInputType.url,

                                        textStyle: TextStyle(
                                          color: ColorScheme.of(context).onSurface,
                                        ),

                                        onChanged: (value) {
                                          context.read<EventsBloc>().add(
                                            AddressEvent(
                                              addressController.text.trim(),
                                              value.trim(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  SizedBox(height: h*0.04,),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        PartyPageData.backgroundImage,
                                        style: TextStyle(
                                          fontSize: h * 0.02,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF656579),
                                        ),
                                      ),

                                      const Spacer(),

                                      radioButtons(
                                        "Yes",
                                        true,
                                        state.hasBackgroundImage,
                                        h,
                                            (value) {
                                          if (value != null) {
                                            context.read<EventsBloc>().add(
                                              BackgroundImageEvent(value),
                                            );
                                          }
                                        },
                                      ),

                                      radioButtons(
                                        "No",
                                        false,
                                        state.hasBackgroundImage,
                                        h,
                                            (value) {
                                          if (value != null) {
                                            context.read<EventsBloc>().add(
                                              BackgroundImageEvent(value),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),


                                  if (state.hasBackgroundImage) ...[

                                    if (state.existingBgImage != null &&
                                        state.existingBgImage!.isNotEmpty &&
                                        state.bgImageUrl == null)
                                      Stack(
                                        children: [
                                          SizedBox(height: h*0.04,),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: buildImageWidget(
                                              state.existingBgImage!,
                                              width: double.infinity,
                                              height: h * 0.18,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: InkWell(
                                              onTap: () {
                                                context.read<EventsBloc>().add(
                                                  RemoveBackgroundImageEvent(),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )

                                    // --------------------------------------------------------
                                    // NEWLY SELECTED BACKGROUND
                                    // --------------------------------------------------------

                                    else if (state.bgImageUrl != null)
                                      ReusableImagePicker(
                                        height: h * 0.18,
                                        mediaFiles: [
                                          state.bgImageUrl!,
                                        ],

                                        onAddMedia: () async {
                                          final PickedMedia pickedMedia =
                                          await ReusableMediaPicker.pickMedia(context);

                                          if (pickedMedia.images.isNotEmpty) {
                                            final imageFile = File(
                                              pickedMedia.images.first.path,
                                            );

                                            context.read<EventsBloc>().add(
                                              BackgroundImageFileEvent(imageFile),
                                            );
                                          }
                                        },

                                        onRemoveMedia: (index) {
                                          context.read<EventsBloc>().add(
                                            RemoveBackgroundImageEvent(),
                                          );
                                        },
                                      )


                                    else
                                      ReusableImagePicker(
                                        height: h * 0.18,
                                        mediaFiles: const [],

                                        onAddMedia: () async {
                                          final PickedMedia pickedMedia =
                                          await ReusableMediaPicker.pickMedia(context);

                                          // Background = IMAGE ONLY
                                          if (pickedMedia.images.isNotEmpty) {
                                            final imageFile = File(
                                              pickedMedia.images.first.path,
                                            );

                                            context.read<EventsBloc>().add(
                                              BackgroundImageFileEvent(imageFile),
                                            );
                                          }
                                        },

                                        onRemoveMedia: (index) {},
                                      ),
                                  ],
                                  SizedBox(height: h*0.04,),
                                  ///----------Display join button
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(PartyPageData.displayJoinButton,
                                        style: TextStyle(
                                          fontSize: h*0.02,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF656579),
                                        ),
                                      ),
                                      Spacer(),
                                      radioButtons(
                                        "Yes",
                                        true,
                                        state.displayJoiningButton,
                                        h,
                                            (value) {
                                          if (value != null) {
                                            context.read<EventsBloc>().add(
                                              JoiningButtonEvent(value),
                                            );
                                          }
                                        },
                                      ),

                                      radioButtons(
                                        "No",
                                        false,
                                        state.displayJoiningButton,
                                        h,
                                            (value) {
                                          if (value != null) {
                                            context.read<EventsBloc>().add(
                                              JoiningButtonEvent(value),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  TaggingPeoplePicker(
                                    initialTaggedPeople: state.taggedPeople,

                                    onChanged: (people) {
                                      // Keep a local copy if needed.
                                      taggedPeople = List<Tagged>.from(people);

                                      // Update BLoC with currently selected people.
                                      context.read<EventsBloc>().add(
                                        TaggedPeopleEvent(
                                          List<Tagged>.from(people),
                                        ),
                                      );

                                      // Find previously existing tags that have been removed.
                                      final originalTags = widget.eventToEdit?.tags ?? [];

                                      final removedTags = originalTags.where((oldTag) {
                                        return !people.any(
                                              (newTag) =>
                                          newTag.id == oldTag.id &&
                                              newTag.type == oldTag.type,
                                        );
                                      }).toList();

                                      // Update removed tags for PATCH API.
                                      context.read<EventsBloc>().add(
                                        RemovedTaggedPeopleEvent(
                                          List<Tagged>.from(removedTags),
                                        ),
                                      );
                                    },

                                    builder: (context, selectedPeople, openTaggingPeople) {
                                      return FeedQuoteTab(
                                        title: selectedPeople.isEmpty
                                            ? PartyPageData.tagPeople
                                            : '${PartyPageData.tagPeople} (${selectedPeople.length})',
                                        isSelected: false,
                                        onTap: openTaggingPeople,
                                        iconName: PartyPageData.tagPeopleIcon,
                                        height: h * 0.05,
                                        width: w * 0.45,
                                      );
                                    },
                                  ),

                                  SizedBox(height: h * 0.02),


                                  if (state.existingMedia.isNotEmpty) ...[
                                    ExistingEventMediaGrid(
                                      media: state.existingMedia,
                                      onRemove: (index) {
                                        context.read<EventsBloc>().add(
                                          RemoveExistingMediaEvent(index),
                                        );
                                      },
                                    ),

                                    SizedBox(height: h * 0.02),
                                  ],

                                  ReusableImagePicker(
                                    height: h * 0.18,

                                    mediaFiles: state.images,

                                    onAddMedia: () async {
                                      final PickedMedia pickedMedia =
                                      await ReusableMediaPicker.pickMedia(context);

                                      final List<File> selectedMedia = [
                                        ...pickedMedia.images.map(
                                              (image) => File(image.path),
                                        ),
                                        ...pickedMedia.videos.map(
                                              (video) => File(video.path),
                                        ),
                                      ];

                                      if (selectedMedia.isEmpty) {
                                        return;
                                      }

                                      // Show compression/loading dialog.
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      );

                                      try {
                                        final List<File> compressedFiles =
                                        await MediaCompressor.compressFiles(
                                          selectedMedia,
                                        );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        Navigator.of(context).pop();

                                        if (compressedFiles.length != selectedMedia.length) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                "Some media files are larger than 25 MB even after compression.",
                                              ),
                                            ),
                                          );
                                        }

                                        if (compressedFiles.isNotEmpty) {
                                          context.read<EventsBloc>().add(
                                            AddImageEvent(compressedFiles),
                                          );
                                        }
                                      } catch (e) {
                                        if (!context.mounted) {
                                          return;
                                        }

                                        Navigator.of(context).pop();

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              "Unable to compress media: $e",
                                            ),
                                          ),
                                        );
                                      }
                                    },

                                    onRemoveMedia: (index) {
                                      context.read<EventsBloc>().add(
                                        RemoveImageEvent(index),
                                      );
                                    },
                                  ),
                                  SizedBox(height: h*0.04,),
                                  ///-----------Publish button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: state.status == EventStatus.loading
                                            ? null
                                            : () {
                                          _previewEvent();
                                        },
                                        child: Center(
                                          child: Container(
                                            height:
                                            MediaQuery
                                                .of(
                                              context,
                                            )
                                                .size
                                                .height *
                                                0.05,
                                            width:
                                            MediaQuery
                                                .of(
                                              context,
                                            )
                                                .size
                                                .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              gradient: GradientColors
                                                  .primaryGradient,
                                              borderRadius:
                                              BorderRadius.circular(
                                                MediaQuery
                                                    .of(
                                                  context,
                                                )
                                                    .size
                                                    .height *
                                                    0.03,
                                              ),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFFFF2164,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                children: [
                                                  SvgPicture.asset(
                                                    PartyPageData
                                                        .addIcon,
                                                    color:
                                                    ColorScheme
                                                        .of(
                                                      context,
                                                    )
                                                        .surface,
                                                    height:
                                                    MediaQuery
                                                        .of(
                                                      context,
                                                    )
                                                        .size
                                                        .height *
                                                        0.02,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                    MediaQuery
                                                        .of(
                                                      context,
                                                    )
                                                        .size
                                                        .width *
                                                        0.02,
                                                  ),
                                                  Text(
                                                   "PREVIEW",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                      color:
                                                      ColorScheme
                                                          .of(
                                                        context,
                                                      )
                                                          .surface,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                      fontSize:
                                                      (MediaQuery
                                                          .of(
                                                        context,
                                                      )
                                                          .size
                                                          .width *
                                                          0.04)
                                                          .clamp(
                                                        14.0,
                                                        16.0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: w*0.03,),
                                      InkWell(
                                        onTap: state.status == EventStatus.loading
                                            ? null
                                            : () {
                                          _publishEvent();
                                        },
                                        child: Center(
                                          child: Container(
                                            height: MediaQuery.of(context).size.height * 0.05,
                                            width: MediaQuery.of(context).size.width * 0.3,
                                            decoration: BoxDecoration(
                                              gradient: GradientColors.primaryGradient,
                                              borderRadius: BorderRadius.circular(
                                                MediaQuery.of(context).size.height * 0.03,
                                              ),
                                              border: Border.all(
                                                color: const Color(0xFFFF2164),
                                              ),
                                            ),
                                            child: Center(
                                              child: state.status == EventStatus.loading
                                                  ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white,
                                                ),
                                              )
                                                  : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    PartyPageData.addIcon,
                                                    color: ColorScheme.of(context).surface,
                                                    height: MediaQuery.of(context).size.height * 0.02,
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.02,
                                                  ),
                                                  Text(
                                                    isEditMode
                                                        ? "Update"
                                                        : PartyPageData.publish,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: ColorScheme.of(context).surface,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: (MediaQuery.of(context).size.width * 0.04)
                                                          .clamp(14.0, 16.0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: h*0.04,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
