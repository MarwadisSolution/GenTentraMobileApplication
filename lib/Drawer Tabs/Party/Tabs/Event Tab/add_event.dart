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

import '../../../../Reusable Functions/reusable_functions.dart';
import '../Feed Tab/apis.dart';
import '../Feed Tab/reusable_functions.dart';
import 'event_modal.dart';
import 'event_tagged_people_helper.dart';

class AddEvent extends StatefulWidget {
  final int partyId;
  const AddEvent({super.key, required this.partyId});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
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

  @override
  void initState() {
    super.initState();

    taggedPeopleHandler = EventTaggedPeopleHandler(
      api: api,
      context: context,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    aboutEventController.dispose();
    dateController.dispose();
    timeController.dispose();
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

      if (parts.length != 2) {
        return null;
      }

      final dateParts = parts[0].split('-');
      final timeParts = parts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 2) {
        return null;
      }

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // If your controller contains AM/PM, handle it separately.
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        hour,
        minute,
      );
    } catch (e) {
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
    print("hello publish----I came");
    final eventState = context.read<EventsBloc>().state;

    final event = EventModel(
      kind: getEventKind(eventState.selectedTab),

      title: titleController.text.trim(),

      aboutEvent: aboutEventController.text.trim(),

      eventFrom: eventState.fromDate,

      eventTo: eventState.toDate,

      timeFrom: eventState.fromTime,

      timeTo: eventState.toTime,

      displayJoinButton: eventState.displayJoiningButton,

      address: Address(
        addressText: addressController.text.trim(),
        addressLink: "",///-------------abhi empty rakhi hai
      ),

      tags: eventState.taggedPeople,

      schedule: scheduleController.text.trim(),

      bgImage: null,

      medias: null,
    );

    context.read<EventsBloc>().add(
      AddNewEvent(
        eventData: event,
        mediaFiles: eventState.images,
        bgImage: eventState.bgImage,
        partyId: widget.partyId,
      ),
    );
    print("hello publish----I completed");
  }
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocConsumer<EventsBloc, EventTabState>(
      listener: (context, state) {
        if (state.status == EventStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Event created successfully",
                style: TextStyle(color: ColorScheme.of(context).surface),
              ),
            ),
          );
          Navigator.pop(context);
        }
        if (state.status == EventStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorScheme.of(context).error,
              content: Text(
                "Something went wrong ",
                style: TextStyle(color: ColorScheme.of(context).surface),
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
                  title: PartyPageData.addEvents,
                  automaticallyImplyLeading: false,
                  height: h * 0.06,
                  isMenuNeeded: false,
                  actions: [
                    ///--------Schedule Button
                    FeedQuoteTab(
                      title: PartyPageData.schedule,
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
                      height: h * 0.05,
                      width: w * 0.35,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: 48,
                        height: 48,
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
                                          isSelected: state.selectedTab == 0,
                                          onTap: (){
                                            context.read<EventsBloc>().add(
                                              ChangeTabEvent(0),
                                            );
                                          },
                                          iconName: PartyPageData.lockIcon,
                                          height: h * 0.05,
                                          width: w * 0.35,
                                        ),
                                        SizedBox(width: w * 0.03),
                                        ///---Private
                                        FeedQuoteTab(
                                          title: PartyPageData.private,
                                          isSelected:  state.selectedTab == 1,
                                          onTap: (){
                                            context.read<EventsBloc>().add(
                                              ChangeTabEvent(1),
                                            );
                                          },
                                          iconName: PartyPageData.globalIcon,
                                          height: h * 0.05,
                                          width: w * 0.35,
                                        ),
                                        SizedBox(width: w * 0.03),
                                        ///--Selective
                                        FeedQuoteTab(
                                          title: PartyPageData.selective,
                                          isSelected:  state.selectedTab == 2,
                                          onTap: (){
                                            context.read<EventsBloc>().add(
                                              ChangeTabEvent(2),
                                            );
                                          },
                                          iconName: PartyPageData.tagPeopleIcon,
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
                                  EventRangePicker(
                                    type: EventRangePickerType.date,
                                    label: "Date",
                                    isRequired: true,

                                    fromDate: state.fromDate,
                                    toDate: state.toDate,

                                    onDateRangeSelected: (range) {
                                      context.read<EventsBloc>().add(
                                        DateEvent(
                                          range.start,
                                          range.end,
                                        ),
                                      );
                                    },
                                  ),
                              SizedBox(height: h*0.04,),
                                  ///------- Add From Time To Time
                                  EventRangePicker(
                                    type: EventRangePickerType.time,
                                    label: "Time",
                                    isRequired: true,

                                    fromTime: state.fromTime,
                                    toTime: state.toTime,

                                    onTimeRangeSelected: (range) {
                                      context.read<EventsBloc>().add(
                                        TimeEvent(
                                          range.start,
                                          range.end,
                                        ),
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
                                          // location link
                                        },
                                        child: SvgPicture.asset(
                                          PartyPageData.locationIcon,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: h*0.04,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(PartyPageData.backgroundImage,
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
                                    SizedBox(height: h * 0.02),

                                    ReusableImagePicker(
                                      height: h * 0.18,
                                      mediaFiles: state.bgImage != null
                                          ? [state.bgImage!]
                                          : [],

                                      onAddMedia: () async {
                                        final PickedMedia pickedMedia =
                                        await ReusableMediaPicker.pickMedia(context);

                                        if (pickedMedia.images.isNotEmpty) {
                                          final File imageFile = File(
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
                                    ),
                                  ],
                                  SizedBox(height: h*0.04,),

                                  ///----------Display join button
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ///--------------Tag People
                                  ///--------------Tag People
                                  FeedQuoteTab(
                                    title: PartyPageData.taggedPeople,
                                    isSelected: false,
                                    onTap: () async {
                                      final currentTaggedPeople =
                                      List<Tagged>.from(state.taggedPeople);

                                      final updatedTaggedPeople =
                                      await taggedPeopleHandler.addMoreTaggedPeople(
                                        taggedPeople: currentTaggedPeople,
                                      );

                                      if (!mounted || updatedTaggedPeople == null) return;

                                      context.read<EventsBloc>().add(
                                        TaggedPeopleEvent(
                                          updatedTaggedPeople,
                                        ),
                                      );
                                    },
                                    iconName: PartyPageData.tagPeopleIcon,
                                    height: h * 0.05,
                                    width: w * 0.45,
                                  ),
                                  ///--------------baki hai
                                  ReusableImagePicker(
                                    height: h * 0.18,

                                    mediaFiles: state.images,
                                    onAddMedia: () async {
                                      final PickedMedia pickedMedia =
                                      await ReusableMediaPicker.pickMedia(context);

                                      final List<File> selectedMedia = [
                                        ...pickedMedia.images.map((image) => File(image.path)),
                                        ...pickedMedia.videos.map((video) => File(video.path)),
                                      ];

                                      if (selectedMedia.isNotEmpty) {
                                        context.read<EventsBloc>().add(
                                          AddImageEvent(selectedMedia),
                                        );
                                      }
                                    },onRemoveMedia: (index) {
                                    context.read<EventsBloc>().add(
                                      RemoveImageEvent(index),
                                    );
                                  },
                                  ),
                                  SizedBox(height: h*0.04,),
                                  ///-----------Publish button
                                  InkWell(
                                    onTap: (){
                                      print("hello publish");
                                      _publishEvent();
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
                                               PartyPageData
                                                    .publish,
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
