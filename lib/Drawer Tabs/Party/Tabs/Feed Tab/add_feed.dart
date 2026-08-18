import 'package:flutter/cupertino.dart' as state;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/add_quote.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:video_player/video_player.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import '../../../../Reusable Functions/sliver_app_bar_reusable.dart';
import '../../party_page_apis.dart';
import 'apis.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'feed_bloc.dart';
import 'feed_event.dart';
import 'feed_model.dart';

class AddFeed extends StatefulWidget {
  final int partyId;
  const AddFeed({
    super.key,
    required this.partyId
  });

  @override
  State<AddFeed> createState() => _AddFeedState();
}

class _AddFeedState extends State<AddFeed> {
  int selectedTab=0;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController scheduleController=TextEditingController();
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    scheduleController.text =
    "${now.day.toString().padLeft(2, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";
  }
  @override
  void dispose() {
    _videoController?.dispose();

    titleController.dispose();
    descriptionController.dispose();
    scheduleController.dispose();

    super.dispose();
  }
  final FeedApis api = FeedApis();
  List<Tagged> taggedPeople = [];

  ///--------------Adding images and videos
  List<XFile> selectedImages = [];
  List<XFile>selectedVideos=[];
  final ImagePicker imagePicker = ImagePicker();

  VideoPlayerController? _videoController;
  int? playingVideoIndex;
  ///---------Media picking
  Future<void>pickMedia()async{
    try{
      final List<XFile>media=await imagePicker.pickMultipleMedia(
        imageQuality: 85,
      );
      if(media.isNotEmpty){
        setState(() {
          for(final file in media){
            final path=file.path.toLowerCase();
            if (path.endsWith('.mp4') ||
                path.endsWith('.mov') ||
                path.endsWith('.avi') ||
                path.endsWith('.mkv') ||
                path.endsWith('.webm')){
              selectedVideos.add(file);
            }
            else{
              selectedImages.add(file);
            }
          }
        });
      }
    }
    catch(e){
      debugPrint("Error picking media: $e");
    }
  }
  ///-------Open video
  Future<void>playVideo(int index)async{
    try{
      if(playingVideoIndex==index && _videoController!=null &&
      _videoController!.value.isInitialized
      ){
        if(_videoController!.value.isInitialized){
          await _videoController!.pause();
        }
        else{
          await _videoController!.play();
        }
        setState(() {});
        return;

      }
      await _videoController?.dispose();
      final controller=VideoPlayerController.file(
        File(selectedVideos[index].path),
      );
      _videoController=controller;
      playingVideoIndex=index;
      await controller.initialize();
      await controller.play();
      setState(() {});
    }
    catch(e){
      print("Error Playing video: $e");
    }
  }
///Showing tagged peoples
  Future<void> showTaggedPeoplesDialog() async {
    await showDialog(context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(PartyPageData.taggedPeople,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: taggedPeople.length,
                separatorBuilder: (_,__)=>const Divider(),
                  itemBuilder: (_, index){
                  final person=taggedPeople[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: ClipOval(
                        child: SizedBox.expand(
                          child: person.photoUrl != null &&
                              person.photoUrl!.isNotEmpty
                              ? buildImageWidget(
                            person.photoUrl!,
                            fit: BoxFit.cover,
                          )
                              : Text(
                            person.name?.isNotEmpty == true
                                ? person.name![0].toUpperCase()
                                : "?",
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      person.name ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: (){
                        setState(() {
                          taggedPeople.removeAt(index);
                        });
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  );
                  },
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width:  MediaQuery.of(context).size.width * 0.27,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Color(0xFFFF2164)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.015,
                          right: MediaQuery.of(context).size.width * 0.01,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              PartyPageData.crossIcon,
                              color: Color(0xFFFF2164),
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                            Text(
                              'CANCEL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFF2164),
                                fontWeight: FontWeight.w500,
                                fontSize: (MediaQuery.of(context).size.width * 0.04).clamp(14.0, 16.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
SizedBox(width: MediaQuery.of(context).size.width*0.05,),

              InkWell(
                onTap: () async {
                  Navigator.pop(dialogContext);

                  await addMoreTaggedPeople();
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    gradient: GradientColors.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Color(0xFFFF2164)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.015,
                      right: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          PartyPageData.addIcon,
                          color: ColorScheme.of(context).surface,
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                        Text(
                          'ADD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorScheme.of(context).surface,
                            fontWeight: FontWeight.w500,
                            fontSize: (MediaQuery.of(context).size.width * 0.04).clamp(14.0, 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                ],
                )
            ],
          );
        }
    );
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
      setState(() {
        for (final newPerson in result) {
          final alreadyTagged = taggedPeople.any(
                (person) =>
            person.id == newPerson.id &&
                person.type == newPerson.type,
          );

          if (!alreadyTagged) {
            taggedPeople.add(newPerson);
          }
        }
      });
    }
  }
  ///------------Publish
  Future<void> _publishFeed() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter feed title"),
        ),
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter description"),
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

      final feed = FeedModel(
        kind: "POST",
        title: titleController.text.trim(),
        body: descriptionController.text.trim(),
        authorPartyId: widget.partyId,
        tagged: taggedPeople,
        scheduledAt: scheduledAt,
      );

      context.read<FeedBloc>().add(
        AddNewFeedEvent(
          feed: feed,
          mediaFiles: mediaFiles,
          partyId: widget.partyId,
        ),
      );
    } catch (e) {
      debugPrint("Error creating feed event: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to publish feed: $e"),
          ),
        );
      }
    }
  }
