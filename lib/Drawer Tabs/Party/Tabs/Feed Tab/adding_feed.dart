import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/reusable_media_grid.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import '../../party_page_data.dart';
import '../tagged_people_helper.dart';
import 'feed_event.dart';

class AddingFeed extends StatefulWidget {
  final int partyId;
  final FeedModel? editFeed;

  const AddingFeed({super.key, required this.partyId, required this.editFeed});

  bool get isEditMode => editFeed != null;

  @override
  State<AddingFeed> createState() => _AddingFeedState();
}

class _AddingFeedState extends State<AddingFeed> {
  final FeedApis api = FeedApis();
  late TaggedPeopleHandler taggedPeopleHandler;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController scheduleController = TextEditingController();

  List<Tagged> taggedPeople = [];

  ///-----------Adding Images and videos
  List<XFile> selectedImages = [];
  List<XFile> selectedVideos = [];
  List<FeedMedia> existingImages = [];
  List<FeedMedia> existingVideos = [];
  List<int> deletedMediaIds = [];
  final ImagePicker imagePicker = ImagePicker();
  final VideoPlayerHelper videoPlayerHelper = VideoPlayerHelper();

  Future<void> playVideo(int index, {required bool isExisting}) async {
    if (isExisting) {
      await videoPlayerHelper.playVideo(
        context: context,
        index: index,
        isExisting: true,
        existingVideoUrl: existingVideos[index].url,
      );
    } else {
      await videoPlayerHelper.playVideo(
        context: context,
        index: index,
        isExisting: false,
        localVideoPath: selectedVideos[index].path,
      );
    }

    if (mounted) {
      setState(() {});
    }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    taggedPeopleHandler = TaggedPeopleHandler(
      context: context,
      api: api,
    );
    if (widget.editFeed != null) {
      final data = FeedHelper.initializeEditData("FEED", widget.editFeed!);

      descriptionController.text = data.description!;
      taggedPeople = data.taggedPeoples;
      existingImages = data.existingImages!;
      existingVideos = data.existingVideos!;
      if (widget.editFeed!.scheduledAt != null) {
        final scheduled = widget.editFeed!.scheduledAt!;

        scheduleController.text =
        "${scheduled.day.toString().padLeft(2, '0')}-"
            "${scheduled.month.toString().padLeft(2, '0')}-"
            "${scheduled.year} "
            "${scheduled.hour.toString().padLeft(2, '0')}:"
            "${scheduled.minute.toString().padLeft(2, '0')}";
      }
    }
  }

