import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_states.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../Reusable Functions/image_video_compressor.dart';
import '../../../../Reusable Functions/reusable_functions.dart';
import '../../../../Reusable Functions/sliver_app_bar_reusable.dart';
import '../../party_page_data.dart';
import '../../reusable_functions.dart';
import '../Event Tab/event_modal.dart';
import '../Feed Tab/reusable_functions.dart';
import '../Feed Tab/reusable_media_grid.dart';
import '../tagged_people_helper.dart';
import '../tagging peoples/tagging_people_model.dart';
import '../tagging peoples/tagging_people_reusable.dart';
import 'development_apis.dart';
import 'development_events.dart';


class AddingDevelopment extends StatefulWidget {
  final int partyId;
  final DevelopmentModel? editDevelopment;
  final String fromWhichPage;
  final int politicianId;
  const AddingDevelopment({
    super.key,
    required this.partyId,
    required this.editDevelopment,required this.fromWhichPage,required this.politicianId});

  bool get isEditMode => editDevelopment != null;

  @override
  State<AddingDevelopment> createState() => _AddingDevelopmentState();
}

class _AddingDevelopmentState extends State<AddingDevelopment> {
  final DevelopmentApis api = DevelopmentApis();
  late TaggedPeopleHandler taggedPeopleHandler;
  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  final TextEditingController fromController =
  TextEditingController();

  final TextEditingController toController = TextEditingController();
  bool isCompressingMedia = false;
  bool showSlowCompressionMessage = false;

  Timer? _compressionTimer;
  List<Tagged> taggedPeople = [];

