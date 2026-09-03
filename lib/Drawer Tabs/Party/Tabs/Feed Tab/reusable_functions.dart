import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PickedMedia {
  final List<XFile> images;
  final List<XFile> videos;

  const PickedMedia({required this.images, required this.videos});
}

class ReusableMediaPicker {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<PickedMedia> pickMedia(
  BuildContext context,
      ) async {
    final List<XFile> media = await _imagePicker.pickMultipleMedia(
      imageQuality: 85,
    );

    final List<XFile> images = [];
    final List<XFile> videos = [];

    for (final file in media) {
      final path = file.path.toLowerCase();

      if (path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv') ||
          path.endsWith('.webm')) {
        videos.add(file);
      } else if (path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif') ||
          path.endsWith('.webp') ||
          path.endsWith('.svg') ||
          path.endsWith('.bmp') ||
          path.endsWith('.tiff') ||
          path.endsWith('.heic')) {
        images.add(file);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red,
                content: Text("add image or videos only",
                style: TextStyle(color: Colors.white),
                )));
      }
    }
    print("Images:$images");
    print("Videos: $videos");
    return PickedMedia(images: images, videos: videos);
  }
}

///-----------------initializeEditData------------------
class EditFeedData {

  final String? description;
  final List<Tagged> taggedPeoples;
  final List<FeedMedia>? existingImages;
  final List<FeedMedia>? existingVideos;
  final String? initialImage;
 final String? quote;
 final String? authorName;
  const EditFeedData({
     this.description,
    required this.taggedPeoples,
     this.existingImages,
     this.existingVideos,
    this.initialImage,
    this.quote,
    this.authorName,

  });
}

class FeedHelper {
  static EditFeedData initializeEditData(String kind,FeedModel feed) {
    final media = feed.media ?? [];
    // print("Data: ${feed.quote?["quote"]} }");
    return kind=="FEED"?EditFeedData(
      description: feed.body ?? "",
      taggedPeoples: List<Tagged>.from(feed.tagged ?? []),
      existingImages: media
          .where((media) => media.mediaType?.toUpperCase() == "IMAGE")
          .toList(),
      existingVideos: media
          .where((media) => media.mediaType?.toUpperCase() == "VIDEO")
          .toList(),
    ):
    EditFeedData(

      taggedPeoples:  List<Tagged>.from(feed.tagged ?? []),
      existingImages: media
          .where(
            (media) =>
        media.mediaType?.toUpperCase() == "IMAGE",
      )
          .toList(),
      initialImage: feed.media?.isNotEmpty == true
        ? feed.media?.first.url
        : null,
      quote: feed.quote?["quote"],
      authorName: feed.quote?["author"],
    )
    ;
  }
}

///---------------------------
///----------------------Play Video
class VideoPlayerHelper {
  VideoPlayerController? controller;
  int? playingVideoIndex;
  bool playingExistingVideo = false;