  ///------------Publish
  Future<void> _publishFeed() async {
    if (descriptionController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ColorScheme
              .of(context)
              .error,
          content: Text(
            "Please enter description",
            style: TextStyle(color: ColorScheme
                .of(context)
                .surface),
          ),
        ),
      );
      return;
    }

    try {
      final List<File> mediaFiles = [
        ...selectedImages.map((e) => File(e.path)),
        ...selectedVideos.map((e) => File(e.path)),
      ];

      DateTime? scheduledAt;

      if (scheduleController.text
          .trim()
          .isNotEmpty) {
        final parts = scheduleController.text.trim().split(' ');

        if (parts.length == 2) {
          final dateParts = parts[0].split('-');
          final timeParts = parts[1].split(':');

          scheduledAt = DateTime.utc(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      }

      final feed = FeedModel(
        id: widget.editFeed?.id,
        kind: "POST",
        //title: titleController.text.trim(),
        body: descriptionController.text.trim(),
        authorPartyId: widget.partyId,
        tagged: taggedPeople,
        scheduledAt: scheduledAt,

        // IMPORTANT: preserve existing media that was NOT deleted
        media: [...existingImages, ...existingVideos],
      );

      if (widget.isEditMode) {
        context.read<FeedBloc>().add(
          UpdateFeedEvent(
            feed: feed,
            mediaFiles: mediaFiles,
            deletedMediaIds: deletedMediaIds,
            partyId: widget.partyId,
          ),
        );
      } else {
        context.read<FeedBloc>().add(
          AddNewFeedEvent(
            feed: feed,
            mediaFiles: mediaFiles,
            partyId: widget.partyId,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error creating feed event: $e");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to publish feed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery
        .of(context)
        .size
        .width;
    final h = MediaQuery
        .of(context)
        .size
        .height;
    return BlocListener<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.isPostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                state.isOfflineQueued
                    ? "Saved offline. It will be published automatically when internet is restored."
                    : "Successfully published",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
        if (state.isError) {
          debugPrint("Error in adding feed:- ${state.errorMessage}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorScheme
                  .of(context)
                  .error,
              content: Text(
                "Failed to publish",
                style: TextStyle(color: ColorScheme
                    .of(context)
                    .surface),
              ),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              ReusableSliverAppBar(
                title: PartyPageData.feedTitle,
                automaticallyImplyLeading: false,
                height: h * 0.06,
                isMenuNeeded: false,
                actions: [
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
                            top: MediaQuery
                                .of(context)
                                .size
                                .height * 0.03,
                            right: MediaQuery
                                .of(context)
                                .size
                                .width * 0.04,
                            left: MediaQuery
                                .of(context)
                                .size
                                .width * 0.04,
                          ),
                          child: Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FeedQuoteTab(
                                      title: PartyPageData.addImage,
                                      isSelected: false,
                                      onTap: () async {
                                        final result =
                                        await ReusableMediaPicker.pickMedia(
                                          context,
                                        );

                                        if (!mounted) return;

                                        setState(() {
                                          selectedImages.addAll(result.images);
                                          selectedVideos.addAll(result.videos);
                                        });
                                      },
                                      iconName: PartyPageData.addImageIcon,
                                      height: h * 0.05,
                                      width: w * 0.35,
                                    ),
                                    SizedBox(width: w * 0.03),
                                    //-----Tag Peoples
                                    FeedQuoteTab(
                                      title: PartyPageData.taggedPeople,
                                      isSelected: false,
                                      onTap: () async {
                                        if (taggedPeople.isEmpty) {
                                          await taggedPeopleHandler.addMoreTaggedPeople(
                                            taggedPeople: taggedPeople,
                                            onChanged: () {
                                              if (mounted) {
                                                setState(() {});
                                              }
                                            },
                                          );
                                        } else {
                                          await taggedPeopleHandler.showTaggedPeopleDialog(
                                            taggedPeople: taggedPeople,
                                            onChanged: () {
                                              if (mounted) {
                                                setState(() {});
                                              }
                                            },
                                          );
                                        }
                                      },
                                      iconName: PartyPageData.tagPeopleIcon,
                                      height: h * 0.05,
                                      width: w * 0.45,
                                    ),
                                    SizedBox(width: w * 0.03),

                                    ///-----Schedule
                                    FeedQuoteTab(
                                      title: PartyPageData.schedule,
                                      isSelected: false,
                                      onTap: () async {
                                        // print("Scheduled At:--${getScheduleDateTime}");
                                        final schedule =
                                        await showDialog<
                                            Map<String, String>
                                        >(
                                          context: context,
                                          builder: (_) =>
                                              AddSchedule(
                                                initialDateTime:
                                                getScheduleDateTime() ??
                                                    widget
                                                        .editFeed
                                                        ?.scheduledAt,
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: h * 0.035),
                                      TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        controller: descriptionController,
                                        minLines: 1,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          hintText: "What's your view?",
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                        ),
                                      ),

                                      SizedBox(height: h * 0.035),
                                      // Show schedule only when user has selected it
                                      if (scheduleController
                                          .text
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 10),

                                        CustomTextField(
                                          readOnly: true,
                                          controller: scheduleController,
                                          labelText: PartyPageData.scheduledFor,
                                          suffixIcons:[
                                            InkWell(
                                              onTap: () async {
                                                final shouldDelete =
                                                await showGeneralDialog<
                                                    bool
                                                >(
                                                    context: context,
                                                    barrierDismissible:
                                                    true,
                                                    barrierLabel: 'Delete',
                                                    barrierColor: Colors
                                                        .black
                                                        .withOpacity(0.25),
                                                    transitionDuration:
                                                    const Duration(
                                                      milliseconds: 250,
                                                    ),
                                                    pageBuilder:
                                                        (dialogContext,
                                                        _,
                                                        __,) {
                                                      return popUpMessageForDeleteOrCancel(
                                                        context,
                                                        PartyPageData
                                                            .schedulePostIcon,
                                                        "Would you like to Delete?",
                                                        "Once deleted, this post will be permanently removed.",
                                                            () {},
                                                      );
                                                    },
                                                    transitionBuilder: (
                                                        context, animation,
                                                        secondaryAnimation,
                                                        child) {
                                                      return SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin: const Offset(0,1),
                                                          end: Offset.zero,
                                                        ).animate(
                                                          CurvedAnimation(parent: animation,
                                                            curve: Curves.easeOutCubic,
                                                          ) ,
                                                        ),
                                                        child: child,
                                                      );
                                                    }
                                                );
                                                if (shouldDelete == true && mounted) {
                                                  scheduleController.clear();
                                                  setState(() {});
                                                  // print(
                                                  //     "Scheduled:- ${scheduleController.text}");
                                                }
                                              },
                                              child: SvgPicture.asset(
                                                PartyPageData.crossIcon,
                                                color: Colors.black,
                                              ),
                                            ),

                                            Transform.rotate(
                                            angle: -1,
                                            child: InkWell(
                                              onTap: () async {
                                                final schedule =
                                                await showDialog<
                                                    Map<String, String>
                                                >(
                                                  context: context,
                                                  builder: (_) =>
                                                      AddSchedule(
                                                        initialDateTime:
                                                        getScheduleDateTime(),
                                                      ),
                                                );

                                                if (schedule != null) {
                                                  setState(() {
                                                    scheduleController
                                                        .text =
                                                    "${schedule['date']} ${schedule['time']}";
                                                  });
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                  15,
                                                ),
                                                child: SvgPicture.asset(
                                                  PartyPageData.arrow,
                                                  color: const Color(
                                                    0xFFFE3A31,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                          ],
                                        ),
                                      ],
                                      SizedBox(height: h * 0.035),
                                      if (selectedImages.isNotEmpty ||
                                          selectedVideos.isNotEmpty ||
                                          existingImages.isNotEmpty ||
                                          existingVideos.isNotEmpty) ...[
                                        SizedBox(height: h * 0.01),

                                        ReusableMediaGrid(
                                          existingImages: existingImages,
                                          existingVideos: existingVideos,
                                          selectedImages: selectedImages,
                                          selectedVideos: selectedVideos,
                                          deletedMediaIds: deletedMediaIds,
                                          videoPlayerHelper: videoPlayerHelper,
                                          onPlayVideo: playVideo,
                                          onMediaChanged: () {
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                      SizedBox(height: h * 0.035),

                                      ///--------------Publish button
                                      BlocBuilder<FeedBloc, FeedState>(
                                        builder: (context, state) {
                                          return Center(
                                            child: InkWell(
                                              onTap: state.isPosting
                                                  ? null
                                                  : () async {
                                                await _publishFeed();
                                              },
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
                                                  child: state.isPosting
                                                      ? const SizedBox(
                                                    height: 22,
                                                    width: 22,
                                                    child:
                                                    CircularProgressIndicator(
                                                      strokeWidth:
                                                      2.5,
                                                      color: Colors
                                                          .white,
                                                    ),
                                                  )
                                                      : Row(
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
                                                        widget.isEditMode
                                                            ? "UPDATE"
                                                            : PartyPageData
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
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