  ///-----------Adding Images and videos
  List<XFile> selectedImages = [];
  List<XFile> selectedVideos = [];
  List<DevelopmentMedia> existingImages = [];
  List<DevelopmentMedia> existingVideos = [];
  List<int> deletedMediaIds = [];
  final ImagePicker imagePicker = ImagePicker();
  final VideoPlayerHelper videoPlayerHelper = VideoPlayerHelper();
  Future<void> _openTaggingPeople() async {
    final result = await Navigator.push<List<SelectedTaggingPersonModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => TaggingPeopleReusable(
          searchPeople: (String query) async {
            final response = await api.searchBarData(query, null);

            return response.map((person) {
              return TaggingPersonModel(
                id: person.id,
                politicianId: person.politicianId,
                imagePath: person.imagePath,
                name: person.name,
                surname: person.surname,
                designation: person.designation,
              );
            }).toList();
          },
          initialSelectedPeople: taggedPeople.map((person) {
            return SelectedTaggingPersonModel(
              politicianId: person.id ?? 0,
              type: person.type ?? 'POLITICIAN',
              name: person.name ?? '',
              imagePath: person.photoUrl,
            );
          }).toList(),
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      taggedPeople = result.map((person) {
        return Tagged(
          type: person.type,
          id: person.politicianId,
          name: person.name,
          photoUrl: person.imagePath,
        );
      }).toList();
    });
    print("Selected Tagged People:");
    print(taggedPeople.map((e) => e.id).toList());
  }
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
  Future<void> _pickAndCompressMedia() async {
    if (isCompressingMedia) return;

    try {
      final result = await ReusableMediaPicker.pickMedia(context);

      if (!mounted) return;

      final List<XFile> pickedImages = result.images;
      final List<XFile> pickedVideos = result.videos;

      if (pickedImages.isEmpty && pickedVideos.isEmpty) {
        return;
      }

      final List<XFile> pickedFiles = [
        ...pickedImages,
        ...pickedVideos,
      ];

      setState(() {
        isCompressingMedia = true;
        showSlowCompressionMessage = false;
      });

      // Show the message only if processing takes longer than 3 seconds.
      _compressionTimer?.cancel();
      _compressionTimer = Timer(
        const Duration(seconds: 3),
            () {
          if (!mounted || !isCompressingMedia) return;

          setState(() {
            showSlowCompressionMessage = true;
          });

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Your media is large and is taking longer to prepare. '
                      'You can continue adding details while we process it.',
                ),
                duration: Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
      );

      final List<File> originalFiles = pickedFiles
          .map((file) => File(file.path))
          .toList();

      final List<File> compressedFiles =
      await MediaCompressor.compressFiles(originalFiles);

      if (!mounted) return;

      if (compressedFiles.length != originalFiles.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ColorScheme.of(context).error,
            content: Text(
              'Some media could not be processed. Please try selecting them again.',
              style: TextStyle(
                color: ColorScheme.of(context).surface,
              ),
            ),
          ),
        );
        return;
      }

      final List<XFile> finalImages = [];
      final List<XFile> finalVideos = [];

      // Preserve the image/video categories.
      for (int i = 0; i < pickedFiles.length; i++) {
        final XFile original = pickedFiles[i];
        final XFile processed = XFile(compressedFiles[i].path);

        if (pickedImages.any((image) => image.path == original.path)) {
          finalImages.add(processed);
        } else {
          finalVideos.add(processed);
        }
      }

      setState(() {
        selectedImages.addAll(finalImages);
        selectedVideos.addAll(finalVideos);
      });

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ColorScheme.of(context).error,
          content: Text(
            'Failed to process media try again',
            style: TextStyle(
              color: ColorScheme.of(context).surface,
            ),
          ),
        ),
      );
    } finally {
      _compressionTimer?.cancel();
      _compressionTimer = null;

      if (mounted) {
        setState(() {
          isCompressingMedia = false;
          showSlowCompressionMessage = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();


    if (widget.isEditMode) {
      final development = widget.editDevelopment!;

      titleController.text = development.title ?? '';
      descriptionController.text = development.description ?? '';

      fromController.text = development.from ?? '';
      toController.text = development.to ?? '';

      existingImages = development.media
          .where((e) => e.mediaType?.toUpperCase() == 'IMAGE')
          .toList();

      existingVideos = development.media
          .where((e) => e.mediaType?.toUpperCase() == 'VIDEO')
          .toList();

      taggedPeople = List<Tagged>.from(
        development.taggedPoliticians,
      );
    }
  }

  @override
  void dispose() {
    _compressionTimer?.cancel();

    titleController.dispose();
    descriptionController.dispose();
    fromController.dispose();
    toController.dispose();

    super.dispose();
  }
  ///------------Publish


  Future<void> _publishDevelopment() async {
    // Validate title
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title')),
      );
      return;
    }

    // Validate description
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter description')),
      );
      return;
    }

    // Validate development years
    if (fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter development from and to years'),
        ),
      );
      return;
    }

    try {
      final List<File> mediaFiles = [
        ...selectedImages.map((e) => File(e.path)),
        ...selectedVideos.map((e) => File(e.path)),
      ];
      final List<int> taggedPoliticianIds = taggedPeople
          .map((person) => person.id)
          .whereType<int>()
          .toList();

      debugPrint("Selected Tagged People: ${taggedPeople.map((e) => e.id).toList()}");
      debugPrint("IDs before creating model: $taggedPoliticianIds");

      final development = DevelopmentModel(
        id: widget.editDevelopment?.id ?? 0,

        title: titleController.text.trim(),
        description: descriptionController.text.trim(),

        authorPartyId: widget.fromWhichPage == "Party"
            ? widget.partyId
            : null,

        from: fromController.text.trim(),
        to: toController.text.trim(),

        // Preserve existing media
        media: [
          ...existingImages,
          ...existingVideos,
        ],
        taggedPoliticianIds: taggedPoliticianIds,

        taggedPartyIds:
        widget.editDevelopment?.taggedPartyIds ?? const [],
      );

      if (widget.isEditMode) {
        context.read<DevelopmentBloc>().add(
          UpdateDevelopmentEvent(
            development: development,
            mediaFiles: mediaFiles,
            deletedMediaIds: deletedMediaIds,
            partyId: widget.partyId,
            fromWhichPage: widget.fromWhichPage,
            politicianId: widget.politicianId,
          ),
        );
      } else {
        context.read<DevelopmentBloc>().add(
          AddNewDevelopmentEvent(
            partyId: widget.partyId,
            politicianId: widget.politicianId,
            fromWhichPage: widget.fromWhichPage,
            development: development,
            mediaFiles: mediaFiles,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit development: $e'),
        ),
      );
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
    return BlocListener<DevelopmentBloc, DevelopmentState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                 "Successfully published",
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
                title: PartyPageData.development,
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
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        FeedQuoteTab(
                                          title: isCompressingMedia
                                              ? "Preparing..."
                                              : "Add Media",
                                          isSelected: false,
                                          onTap: isCompressingMedia
                                              ? () {}
                                              : _pickAndCompressMedia,
                                          iconName: PartyPageData.addImageIcon,
                                          height: h * 0.05,
                                          width: w * 0.35,
                                        ),

                                        if (isCompressingMedia)
                                          IgnorePointer(
                                            child: Container(
                                              height: h * 0.05,
                                              width: w * 0.35,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.85),
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              child: const Center(
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Color(0xFFFE3A31),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(width: w * 0.03),
                                    //-----Tag Peoples
                                    FeedQuoteTab(
                                        title: PartyPageData.taggedPeople,
                                        isSelected: false,
                                        onTap: _openTaggingPeople,
                                      iconName: PartyPageData.quoteIcon,
                                    ),

                                    SizedBox(width: w * 0.03),

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
                                        controller: titleController,
                                        minLines: 1,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          hintText: "What's your title?",
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                        ),
                                      ),
                                      const Divider(),
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
                                      const Divider(),

// From year
                                      TextFormField(
                                        controller: fromController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'From year (e.g. 2007)',
                                          border: InputBorder.none,
                                        ),
                                      ),

// To year
                                      TextFormField(
                                        controller: toController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'To year (e.g. 2008)',
                                          border: InputBorder.none,
                                        ),
                                      ),

                                      const Divider(),
                                      SizedBox(height: h * 0.035),

                                      SizedBox(height: h * 0.035),
                                      if (selectedImages.isNotEmpty ||
                                          selectedVideos.isNotEmpty ||
                                          existingImages.isNotEmpty ||
                                          existingVideos.isNotEmpty) ...[
                                        SizedBox(height: h * 0.01),

                                        ReusableMediaGrid<DevelopmentMedia>(
                                          existingImages: existingImages,
                                          existingVideos: existingVideos,
                                          selectedImages: selectedImages,
                                          selectedVideos: selectedVideos,
                                          deletedMediaIds: deletedMediaIds,

                                          getMediaUrl: (media) => media.url,
                                          getMediaId: (media) => media.id,

                                          videoPlayerHelper: videoPlayerHelper,
                                          onPlayVideo: playVideo,
                                          onMediaChanged: () {
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                      SizedBox(height: h * 0.035),

                                      ///--------------Publish button
                                      BlocBuilder<DevelopmentBloc, DevelopmentState>(
                                        builder: (context, state) {
                                          return Center(
                                            child: InkWell(
                                              onTap: state.isAdding || isCompressingMedia
                                                  ? null
                                                  : () async {
                                                await _publishDevelopment();
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
                                                  child: state.isAdding
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
