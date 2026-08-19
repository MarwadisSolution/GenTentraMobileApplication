import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'package:video_player/video_player.dart';

class FeedMediaWidget extends StatelessWidget {
  final List<FeedMedia> media;

  const FeedMediaWidget({
    super.key,
    required this.media,
  });

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
      height: 280,
      borderRadius: BorderRadius.circular(12),
    );
  }

  // ============================================================
  // 2 MEDIA
  // ============================================================

  Widget _buildTwoMedia(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Row(
        children: [
          Expanded(
            child: _mediaTile(
              context: context,
              index: 0,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),

          const SizedBox(width: 3),

          Expanded(
            child: _mediaTile(
              context: context,
              index: 1,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 3),

          // ---------------- BOTTOM TWO MEDIA ----------------

          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: _mediaTile(
                    context: context,
                    index: 1,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(width: 3),

                Expanded(
                  child: _mediaTile(
                    context: context,
                    index: 2,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
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
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _mediaPreview(media[index]),

              // Dark overlay for "+X more"
              if (overlayCount != null)
                Container(
                  color: Colors.black.withOpacity(0.55),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.collections_outlined,
                        color: Colors.white,
                        size: 28,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "+$overlayCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      const Text(
                        "more",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Small video indicator
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
          child: const Icon(
            Icons.image_outlined,
            size: 40,
            color: Colors.grey,
          ),
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

  void _openViewer(
      BuildContext context,
      int initialIndex,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FeedMediaViewer(
            media: media,
            initialIndex: initialIndex,
          );
        },
      ),
    );
  }
}

class VideoPreview extends StatefulWidget {
  final String url;

  const VideoPreview({
    super.key,
    required this.url,
  });

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

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

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
            Icon(
              Icons.video_library_outlined,
              color: Colors.grey,
              size: 38,
            ),
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

          // Center play icon
          // const Center(
          //   child: Icon(
          //     Icons.play_circle_fill,
          //     color: Colors.white,
          //     size: 48,
          //     shadows: [
          //       Shadow(
          //         color: Colors.black54,
          //         blurRadius: 8,
          //       ),
          //     ],
          //   ),
          // ),
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

  const FullScreenVideo({
    super.key,
    required this.url,
  });

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

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

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

    _hideTimer = Timer(
      const Duration(seconds: 2),
          () {
        if (mounted) {
          setState(() {
            showPlayButton = false;
          });
        }
      },
    );
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
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
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
                  controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
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
Widget FeedQuoteWidget(
    final String quote,
    final String author,
final List<FeedMedia> media,
BuildContext context,
    ){
return Container(
  decoration: BoxDecoration(
  ),
  child: Column(
    children: [
      Align(
        alignment: Alignment.topLeft,
        child: SvgPicture.asset(PartyPageData.quoteIcon),
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.021,),
      Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
          ),
          child: Text(
           quote,
            textAlign: TextAlign.center,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.height * 0.038,
            ),
          ),
        ),
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: SizedBox.expand(
                child: Image.network(media[0].url!,fit: BoxFit.cover,),
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03,),
          Text(author,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:MediaQuery.of(context).size.height * 0.021,
            color: Color(0xFF666666)
          ),
          ),
        ],
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.021,),
      Align(
        alignment: Alignment.bottomRight,
        child: Transform.rotate(
          angle: 3.14,
            child: SvgPicture.asset(PartyPageData.quoteIcon)),
      )
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
      builder: (_) => LeaderPickerDialog(
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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
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

                        final checked = !isRemoved && (alreadyTagged || isSelected);
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
                                    final removedIndex = removedExistingLeaders.indexWhere(
                                          (e) => e.id == leader.id,
                                    );

                                    if (removedIndex != -1) {
                                      // User selected it again
                                      removedExistingLeaders.removeAt(removedIndex);
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
                                "${leader.designation.toUpperCase()}, ${leader.uniqueId.toUpperCase()}",
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

                            final List<Tagged> taggedLeaders = selectedLeaders.map((leader) {
                              return Tagged(
                                type: "POLITICIAN",
                                id: leader.id,
                                name: leader.name,
                                photoUrl: leader.image,
                              );
                            }).toList();

                            Navigator.pop(context, {
                              'added': taggedLeaders,
                              'removed': removedExistingLeaders.map((e) => e.id).toList(),
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
                                    color: ColorScheme.of(context).surface,
                                    height: h * 0.02,
                                  ),
                                  SizedBox(width: w * 0.02),
                                  Text(
                                    'ADD',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorScheme.of(context).surface,
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
  const AddSchedule({super.key});

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
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

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
                    color: ColorScheme.of(context)
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
                  suffixIcon: InkWell(
                    onTap: () async {
                      final now = DateTime.now();

                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? now,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;

                          dateController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}-"
                              "${pickedDate.month.toString().padLeft(2, '0')}-"
                              "${pickedDate.year}";

                          errorMessage = null;
                        });
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.045),
                      child: SvgPicture.asset(
                        PartyPageData.dateIcon,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.025),

                CustomTextField(
                  controller: timeController,
                  labelText: PartyPageData.time,
                  isRequired: true,
                  readOnly: true,
                  suffixIcon: InkWell(
                    onTap: () async {
                      final now = DateTime.now();

                      TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();

                      if (selectedDate != null) {
                        final isToday =
                            selectedDate!.year == now.year &&
                                selectedDate!.month == now.month &&
                                selectedDate!.day == now.day;

                        if (isToday) {
                          initialTime = TimeOfDay(
                            hour: now.hour,
                            minute: now.minute,
                          );
                        }
                      }

                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );

                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;

                          timeController.text = pickedTime.format(context);

                          errorMessage = null;
                        });
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(w * 0.045),
                      child: SvgPicture.asset(
                        PartyPageData.dateIcon,
                      ),
                    ),
                  ),
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
                            border: Border.all(
                              color: const Color(0xFFFF2164),
                            ),
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
                                  fontSize:
                                  (w * 0.04).clamp(14.0, 16.0),
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
                              errorMessage = 'Please select both date and time.';
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
                            gradient:
                            GradientColors.primaryGradient,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFFF2164),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                PartyPageData.addIcon,
                                color:
                                ColorScheme.of(context).surface,
                                height: h * 0.02,
                              ),
                              SizedBox(width: w * 0.02),
                              Flexible(
                                child: Text(
                                  PartyPageData.setDateTime,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: ColorScheme.of(context)
                                        .surface,
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                    (w * 0.04).clamp(14.0, 16.0),
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


Widget buildTaggedPeopleAvatars(
    List<Tagged> taggedPeople,
    double h,
    double w,
    ) {
  final peopleToShow = taggedPeople.take(3).toList();

  return SizedBox(
    width: peopleToShow.isEmpty
        ? 0
        : (peopleToShow.length * 22.0) + 10,
    height: h * 0.05,
    child: Stack(
      clipBehavior: Clip.none,
      children: List.generate(
        peopleToShow.length,
            (index) {
          final person = peopleToShow[index];

          return Positioned(
            left: index * 20.0,
            top: 0,
            child: Container(
              width: h * 0.045,
              height: h * 0.045,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
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
            ),
          );
        },
      ),
    ),
  );
}

///--------------Reusabel container
class FeedQuoteTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final String? iconName;

  const FeedQuoteTab({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(h * 0.02),
      child: Container(
        height: h * 0.05,
        width: w * 0.25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h * 0.025),
          gradient: isSelected
              ? GradientColors.primaryGradient
              : null,
          color: isSelected
              ? null
              : ColorScheme.of(context)
              .onSurface
              .withOpacity(0.26),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                title,
                style: TextStyle(
                  color:ColorScheme.of(context).surface,

                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.02,),
              SvgPicture.asset(iconName!,color: ColorScheme.of(context).surface,),
            ],
          ),
        ),
      ),
    );
  }
}