///------------------quote
  Future<void> _publishQuote(
      String quoteText,
      String authorName,
      XFile? image,
      ) async {
    try {
      final List<File> mediaFiles = [];

      if (image != null) {
        mediaFiles.add(
          File(image.path),
        );
      }

      final feed = FeedModel(
        kind: "QUOTE",
        quote: {
          "quote": quoteText,
          "author": authorName,
        },

        // IMPORTANT: don't hardcode 4
        authorPartyId: widget.partyId,

        tagged: taggedPeople,
      );

      context.read<FeedBloc>().add(
        AddNewFeedEvent(
          feed: feed,
          mediaFiles: mediaFiles,
          partyId: widget.partyId,
        ),
      );
    } catch (e) {
      debugPrint("Error creating quote event: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to publish quote: $e"),
          ),
        );
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

    return  BlocListener<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.isPostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Successfully published",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );

          debugPrint("NAVIGATING BACK AFTER SUCCESS");

          Navigator.pop(context, true);
        }

        if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage.isNotEmpty
                    ? state.errorMessage
                    : "Failed to publish",
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            ReusableSliverAppBar(
              titleWidget: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Text(
                    selectedTab==0 ? PartyPageData.feedTitle : PartyPageData.quote,
                    style: TextStyle(
                      color: ColorScheme
                          .of(context)
                          .surface,
                      fontWeight: FontWeight.w600,
                      fontSize: (w * 0.06).clamp(14.0, 18.0),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              height: h * 0.06,

              actions: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SvgPicture.asset(
                      PartyPageData.descriptionIcon,
                      height: h * 0.03,
                    ),
                  ),
                ),

                SizedBox(width: w * 0.02),

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

                SizedBox(width: w * 0.03),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FeedQuoteTab(
                                  title: "Feed",
                                  isSelected: selectedTab == 0,
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 0;
                                    });
                                  },
                                  iconName: PartyPageData.feedIcon,
                                ),
                                SizedBox(width: w*0.03,),
                                FeedQuoteTab(
                                  title: "Quote",
                                  isSelected: selectedTab == 1,
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 1;
                                    });
                                  },
                                    iconName: PartyPageData.quoteDiffIcon,
                                ),
                                SizedBox(width: w*0.03,),
                                FeedQuoteTab(
                                  title: "Event",
                                  isSelected: selectedTab == 2,
                                  onTap: () {
                                    setState(() {
                                      selectedTab = 2;
                                    });
                                  },
                                    iconName: PartyPageData.dateIcon,
                                ),
                              ],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child:
                                selectedTab==0? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: h*0.02,),
                                    CustomTextField(
                                      controller: titleController,
                                      labelText: "Feed Title",
                                      isRequired: true,
                                    ),
                                    SizedBox(height: h * 0.035),
                                    CustomTextField(
                                      controller: descriptionController,
                                      labelText: "Description",
                                      isRequired: true,
                                      //height: 150,
                                      maxLines: 5,
                                      keyboardType: TextInputType.multiline,
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: h * 0.035),

                                    ///--------------Tagging
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
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
                                                setState(() {
                                                  for (final newPerson in result) {
                                                    final alreadyTagged = taggedPeople.any(
                                                          (person) =>
                                                      person.id == newPerson.id &&
                                                          person.type == newPerson.type,
                                                    );

                                                    if (!alreadyTagged) {
                                                      taggedPeople.add(newPerson);
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: h * 0.057,
                                              width: w * 0.27,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                gradient: GradientColors.primaryGradient,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  //textAlign: TextAlign.center,
                                                  "@Tag",
                                                  style: TextStyle(
                                                    color: ColorScheme
                                                        .of(context)
                                                        .surface,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: (w * 0.05).clamp(13.0, 16.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                                          ///-----------Tagged Peoples
                                          taggedPeople.isNotEmpty?
                                          InkWell(
                                            onTap: () async {
                                              await showTaggedPeoplesDialog();
                                            },
                                            child: Container(
                                              height: h * 0.057,
                                              width: w * 0.63,
                                              decoration: BoxDecoration(
                                                color: ColorScheme
                                                    .of(context)
                                                    .onSurface
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(
                                                    MediaQuery
                                                        .of(context)
                                                        .size
                                                        .height * 0.02),

                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Row(
                                                  children: [
                                                    if (taggedPeople.isNotEmpty) ...[
                                                      buildTaggedPeopleAvatars(
                                                        taggedPeople,
                                                        h,
                                                        w,
                                                      ),
                                                      SizedBox(width: w * 0.02),
                                                    ],
                                                    Text(
                                                      PartyPageData.taggedPeople,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: (w * 0.04).clamp(
                                                            12.0, 14.0),
                                                      ),),
                                                    SizedBox(width: w * 0.02,),
                                                    Transform.rotate(
                                                      angle: -1,
                                                      child: SvgPicture.asset(
                                                        PartyPageData.arrow,
                                                        color: Color(0xFFFE3A31),),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ):SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: h * 0.035),
                                    ///----Schedule the feed post
                                    CustomTextField(
                                      readOnly: true,
                                        controller: scheduleController,
                                        labelText: PartyPageData.scheduledFor,
                                      suffixIcon:  Transform.rotate(
                                        angle: -1,
                                        child: InkWell(
                                          onTap: () async {
                                            final schedule = await showDialog<Map<String, String>>(
                                              context: context,
                                              builder: (_) => const AddSchedule(),
                                            );

                                            if (schedule != null) {
                                              setState(() {
                                                scheduleController.text =
                                                "${schedule['date']} ${schedule['time']}";
                                              });
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(15),
                                            child: SvgPicture.asset(
                                              PartyPageData.arrow,

                                              color: Color(0xFFFE3A31),),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: h * 0.035),
                                    ///--------------Add image
                                    Row(children: [
                                      Text(PartyPageData.eventImagesVideos,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: w*0.045,
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () async {
                                          await pickMedia();
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context).size.height * 0.05,
                                          width: MediaQuery.of(context).size.width * 0.2,
                                          decoration: BoxDecoration(
                                            gradient: GradientColors.primaryGradient,
                                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*0.03),
                                            border: Border.all(color: Color(0xFFFF2164)),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context).size.width * 0.015,
                                              right: MediaQuery.of(context).size.width * 0.01,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  PartyPageData.add,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: ColorScheme.of(context).surface,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: (MediaQuery.of(context).size.width * 0.04).clamp(14.0, 16.0),
                                                  ),
                                                ),
                                                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                                SvgPicture.asset(
                                                  PartyPageData.addIcon,
                                                  color: ColorScheme.of(context).surface,
                                                  height: MediaQuery.of(context).size.height * 0.017,
                                                ),


                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],),
                                    ///----------------Showing images
                                    if (selectedImages.isNotEmpty || selectedVideos.isNotEmpty) ...[
                                      SizedBox(height: h * 0.01),

                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: selectedImages.length + selectedVideos.length,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 3,
                                        ),
                                        itemBuilder: (context, index) {

                                          // ---------------- IMAGE ----------------
                                          if (index < selectedImages.length) {
                                            final image = selectedImages[index];

                                            return Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Image.file(
                                                      File(image.path),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),

                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedImages.removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 22,
                                                      width: 22,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          // ---------------- VIDEO ----------------

                                          final videoIndex = index - selectedImages.length;

                                          return Stack(
                                            children: [
                                              Positioned.fill(
                                                child: InkWell(
                                                  onTap: () async {
                                                    await playVideo(videoIndex);
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Container(
                                                      color: Colors.black87,
                                                      child: playingVideoIndex == videoIndex &&
                                                          _videoController != null &&
                                                          _videoController!.value.isInitialized
                                                          ? Center(
                                                        child: AspectRatio(
                                                          aspectRatio: _videoController!.value.aspectRatio,
                                                          child: VideoPlayer(_videoController!),
                                                        ),
                                                      )
                                                          : const Center(
                                                        child: Icon(
                                                          Icons.play_circle_fill,
                                                          color: Colors.white,
                                                          size: 45,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Positioned(
                                                bottom: 5,
                                                left: 5,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.videocam,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 3),
                                                      Text(
                                                        "VIDEO",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedVideos.removeAt(videoIndex);
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 22,
                                                    width: 22,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                    SizedBox(height: h * 0.035),
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
                                                      PartyPageData.publish,
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
                                      },
                                    ),
                                    SizedBox(height: h * 0.035),
                                  ],
                                ): AddQuote(
                                  taggedPeople: taggedPeople,
                                  onAddTaggedPeople: addMoreTaggedPeople,
                                  onShowTaggedPeople: showTaggedPeoplesDialog,
                                  onPublishQuote: _publishQuote,
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
    );
  }
}