  Future<void> playVideo({
    required BuildContext context,
    required int index,
    required bool isExisting,
    String? existingVideoUrl,
    String? localVideoPath,
  }) async {
    try {
      if (playingVideoIndex == index &&
          playingExistingVideo == isExisting &&
          controller != null &&
          controller!.value.isInitialized) {
        if (controller!.value.isPlaying) {
          await controller!.pause();
        } else {
          await controller!.play();
        }
        return;
      }
      await controller?.dispose();
      controller = null;
      late VideoPlayerController newController;
      if (isExisting) {
        if (existingVideoUrl == null || existingVideoUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Video URL is not available.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          return;
        }
        newController = VideoPlayerController.networkUrl(
          Uri.parse(existingVideoUrl),
        );
      } else {
        if (localVideoPath == null || localVideoPath.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Video file is not available.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
          return;
        }
        newController = VideoPlayerController.file(File(localVideoPath));
      }
      controller = newController;
      playingVideoIndex = index;
      playingExistingVideo = isExisting;
      await newController.initialize();
      await newController.play();
    } catch (e) {
      if (context.mounted) {
        debugPrint("Error Playing video: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
              "Unable to play video. Please try again.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }
  Future<void> stopVideo() async {
    await controller?.pause();
    await controller?.dispose();

    controller = null;
    playingVideoIndex = null;
    playingExistingVideo = false;
  }
  Future<void> dispose() async {
    await controller?.dispose();
    controller = null;
  }
}

///--------------------------
///---------------Tagged Peoples
class TaggedPeopleDialog {
  static Future<void> show({
    required BuildContext context,
    required List<Tagged> taggedPeople,
    required Future<void> Function() onAddMore,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _TaggedPeopleDialogContent(
          taggedPeople: taggedPeople,
          onAddMore: onAddMore,
        );
      },
    );
  }
}
class _TaggedPeopleDialogContent extends StatefulWidget {
  final List<Tagged> taggedPeople;
  final Future<void> Function() onAddMore;

  const _TaggedPeopleDialogContent({
    required this.taggedPeople,
    required this.onAddMore,
  });

  @override
  State<_TaggedPeopleDialogContent> createState() =>
      _TaggedPeopleDialogContentState();
}

class _TaggedPeopleDialogContentState
    extends State<_TaggedPeopleDialogContent> {
  late List<Tagged> taggedPeople;

  @override
  void initState() {
    super.initState();

    // Create a local copy for the dialog.
    taggedPeople = List<Tagged>.from(widget.taggedPeople);
  }

  void removePerson(int index) {
    setState(() {
      taggedPeople.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        PartyPageData.taggedPeople,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: taggedPeople.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final person = taggedPeople[index];

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
              // trailing: InkWell(
              //   onTap: () {
              //     removePerson(index);
              //   },
              //   child: const Icon(
              //     Icons.close,
              //     color: Colors.black,
              //   ),
              // ),
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
                width: MediaQuery.of(context).size.width * 0.27,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFFF2164),
                  ),
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
                        color: const Color(0xFFFF2164),
                        height:
                        MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Text(
                        'CANCEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFFF2164),
                          fontWeight: FontWeight.w500,
                          fontSize:
                          (MediaQuery.of(context).size.width * 0.04)
                              .clamp(14.0, 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
            ),

            InkWell(
              onTap: () async {
                Navigator.pop(context);
                await widget.onAddMore();
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  gradient: GradientColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFFF2164),
                  ),
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
                        height:
                        MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Text(
                        'ADD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorScheme.of(context).surface,
                          fontWeight: FontWeight.w500,
                          fontSize:
                          (MediaQuery.of(context).size.width * 0.04)
                              .clamp(14.0, 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

///----------------------------
class FeedMediaWidget extends StatelessWidget {
  final List<FeedMedia> media;

  const FeedMediaWidget({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    if (media.length == 1) {
      return _buildSingleMedia(context);
    }

    if (media.length == 2) {
      return _buildTwoMedia(context);
    }

    return _buildThreeOrMoreMedia(context);
  }

  // ============================================================
  // 1 MEDIA
  // ============================================================

  Widget _buildSingleMedia(BuildContext context) {
    return _mediaTile(
      context: context,
      index: 0,
    );
  }

  // ============================================================
  // 2 MEDIA
  // ============================================================

  Widget _buildTwoMedia(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(
            child: _mediaTile(
              context: context,
              index: 0,
              // borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(12),
              //   bottomLeft: Radius.circular(12),
              // ),
            ),
          ),

          const SizedBox(width: 3),

          Expanded(
            child: _mediaTile(
              context: context,
              index: 1,
              // borderRadius: const BorderRadius.only(
              //   topRight: Radius.circular(12),
              //   bottomRight: Radius.circular(12),
              // ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3 OR MORE MEDIA
  // ============================================================

  Widget _buildThreeOrMoreMedia(BuildContext context) {
    final remaining = media.length - 3;

    return SizedBox(
      height: 360,
      child: Column(
        children: [
          // ---------------- TOP LARGE MEDIA ----------------
          Expanded(
            flex: 2,
            child: _mediaTile(
              context: context,
              index: 0,
              // borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(12),
              //   topRight: Radius.circular(12),
              // ),
            ),
          ),

          const SizedBox(height: 3),

          // ---------------- BOTTOM TWO MEDIA ----------------
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(child: _mediaTile(context: context, index: 1)),

                const SizedBox(width: 3),

                Expanded(
                  child: _mediaTile(
                    context: context,
                    index: 2,

                    overlayCount: remaining > 0 ? remaining : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON MEDIA TILE
  // ============================================================

  Widget _mediaTile({
    required BuildContext context,
    required int index,
    double? height,
    BorderRadius borderRadius = BorderRadius.zero,
    int? overlayCount,
  }) {
    return GestureDetector(
      onTap: () {
        _openViewer(context, index);
      },
      child: Container(
        height: height,
        width: double.infinity,
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _mediaPreview(media[index]),

              if (overlayCount != null)
                Container(
                  color: Colors.black.withOpacity(0.55),
                  alignment: Alignment.center,
                  child: Text(
                    "+$overlayCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (media[index].mediaType == "VIDEO")
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  // ============================================================
  // MEDIA PREVIEW
  // ============================================================

  Widget _mediaPreview(FeedMedia item) {
    final url = item.url ?? "";

    if (item.mediaType == "VIDEO") {
      return VideoPreview(url: url);
    }

    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FULL SCREEN VIEWER
  // ============================================================

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FeedMediaViewer(media: media, initialIndex: initialIndex);
        },
      ),
    );
  }
}

class VideoPreview extends StatefulWidget {
  final String url;

  const VideoPreview({super.key, required this.url});

  @override
  State<VideoPreview> createState() => VideoPreviewState();
}

class VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController controller;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    print("VIDEO URL: ${widget.url}");

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await controller.initialize();

      print("VIDEO INITIALIZED");
      print("VIDEO SIZE: ${controller.value.size}");
      print("VIDEO DURATION: ${controller.value.duration}");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("VIDEO INITIALIZATION ERROR: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.black,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined, color: Colors.grey, size: 38),
            SizedBox(height: 8),
            Text(
              "Unable to load video",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedMediaViewer extends StatefulWidget {
  final List<FeedMedia> media;
  final int initialIndex;

  const FeedMediaViewer({
    super.key,
    required this.media,
    required this.initialIndex,
  });

  @override
  State<FeedMediaViewer> createState() => _FeedMediaViewerState();
}

class _FeedMediaViewerState extends State<FeedMediaViewer> {
  late PageController pageController;

  late int currentIndex;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        title: Text(
          "${currentIndex + 1} / ${widget.media.length}",
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: PageView.builder(
        controller: pageController,
        itemCount: widget.media.length,

        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        itemBuilder: (context, index) {
          final item = widget.media[index];

          if (item.mediaType == "VIDEO") {
            return FullScreenVideo(url: item.url ?? "");
          }

          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,

            child: Center(
              child: Image.network(
                item.url ?? "",
                fit: BoxFit.contain,

                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, color: Colors.white, size: 60);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenVideo extends StatefulWidget {
  final String url;

  const FullScreenVideo({super.key, required this.url});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late VideoPlayerController controller;

  bool showPlayButton = true;

  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await controller.initialize();

      if (!mounted) return;

      setState(() {});

      // Automatically start video
      await controller.play();

      // Show button initially, then hide after 2 seconds
      _startHideTimer();
    } catch (e) {
      debugPrint("FULL SCREEN VIDEO ERROR: $e");
    }
  }

  void togglePlay() {
    if (!controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {
      showPlayButton = true;
    });

    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showPlayButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),

          // Play / Pause button
          AnimatedOpacity(
            opacity: showPlayButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !showPlayButton,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///----------------Quote showing design
Widget FeedQuoteWidget(final int? feedId,
    final String quote,
    final String author,
    final List<FeedMedia> media,
    BuildContext context,) {
  return Container(
    decoration: BoxDecoration(),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: MediaQuery
                .of(context)
                .size
                .width * 0.04,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SvgPicture.asset(PartyPageData.quoteIcon),
          ),
        ),
        SizedBox(height: MediaQuery
            .of(context)
            .size
            .height * 0.081),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery
                  .of(context)
                  .size
                  .width * 0.08,
            ),
            child: Text(
              quote,

              textAlign: TextAlign.center,
              maxLines: 5,

              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.1,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery
                    .of(context)
                    .size
                    .height * 0.035,
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery
            .of(context)
            .size
            .height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: SizedBox.expand(
                  child:
                  media.isNotEmpty &&
                      media[0].url != null &&
                      media[0].url!.isNotEmpty
                      ? buildImageWidget(
                    media[0].url!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: MediaQuery
                .of(context)
                .size
                .width * 0.03),
            Text(
              author,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery
                    .of(context)
                    .size
                    .height * 0.019,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery
            .of(context)
            .size
            .height * 0.081),
        Padding(
          padding: EdgeInsets.only(
            right: MediaQuery
                .of(context)
                .size
                .width * 0.04,
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              angle: 3.14,
              child: SvgPicture.asset(PartyPageData.quoteIcon),
            ),
          ),
        ),
        SizedBox(height: MediaQuery
            .of(context)
            .size
            .height * 0.025),
      ],
    ),
  );
}

///------------------Search Bar for tagging
class LeaderPickerDialog extends StatefulWidget {
  final Future<List<LeaderModel>> Function(String text) searchFunction;
  final bool isNew;
  final bool single;
  final List<Tagged> existingTagged;

  const LeaderPickerDialog({
    super.key,
    required this.searchFunction,
    required this.isNew,
    required this.single,
    this.existingTagged = const [],
  });

  static Future<Map<String, dynamic>?> show({
    required Future<List<LeaderModel>> Function(String text) searchFunction,
    required bool isNew,
    required bool single,
    required BuildContext context,
    List<Tagged> existingTagged = const [],
  }) {
    return showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          LeaderPickerDialog(
            searchFunction: searchFunction,
            isNew: isNew,
            single: single,
            existingTagged: existingTagged,
          ),
    );
  }

  @override
  State<LeaderPickerDialog> createState() => _LeaderPickerDialogState();
}

class _LeaderPickerDialogState extends State<LeaderPickerDialog> {
  final TextEditingController controller = TextEditingController();

  List<LeaderModel> leaders = [];

  List<LeaderModel> selectedLeaders = [];

  List<LeaderModel> removedExistingLeaders = [];

  bool loading = false;

  Timer? timer;

  Future<void> search(String text) async {
    if (text.isEmpty) {
      setState(() {
        leaders = [];
      });
      return;
    }

    setState(() => loading = true);

    try {
      leaders = await widget.searchFunction(text);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void debounce(String value) {
    timer?.cancel();

    timer = Timer(const Duration(milliseconds: 300), () => search(value));
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
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
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.9,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.75,
        child: Stack(
          children: [
            if (leaders.isEmpty && controller.text.isEmpty)
              Center(child: Text("Please search")),
            if (leaders.isEmpty && controller.text.isNotEmpty)
              Center(child: Text("No results found")),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Top Leaders",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(12, 12, 12, 1),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    PartyPageData.searchBy,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: h * 0.065,
                    child: TextField(
                      controller: controller,
                      onChanged: debounce,
                      cursorColor: Colors.black,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: PartyPageData.searchBy,
                        hintStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Color.fromRGBO(199, 199, 199, 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Semi-circle
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(199, 199, 199, 0.2),
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(199, 199, 199, 0.2),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color.fromRGBO(199, 199, 199, 0.2),
                            width: 2,
                          ),
                        ),

                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Container(
                            height: 30,
                            width: 79,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(194, 193, 193, 1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'SEARCH',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Divider(color: Color.fromRGBO(215, 215, 220, 1)),
                  SizedBox(height: h * 0.01),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: h * 0.10),
                      itemCount: leaders.length,
                      itemBuilder: (_, index) {
                        final leader = leaders[index];

                        final alreadyTagged = widget.existingTagged.any(
                              (e) => e.id == leader.id,
                        );

                        final isSelected = selectedLeaders.any(
                              (e) => e.id == leader.id,
                        );

                        final isRemoved = removedExistingLeaders.any(
                              (e) => e.id == leader.id,
                        );

                        final checked =
                            !isRemoved && (alreadyTagged || isSelected);
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                final alreadyTagged = widget.existingTagged.any(
                                      (e) => e.id == leader.id,
                                );

                                setState(() {
                                  // Previously tagged leader
                                  if (alreadyTagged) {
                                    final removedIndex = removedExistingLeaders
                                        .indexWhere((e) => e.id == leader.id);

                                    if (removedIndex != -1) {
                                      // User selected it again
                                      removedExistingLeaders.removeAt(
                                        removedIndex,
                                      );
                                    } else {
                                      // User wants to untag it
                                      removedExistingLeaders.add(leader);
                                    }

                                    return;
                                  }

                                  // Newly selected leader
                                  final index = selectedLeaders.indexWhere(
                                        (e) => e.id == leader.id,
                                  );

                                  if (index != -1) {
                                    selectedLeaders.removeAt(index);
                                  } else {
                                    if (widget.single) {
                                      selectedLeaders.clear();
                                    }

                                    selectedLeaders.add(leader);
                                  }
                                });
                              },
                              leading: CircleAvatar(
                                backgroundImage: leader.image != null
                                    ? NetworkImage('$api${leader.image!}')
                                    : null,
                                child: leader.image == null
                                    ? Text(leader.name[0])
                                    : null,
                              ),
                              title: Text(
                                leader.name,
                                style: TextStyle(
                                  color: Color.fromRGBO(46, 46, 56, 1),
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                "${leader.designation.toUpperCase()}, ${leader
                                    .uniqueId.toUpperCase()}",
                                style: TextStyle(
                                  color: Color.fromRGBO(101, 101, 121, 1),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Icon(
                                Icons.check_circle,
                                color: checked ? Colors.green : Colors.grey,
                              ),
                            ),
                            const Divider(
                              color: Color.fromRGBO(215, 215, 220, 1),
                              height: 1,
                              thickness: 1,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: h * 0.08,
                color: Colors.white,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: w * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: h * 0.05,
                            width: w * 0.27,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Color(0xFFFF2164)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: w * 0.015,
                                right: w * 0.01,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    PartyPageData.crossIcon,
                                    color: Color(0xFFFF2164),
                                    height: h * 0.02,
                                  ),
                                  SizedBox(width: w * 0.02),
                                  Text(
                                    'CANCEL',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFFF2164),
                                      fontWeight: FontWeight.w500,
                                      fontSize: (w * 0.04).clamp(14.0, 16.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: w * 0.07),
                        InkWell(
                          onTap: () {
                            if (selectedLeaders.isEmpty &&
                                removedExistingLeaders.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select a leader"),
                                ),
                              );
                              return;
                            }

                            final List<Tagged> taggedLeaders = selectedLeaders
                                .map((leader) {
                              return Tagged(
                                type: "POLITICIAN",
                                id: leader.id,
                                name: leader.name,
                                photoUrl: leader.image,
                              );
                            })
                                .toList();

                            Navigator.pop(context, {
                              'added': taggedLeaders,
                              'removed': removedExistingLeaders
                                  .map((e) => e.id)
                                  .toList(),
                            });
                          },
                          child: Container(
                            height: h * 0.05,
                            width: w * 0.2,
                            decoration: BoxDecoration(
                              gradient: GradientColors.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Color(0xFFFF2164)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: w * 0.015,
                                right: w * 0.01,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    PartyPageData.addIcon,
                                    color: ColorScheme
                                        .of(context)
                                        .surface,
                                    height: h * 0.02,
                                  ),
                                  SizedBox(width: w * 0.02),
                                  Text(
                                    'ADD',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorScheme
                                          .of(context)
                                          .surface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: (w * 0.04).clamp(14.0, 16.0),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///--------------Set time and date

class AddSchedule extends StatefulWidget {
  final DateTime? initialDateTime;
  const AddSchedule({super.key,
    this.initialDateTime,
  });

  @override
  State<AddSchedule> createState() => _AddScheduleState();
}

class _AddScheduleState extends State<AddSchedule> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String? errorMessage;

  bool isSelectedDateTimeValid() {
    if (selectedDate == null || selectedTime == null) {
      return false;
    }

    final now = DateTime.now();

    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    return selectedDateTime.isAfter(now);
  }
  @override
  void initState() {
    super.initState();

    if (widget.initialDateTime != null) {
      final dateTime = widget.initialDateTime!;

      selectedDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

      selectedTime = TimeOfDay(
        hour: dateTime.hour,
        minute: dateTime.minute,
      );

      dateController.text =
      "${dateTime.day.toString().padLeft(2, '0')}-"
          "${dateTime.month.toString().padLeft(2, '0')}-"
          "${dateTime.year}";

      timeController.text =formatTime(selectedTime!);
    }
  }
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
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

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: w * 0.05,
              right: w * 0.05,
              top: h * 0.025,
              bottom: h * 0.025,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PartyPageData.schedule,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: w * 0.055,
                    color: const Color(0xFF121212),
                  ),
                ),

                SizedBox(height: h * 0.015),

                Text(
                  PartyPageData.chooseDate,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.038,
                    color: ColorScheme
                        .of(context)
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),

                SizedBox(height: h * 0.025),

                CustomTextField(
                  controller: dateController,
                  labelText: PartyPageData.date,
                  isRequired: true,
                  readOnly: true,
                  suffixIcons:[ InkWell(
                    onTap: () async {
                      final now = DateTime.now();

                      DateTime tempDate = selectedDate ?? now;

                      await showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: h * 0.35,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Top bar
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.04,
                                    vertical: h * 0.015,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Color(0xFFFF2164),
                                          ),
                                        ),
                                      ),
                                      //
                                      // const Text(
                                      //   'Select Date',
                                      //   style: TextStyle(
                                      //     fontWeight: FontWeight.w600,
                                      //     fontSize: 16,
                                      //   ),
                                      // ),

                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          setState(() {
                                            selectedDate = tempDate;

                                            dateController.text =
                                            "${tempDate.day.toString().padLeft(2, '0')}-"
                                                "${tempDate.month.toString().padLeft(2, '0')}-"
                                                "${tempDate.year}";

                                            errorMessage = null;
                                          });

                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Done',
                                          style: TextStyle(
                                            color: Color(0xFFFF2164),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Expanded(
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    initialDateTime: tempDate,
                                    minimumDate: DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                    ),
                                    maximumDate: DateTime(2100),
                                    onDateTimeChanged: (DateTime value) {
                                      tempDate = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.045),
                      child: SvgPicture.asset(PartyPageData.dateIcon),
                    ),
                  ),
          ],
                ),

                SizedBox(height: h * 0.025),

                CustomTextField(
                  controller: timeController,
                  labelText: PartyPageData.time,
                  isRequired: true,
                  readOnly: true,
                  suffixIcons:[
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();

                        DateTime tempDateTime;

                        if (selectedDate != null && selectedTime != null) {
                          tempDateTime = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );
                        } else {
                          tempDateTime = now;
                        }

                        await showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: h * 0.35,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Top bar
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.04,
                                      vertical: h * 0.015,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color(0xFFFF2164),
                                            ),
                                          ),
                                        ),

                                        // const Text(
                                        //   'Select Time',
                                        //   style: TextStyle(
                                        //     fontWeight: FontWeight.w600,
                                        //     fontSize: 16,
                                        //   ),
                                        // ),

                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            setState(() {
                                              selectedTime = TimeOfDay(
                                                hour: tempDateTime.hour,
                                                minute: tempDateTime.minute,
                                              );

                                              timeController.text =
                                                  formatTime(selectedTime!);

                                              errorMessage = null;
                                            });

                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                              color: Color(0xFFFF2164),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.time,
                                      initialDateTime: tempDateTime,
                                      use24hFormat: false,
                                      onDateTimeChanged: (DateTime value) {
                                        tempDateTime = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.045),
                      child: SvgPicture.asset(PartyPageData.dateIcon),
                    ),
                  ),
          ],
                ),

                SizedBox(height: h * 0.03),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: h * 0.05,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFF2164)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                PartyPageData.crossIcon,
                                color: const Color(0xFFFF2164),
                                height: h * 0.02,
                              ),
                              SizedBox(width: w * 0.02),
                              Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: const Color(0xFFFF2164),
                                  fontWeight: FontWeight.w500,
                                  fontSize: (w * 0.04).clamp(14.0, 16.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: w * 0.03),

                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (selectedDate == null || selectedTime == null) {
                            setState(() {
                              errorMessage =
                              'Please select both date and time.';
                            });
                            return;
                          }

                          if (!isSelectedDateTimeValid()) {
                            setState(() {
                              errorMessage =
                              'Please select a present or future date and time.';
                            });
                            return;
                          }

                          Navigator.pop(context, {
                            'date': dateController.text,
                            'time': timeController.text,
                          });
                        },
                        child: Container(
                          height: h * 0.05,
                          decoration: BoxDecoration(
                            gradient: GradientColors.primaryGradient,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFF2164)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                PartyPageData.addIcon,
                                color: ColorScheme
                                    .of(context)
                                    .surface,
                                height: h * 0.02,
                              ),
                              SizedBox(width: w * 0.02),
                              Flexible(
                                child: Text(
                                  PartyPageData.setDateTime,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: ColorScheme
                                        .of(context)
                                        .surface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: (w * 0.04).clamp(14.0, 16.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildTaggedPeopleAvatars(List<Tagged> taggedPeople, double h, double w) {
  final peopleToShow = taggedPeople.take(3).toList();

  return SizedBox(
    width: peopleToShow.isEmpty ? 0 : (peopleToShow.length * 22.0) + 10,
    height: h * 0.05,
    child: Stack(
      clipBehavior: Clip.none,
      children: List.generate(peopleToShow.length, (index) {
        final person = peopleToShow[index];

        return Positioned(
          left: index * 20.0,
          top: 0,
          child: Container(
            width: h * 0.045,
            height: h * 0.045,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: ClipOval(
                child: SizedBox.expand(
                  child: person.photoUrl != null && person.photoUrl!.isNotEmpty
                      ? buildImageWidget(person.photoUrl!, fit: BoxFit.cover)
                      : Text(
                    person.name?.isNotEmpty == true
                        ? person.name![0].toUpperCase()
                        : "?",
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}

///--------------Reusabel container
class FeedQuoteTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final String? iconName;
 final double?height;
 final double? width;
  const FeedQuoteTab({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.iconName,
    required this.height,
    required this.width,
  });

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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(h * 0.02),
      child: Container(
        height: height,//h * 0.05,
        width:width,// w * 0.35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h * 0.025),
          gradient: isSelected ? GradientColors.primaryGradient : null,
          color: isSelected
              ? null
              : ColorScheme
              .of(context)
              .onSurface
              .withOpacity(0.08),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                height: h * 0.025,

                iconName!,
                // color: ColorScheme.of(context).surface,
              ),
              SizedBox(width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.02),
              Text(
                textAlign: TextAlign.center,
                title,
                style: TextStyle(
                    color: ColorScheme
                        .of(context)
                        .onSurface,

                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.22
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
