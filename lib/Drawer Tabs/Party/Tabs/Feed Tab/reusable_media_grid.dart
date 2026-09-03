import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import 'feed_model.dart';
import 'reusable_functions.dart';

class ReusableMediaGrid extends StatefulWidget {
  final List<FeedMedia> existingImages;
  final List<FeedMedia> existingVideos;

  final List<XFile> selectedImages;
  final List<XFile> selectedVideos;

  final List<int> deletedMediaIds;

  final VideoPlayerHelper videoPlayerHelper;

  final Future<void> Function(
      int index, {
      required bool isExisting,
      }) onPlayVideo;

  final VoidCallback onMediaChanged;

  const ReusableMediaGrid({
    super.key,
    required this.existingImages,
    required this.existingVideos,
    required this.selectedImages,
    required this.selectedVideos,
    required this.deletedMediaIds,
    required this.videoPlayerHelper,
    required this.onPlayVideo,
    required this.onMediaChanged,
  });

  @override
  State<ReusableMediaGrid> createState() => _ReusableMediaGridState();
}

class _ReusableMediaGridState extends State<ReusableMediaGrid> {
  @override
  Widget build(BuildContext context) {
    final totalMedia = widget.existingImages.length +
        widget.existingVideos.length +
        widget.selectedImages.length +
        widget.selectedVideos.length;

    if (totalMedia == 0) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalMedia,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemBuilder: (context, index) {
        // =========================================================
        // 1. EXISTING IMAGES
        // =========================================================

        if (index < widget.existingImages.length) {
          final imageIndex = index;
          final image = widget.existingImages[imageIndex];

          return Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: buildImageWidget(
                    image.url ?? "",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () {
                    final media = widget.existingImages[imageIndex];

                    if (media.id != null &&
                        !widget.deletedMediaIds.contains(media.id!)) {
                      widget.deletedMediaIds.add(media.id!);
                    }

                    widget.existingImages.removeAt(imageIndex);

                    widget.onMediaChanged();
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

        // =========================================================
        // 2. EXISTING VIDEOS
        // =========================================================

        final existingVideoStart = widget.existingImages.length;

        final existingVideoEnd =
            widget.existingImages.length + widget.existingVideos.length;

        if (index >= existingVideoStart &&
            index < existingVideoEnd) {
          final videoIndex = index - existingVideoStart;
          final video = widget.existingVideos[videoIndex];

          final helper = widget.videoPlayerHelper;

          return Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: () async {
                    await widget.onPlayVideo(
                      videoIndex,
                      isExisting: true,
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      color: Colors.black87,
                      child: helper.playingVideoIndex == videoIndex &&
                          helper.playingExistingVideo &&
                          helper.controller != null &&
                          helper.controller!.value.isInitialized
                          ? Center(
                        child: AspectRatio(
                          aspectRatio:
                          helper.controller!.value.aspectRatio,
                          child: VideoPlayer(
                            helper.controller!,
                          ),
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
                  onTap: () async {
                    final helper = widget.videoPlayerHelper;

                    if (helper.playingVideoIndex == videoIndex &&
                        helper.playingExistingVideo) {
                      await helper.stopVideo();
                    }

                    final media = widget.existingVideos[videoIndex];

                    if (media.id != null &&
                        !widget.deletedMediaIds.contains(media.id!)) {
                      widget.deletedMediaIds.add(media.id!);
                    }

                    widget.existingVideos.removeAt(videoIndex);

                    widget.onMediaChanged();
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

        // =========================================================
        // 3. SELECTED / NEW IMAGES
        // =========================================================

        final selectedImageStart =
            widget.existingImages.length +
                widget.existingVideos.length;

        final selectedImageEnd =
            selectedImageStart +
                widget.selectedImages.length;

        if (index >= selectedImageStart &&
            index < selectedImageEnd) {
          final imageIndex = index - selectedImageStart;
          final image = widget.selectedImages[imageIndex];

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
                    widget.selectedImages.removeAt(imageIndex);
                    widget.onMediaChanged();
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

        // =========================================================
        // 4. SELECTED / NEW VIDEOS
        // =========================================================

        final selectedVideoStart =
            widget.existingImages.length +
                widget.existingVideos.length +
                widget.selectedImages.length;

        final videoIndex = index - selectedVideoStart;
        final video = widget.selectedVideos[videoIndex];

        final helper = widget.videoPlayerHelper;

        return Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () async {
                  await widget.onPlayVideo(
                    videoIndex,
                    isExisting: false,
                  );

                  if (mounted) {
                    setState(() {});
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    color: Colors.black87,
                    child: helper.playingVideoIndex == videoIndex &&
                        !helper.playingExistingVideo &&
                        helper.controller != null &&
                        helper.controller!.value.isInitialized
                        ? Center(
                      child: AspectRatio(
                        aspectRatio:
                        helper.controller!.value.aspectRatio,
                        child: VideoPlayer(
                          helper.controller!,
                        ),
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
                onTap: () async {
                  final helper = widget.videoPlayerHelper;

                  if (helper.playingVideoIndex == videoIndex &&
                      !helper.playingExistingVideo) {
                    await helper.stopVideo();
                  }

                  widget.selectedVideos.removeAt(videoIndex);
                  widget.onMediaChanged();
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
    );
  }
}