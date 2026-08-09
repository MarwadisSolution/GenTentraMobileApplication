import 'package:flutter/material.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
import 'package:video_player/video_player.dart';

class FeedMediaWidget extends StatelessWidget {
  final List<FeedMedia> media;

  const FeedMediaWidget({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if(media.isEmpty){
      return const SizedBox.shrink();
    }
   if(media.length==1){
     return _singleMedia(context, media[0],0,);
   }
   if(media.length==2){
     return _twoMedia(context,);
   }
   return _threeOrMoreMedia(
     context,
   );
  }
  ///-----1 media only
  Widget _singleMedia(BuildContext context, FeedMedia item, int index){
    return GestureDetector(
      onTap: (){
        _openViewer(context, index);
      },
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: _mediaPreview(item),
      ),
    );
  }
  ///---------Media
 Widget _twoMedia(BuildContext context){
    return SizedBox(
      height: 250,
      child:  Row(
        children: [
          Expanded(child: GestureDetector(
      onTap: (){
        _openViewer(context, 0);
      },
            child: _mediaPreview(media[0]),
          ),
          ),
          const SizedBox(width: 2,),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _openViewer(context, 1);
              },
              child: _mediaPreview(media[1]),
            ),
          ),
        ],
      ),
    );
 }
 Widget _threeOrMoreMedia(BuildContext context){
    final remaining=media.length-3;
    return SizedBox(
      height: 350,
      child: Column(
        children: [
          ///---------Media 1 (Large)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                _openViewer(context, 0);
              },
              child: _mediaPreview(media[0]),
            ),
          ),

          const SizedBox(height: 2),

          Expanded(
              flex: 1,
              child: Row(
                children: [
                  ///------media 2
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _openViewer(context, 1);
                      },
                      child: _mediaPreview(media[1]),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                      child:GestureDetector(
                        onTap: (){
                          _openViewer(context, 2);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _mediaPreview(media[2]),

                            if(remaining>0)
                              Container(
                                color: Colors.black.withOpacity(0.55),
                                child: Center(
                                  child: Text(
                                    "+$remaining View More",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                  )
          ],
              )
          )
        ],
      ),
    );
 }
 Widget _mediaPreview(FeedMedia item){
    final url=item.url??"";
    if(item.mediaType=="VIDEO"){
      return VideoPreview(url:url,);
    }
    return Image.network(url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(
              Icons.image,
              size: 40,
              color: Colors.grey,
            ),
          ),
        );
      },
      loadingBuilder: (context,child, loadingProgress){
        if (loadingProgress == null) {
          return child;
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        );
      },
    );
 }
 ///----------Open Full Screen images
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
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        color: Colors.black12,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 35,
              ),
              const SizedBox(height: 8),
              const Text(
                "Unable to load video",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // border: Border.all(
            //   color: Colors.grey, // Sets the border color to grey
            //   width: 1.0,         // Optional: changes the border thickness
            // ),
            //color: Colors.black54,
            //shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.black,
            size: 30,
          ),
        ),
      ],
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

    pageController = PageController(
      initialPage: widget.initialIndex,
    );
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
          style: const TextStyle(
            color: Colors.white,
          ),
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
            return FullScreenVideo(
              url: item.url ?? "",
            );
          }

          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,

            child: Center(
              child: Image.network(
                item.url ?? "",
                fit: BoxFit.contain,

                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 60,
                  );
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

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    controller.initialize().then((_) {
      if (mounted) {
        controller.pause(); // Don't autoplay

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
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

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: GestureDetector(
          onTap: togglePlay,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}