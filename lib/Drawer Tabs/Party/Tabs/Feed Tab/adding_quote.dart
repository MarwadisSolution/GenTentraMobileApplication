import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/apis.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_state.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import '../../../../Reusable Functions/sliver_app_bar_reusable.dart';
import '../../party_page_data.dart';
import '../../reusable_functions.dart';
import 'feed_bloc.dart';
import 'feed_event.dart';
import 'feed_model.dart';
import 'reusable_functions.dart';

class AddingQuote extends StatefulWidget {
  final int partyId;
  final FeedModel? editQuote;

  const AddingQuote({
    super.key,
    required this.partyId,
    required this.editQuote,
  });

  bool get isEditMode => editQuote != null;

  @override
  State<AddingQuote> createState() => _AddingQuoteState();
}

class _AddingQuoteState extends State<AddingQuote> {
  final FeedApis api = FeedApis();
  TextEditingController quoteController = TextEditingController();
  TextEditingController authorNameController = TextEditingController();
  TextEditingController scheduleController = TextEditingController();
  String? initialImage;
  List<Tagged> taggedPeople = [];
  List<int> deletedMediaIds = [];
  XFile? selectedImage;
  FeedMedia? initialMedia;
  final ImagePicker imagePicker = ImagePicker();
  bool removeInitialImage = false;
  Future<void> showTaggedPeoplesDialog() async {
    await TaggedPeopleDialog.show(
      context: context,
      taggedPeople: taggedPeople,
      onAddMore: addMoreTaggedPeople,
    );

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
  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 85
      );
      if(image!=null){
        setState(() {
          selectedImage=image;
        });
      }
    }
    catch(e){
      debugPrint("Error picking image: $e");
    }
  }
  Future<void> addMoreTaggedPeople() async {
    final result = await LeaderPickerDialog.show(
      context: context,
      searchFunction: (String text) {
        return api.searchBarData(text, null);
      },
      isNew: false,
      single: false,
      existingTagged: taggedPeople,
    );

    if (result != null) {
      final List<Tagged> added = (result['added'] as List<Tagged>?) ?? [];

      final List<dynamic> removed = (result['removed'] as List<dynamic>?) ?? [];

      setState(() {
        // Remove previously tagged people
        taggedPeople.removeWhere((person) => removed.contains(person.id));

        // Add newly selected people
        for (final newPerson in added) {
          final alreadyTagged = taggedPeople.any(
            (person) =>
                person.id == newPerson.id && person.type == newPerson.type,
          );

          if (!alreadyTagged) {
            taggedPeople.add(newPerson);
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.editQuote != null) {
      final data = FeedHelper.initializeEditData(
        "QUOTE",
        widget.editQuote!,
      );

      taggedPeople = data.taggedPeoples;
      initialImage = data.initialImage;

      if (data.existingImages != null &&
          data.existingImages!.isNotEmpty) {
        initialMedia = data.existingImages!.first;
      }

      quoteController.text = data.quote!;
      authorNameController.text = data.authorName!;

      // Show existing schedule when editing
      if (widget.editQuote!.scheduledAt != null) {
        final scheduled = widget.editQuote!.scheduledAt!;

        final hour = scheduled.hour == 0
            ? 12
            : scheduled.hour > 12
            ? scheduled.hour - 12
            : scheduled.hour;

        final period = scheduled.hour >= 12 ? "PM" : "AM";

        scheduleController.text =
        "${scheduled.day.toString().padLeft(2, '0')}-"
            "${scheduled.month.toString().padLeft(2, '0')}-"
            "${scheduled.year} "
            "${hour.toString().padLeft(2, '0')}:"
            "${scheduled.minute.toString().padLeft(2, '0')} "
            "$period";
      }
    }
  }

  ///-------- Publish quote
  Future<void> _publishQuote(
    String quoteText,
    String authorName,
    XFile? image,
  ) async {
    try {
      final List<File> mediaFiles = [];
      DateTime? scheduledAt;

      if (scheduleController.text.trim().isNotEmpty) {
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
      if (image != null) {
        mediaFiles.add(File(image.path));
      }
      final feed = FeedModel(
        id: widget.editQuote?.id,
        kind: "QUOTE",
        quote: {"quote": quoteText, "author": authorName},
        authorPartyId: widget.partyId,
        tagged: taggedPeople,
        media: removeInitialImage
            ? []
            : initialMedia != null
            ? [initialMedia!]
            : [],
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
      debugPrint("Error creating quote event: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ColorScheme.of(context).error,
            content: Text(
              "Failed to publish quote, please try again",
              style: TextStyle(color: ColorScheme.of(context).surface),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return BlocListener<FeedBloc, FeedState>(
        listener: (context, state){
          if(state
              .isPostSuccess){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  state.isOfflineQueued
                      ? "Saved offline. It will be published automatically when internet is restored."
                      : "Successfully published",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            );
            Navigator.pop(context,true);
          }
          if (state.isError) {
            debugPrint("Error in adding feed:- ${state.errorMessage}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: ColorScheme.of(context).error,
                content: Text(
                  "Failed to publish",
                  style: TextStyle(
                      color: ColorScheme.of(context).surface
                  ),
                ),
              ),
            );
          }
        },
        child: GestureDetector(
        onTap: (){
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
                          gradient: GradientColorsForBellowAppbar.gradientBelowAppbar,
                        ),
                      ),
                      Positioned.fill(
                          top: h*0.02,
                          child:Container(
                            height: h,width: w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            child: Padding(padding: EdgeInsets.only(
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
                                  child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //-----Tag Peoples
                                      FeedQuoteTab(
                                        title: PartyPageData.taggedPeople,
                                        isSelected: false,
                                        onTap: () async {
                                          if (taggedPeople.isEmpty) {
                                            await addMoreTaggedPeople();
                                          } else {
                                            await showTaggedPeoplesDialog();
                                          }
                                        },
                                        iconName: PartyPageData.tagPeopleIcon,
                                        height: h*0.05, width: w*0.45,
                                      ),
                                      SizedBox(width: w*0.03,),
                                      ///-----Schedule
                                      FeedQuoteTab(
                                        title: PartyPageData.schedule,
                                        isSelected: false,
                                        onTap: () async {
                                          final schedule = await showDialog<Map<String, String>>(
                                            context: context,
                                            builder: (_) => AddSchedule(
                                              initialDateTime:
                                              getScheduleDateTime() ?? widget.editQuote?.scheduledAt,
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
                                        height: h*0.05, width: w*0.35,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: SingleChildScrollView(

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: h*0.035,),
                                      ///-----------Adding Quote
                                      Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: w * 0.75,
                                          height: h * 0.28,
                                          child: TextFormField(
                                            controller: quoteController,

                                            maxLines: 3,
                                            maxLength: 50,

                                            keyboardType: TextInputType.multiline,

                                            textAlign: TextAlign.center,
                                            textAlignVertical: TextAlignVertical.center,

                                            style: TextStyle(
                                              fontSize: h * 0.038,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              letterSpacing: 0.31,
                                            ),

                                            decoration: InputDecoration(
                                              hintText: PartyPageData.sampleQuote,

                                              hintStyle: TextStyle(
                                                fontSize: h * 0.038,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFC0C0C0).withOpacity(0.3),
                                                letterSpacing: 0.31,
                                              ),

                                              counter: ValueListenableBuilder<TextEditingValue>(
                                                valueListenable: quoteController,
                                                builder: (context, value, child) {
                                                  final remaining = 50 - value.text.length;

                                                  return SizedBox(
                                                    width: double.infinity,
                                                    child: Text(
                                                      "Max $remaining characters",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color(0xFF777777),
                                                        fontSize: h * 0.022,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                              label: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: PartyPageData.addQuote,
                                                      style: TextStyle(
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.044,
                                                        color: ColorScheme
                                                            .of(context)
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: " *",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: w * 0.04,
                                                vertical: h * 0.015,
                                              ),

                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: ColorScheme
                                                      .of(context)
                                                      .onSurface
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),

                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: ColorScheme
                                                      .of(context)
                                                      .onSurface
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ///----------Adding author name
                                      SizedBox(height: h * 0.017,),
                                      Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: w * 0.75,
                                          height: h * 0.18,
                                          child: TextFormField(
                                            controller: authorNameController,

                                            maxLines: 2,

                                            keyboardType: TextInputType.multiline,

                                            textAlign: TextAlign.center,
                                            textAlignVertical: TextAlignVertical.center,

                                            style: TextStyle(
                                              fontSize: h * 0.038,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              letterSpacing: 0.31,
                                            ),

                                            decoration: InputDecoration(
                                              hintText: PartyPageData.sampleAuthorName,

                                              hintStyle: TextStyle(
                                                fontSize: h * 0.038,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFC0C0C0).withOpacity(0.3),
                                                letterSpacing: 0.31,
                                              ),


                                              label: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: PartyPageData.authorName,
                                                      style: TextStyle(
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width * 0.044,
                                                        color: ColorScheme
                                                            .of(context)
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: " *",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: w * 0.04,
                                                vertical: h * 0.02,
                                              ),

                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: ColorScheme
                                                      .of(context)
                                                      .onSurface
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),

                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: ColorScheme
                                                      .of(context)
                                                      .onSurface
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Show schedule only when a schedule has been selected
                                      if (scheduleController.text.isNotEmpty) ...[
                                        SizedBox(height: h * 0.025),

                                        CustomTextField(
                                          readOnly: true,
                                          controller: scheduleController,
                                          labelText: PartyPageData.scheduledFor,
                                          suffixIcons:[
                                            InkWell(
                                              onTap: ()async{
                                                final shouldDelete=await showGeneralDialog<bool>(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    barrierLabel: 'Delete',
                                                    barrierColor: Colors.black.withOpacity(0.25),
                                                    transitionDuration: const Duration(milliseconds: 250),
                                                    pageBuilder: (dialogContext,_,__){
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
                                                await showDialog<Map<String, String>>(
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
                                              child: Padding(
                                                padding: const EdgeInsets.all(15),
                                                child: SvgPicture.asset(
                                                  PartyPageData.arrow,
                                                  color: const Color(0xFFFE3A31),
                                                ),
                                              ),
                                            ),
                                          ),
                              ],
                                        ),
                                      ],

                                      SizedBox(height: h * 0.025),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: w * 0.12,
                                            height: w * 0.12,
                                            decoration: BoxDecoration(
                                              color: selectedImage == null &&
                                                  (initialImage == null || removeInitialImage)
                                                  ? Colors.black
                                                  : Colors.black.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                onTap: selectedImage == null &&
                                                    (initialImage == null || removeInitialImage)
                                                    ? pickImage
                                                    : null,
                                                customBorder: const CircleBorder(),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    PartyPageData.addIcon,
                                                    color: ColorScheme.of(context).surface,
                                                    height: w * 0.045,
                                                    width: w * 0.045,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: w * 0.07),
                                          Container(
                                            width: w * 0.29,
                                            height: w * 0.29,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade200,
                                            ),
                                            child: ClipOval(
                                              child: selectedImage != null
                                                  ? Image.file(
                                                File(selectedImage!.path),
                                                fit: BoxFit.cover,
                                              )
                                                  : initialImage != null && !removeInitialImage
                                                  ? buildImageWidget(
                                                initialImage!,
                                                fit: BoxFit.cover,
                                              )
                                                  : Icon(
                                                Icons.image,
                                                size: w * 0.17,
                                                color: ColorScheme.of(context)
                                                    .onSurface
                                                    .withOpacity(0.2),
                                              ),

                                            ),
                                          ),
                                          SizedBox(width: w * 0.07),
                                          InkWell(
                                            onTap: () {
                                              if (selectedImage != null ) {
                                                setState(() {
                                                  selectedImage = null;
                                                });
                                              }
                                              else if (initialImage != null && !removeInitialImage) {
                                                setState(() {
                                                  removeInitialImage = true;
                                                });
                                              }
                                            },
                                            customBorder: const CircleBorder(),
                                            child: Container(
                                              width: w * 0.12,
                                              height: w * 0.12,
                                              decoration: BoxDecoration(
                                                color: selectedImage != null ||
                                                    (initialImage != null && !removeInitialImage)
                                                    ? Colors.black
                                                    : Colors.black.withOpacity(0.3),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  PartyPageData.deleteIcon,
                                                  color: Colors.white,

                                                  height: w * 0.045,
                                                  width: w * 0.045,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],),
                                      ///--------------Publish button
                                      SizedBox(height: h*0.051,),
                                      BlocBuilder<FeedBloc, FeedState>(
                                        builder: (context, state) {
                                          return Center(
                                            child: InkWell(
                                              onTap: state.isPosting
                                                  ? null
                                                  : () async {
                                                await _publishQuote(quoteController.text, authorNameController.text,selectedImage );
                                              },
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
                                                  child: state.isPosting
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
                                                        widget.isEditMode
                                                            ? "UPDATE"
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
                                          );
                                        },),
                                      SizedBox(height: h*0.051,),
                                    ],
                                  ),
                                )
                                )
                              ],
                            ),
                            ),

                          )
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
    ),
    );
  }
}
