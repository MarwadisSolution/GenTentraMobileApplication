import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/Offline/offline_feed_repository.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_event.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_state.dart';

import '../../../../media_upload_api.dart';
import 'apis.dart';
import 'feed_model.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedApis api;
  final OfflineFeedRepository offlineRepository;

  FeedBloc(this.api, {OfflineFeedRepository? offlineRepository})
      : offlineRepository = offlineRepository ?? OfflineFeedRepository(),
        super(FeedState.initial()) {
    on<LoadFeedEvent>(_loadFeed);
    on<AddNewFeedEvent>(_addNewFeed);
    on<YearWiseFeedEvent>(_yearWiseFeed);
    on<DeleteFeedEvent>(_deleteFeed);
    on<UpdateFeedEvent>(_updateFeed);
  }

  Future<void> _loadFeed(
      LoadFeedEvent event,
      Emitter<FeedState> emit,
      ) async {
    final bool isFirstPage = event.page == 0;

    // Don't make duplicate pagination requests
    if (!isFirstPage) {
      if (state.isLoadingMore || !state.hasMore) {
        return;
      }

      emit(
        state.copyWith(
          isLoadingMore: true,
          isError: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: true,
          isError: false,
        ),
      );
    }

    try {
      final newFeeds = await api.getFeeds(
        partyId: event.partyId,
        page: event.page,
        size: event.size,
      );

      // If less than 20 came back, there is no next page.
      final bool hasMore = newFeeds.length == event.size;

      if (isFirstPage) {
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            isError: false,
            feeds: newFeeds,
            currentPage: 0,
            hasMore: hasMore,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoadingMore: false,
            isError: false,


            feeds: [
              ...state.feeds,
              ...newFeeds,
            ],

            currentPage: event.page,
            hasMore: hasMore,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _addNewFeed(AddNewFeedEvent event,
      Emitter<FeedState> emit,) async {
    emit(
      state.copyWith(
        isPosting: true,
        isError: false,
        isPostSuccess: false,
        isOfflineQueued: false,
        errorMessage: '',
      ),
    );

    try {
      debugPrint("POSTING FEED/QUOTE...");
      debugPrint("Kind: ${event.feed.kind}");

      ///---------Internet Checking
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.hasConnectivity) {
        debugPrint(
          "NO INTERNET -> SAVING FEED TO Sqllit",);
        await offlineRepository.savePost(feed: event.feed,
            mediaFiles: event.mediaFiles
        );
        emit(state.copyWith(
          isPosting: false,
          isError: false,
          isPostSuccess: true,
          isOfflineQueued: true,
          errorMessage: '',
        )
        );

        debugPrint("FEED SAVED OFFLINE SUCCESSFULLY",);
        return;
      }

      ///------------Internet appears available
      try {
        await api.postTheFeed(feed: event.feed, mediaFiles: event.mediaFiles);

        debugPrint("POST API SUCCESS");

        final feed = await api.getFeeds(
          partyId: event.partyId,
          page: 0,
          size: 20,
        );

        emit(
          state.copyWith(
            isPosting: false,
            isError: false,
            isPostSuccess: true,
            isOfflineQueued: false,
            feeds: feed,
            currentPage: 0,
            hasMore: feed.length == 20,
            isLoadingMore: false,
            errorMessage: '',
          ),
        );

        debugPrint("PUBLISH SUCCESS");
      }
      catch (e) {
        if (isNetworkError(e)) {
          debugPrint(
            "API NETWORK ERROR -> SAVING FEED TO SQLITE",
          );
          await offlineRepository.savePost(
              feed: event.feed, mediaFiles: event.mediaFiles
          );
          emit(
              state.copyWith(
                isPosting: false,
                isError: false,
                isPostSuccess: true,
                isOfflineQueued: true,
                errorMessage: '',
              )
          );

          debugPrint(
            "FEED SAVED OFFLINE AFTER API NETWORK FAILURE",
          );
          return;
        }
        rethrow;
      }
    }
    catch (e, stackTrace) {
      debugPrint("PUBLISH ERROR: $e");
      debugPrint("$stackTrace");

      emit(
        state.copyWith(
          isPosting: false,
          isError: true,
          isPostSuccess: false,
          isOfflineQueued: false,
          errorMessage: e.toString(),
        ),
      );
    }

  }

  void _yearWiseFeed(YearWiseFeedEvent event, Emitter<FeedState> emit) {
    emit(state.copyWith(selectYearFeed: event.year));
  }

  void _deleteFeed(DeleteFeedEvent event, Emitter<FeedState> emit) async {
    ///-----------------Delete Api call
    try {
      emit(state.copyWith(isLoading: true, isError: false, errorMessage: ''));

      debugPrint("Deleting feed ID: ${event.id}");

      final message = await api.deletePost(event.id);

      debugPrint("Delete response: $message");
      final feed = await api.getFeeds(
        partyId: event.partyId,
        page: 0,
        size: 20,
      );
      emit(
        state.copyWith(
          isLoading: false,
          isError: false,
          feeds: feed,
          currentPage: 0,
          hasMore: feed.length == 20,
          isLoadingMore: false,
          errorMessage: message,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("DELETE ERROR: $e");
      debugPrint("$stackTrace");
      emit(
        state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }
  Future<void> _updateFeed(
      UpdateFeedEvent event,
      Emitter<FeedState> emit,
      ) async {
    emit(
      state.copyWith(
        isPosting: true,
        isError: false,
        isPostSuccess: false,
        errorMessage: '',
      ),
    );

    try {
      debugPrint("======================================");
      debugPrint("UPDATING FEED ID: ${event.feed.id}");
      debugPrint("======================================");

      FeedModel updatedFeed = event.feed;
// =========================================================
// 1. UPLOAD NEW MEDIA
// =========================================================

      final List<FeedMedia> newlyUploadedMedia = [];

      for (final file in event.mediaFiles) {
        debugPrint("Uploading new media: ${file.path}");

        // Determine type from ORIGINAL FILE
        final mediaType = _getMediaTypeFromFile(file);

        debugPrint("Detected media type: $mediaType");

        final uploaded = await MediaUploadApi().uploadMedia(
          filePaths: [file.path],
          category: "feed",
        );

        if (uploaded.isNotEmpty) {
          final uploadedUrl = uploaded.first;

          newlyUploadedMedia.add(
            FeedMedia(
              id: null,
              url: uploadedUrl,
              mediaType: mediaType,
            ),
          );

          debugPrint(
            "Uploaded successfully: $uploadedUrl | type=$mediaType",
          );
        }
      }
// =========================================================
// 2. ADD UPLOADED MEDIA TO FEED
// =========================================================

      final List<FeedMedia> currentMedia = List<FeedMedia>.from(
        updatedFeed.media ?? <FeedMedia>[],
      );

// Remove media that user deleted
      currentMedia.removeWhere(
            (media) =>
        media.id != null &&
            event.deletedMediaIds.contains(media.id),
      );

// Add newly uploaded media
      // Add newly uploaded media
      currentMedia.addAll(newlyUploadedMedia);

      updatedFeed = updatedFeed.copyWith(
        media: currentMedia,
      );

      debugPrint("MEDIA AFTER DELETE + ADD:");

      for (final media in currentMedia) {
        debugPrint(
          "id=${media.id}, url=${media.url}, type=${media.mediaType}",
        );
      }

      // =========================================================
      // 3. PATCH JSON
      // =========================================================

      debugPrint("Final feed before PATCH:");
      debugPrint(
        jsonEncode(updatedFeed.toJson()),
      );

      final result = await api.updateThePost(
        feed: updatedFeed,
        deletedMediaIds: event.deletedMediaIds,
      );

      // =========================================================
      // 4. UPDATE LOCAL BLOC STATE
      // =========================================================

      final updatedFeeds = List<FeedModel>.from(
        state.feeds,
      );

      final index = updatedFeeds.indexWhere(
            (feed) => feed.id == result.id,
      );

      if (index != -1) {
        updatedFeeds[index] = result;
      }

      emit(
        state.copyWith(
          isPosting: false,
          isError: false,
          isPostSuccess: true,
          feeds: updatedFeeds,
          errorMessage: '',
        ),
      );

      debugPrint("======================================");
      debugPrint("FEED UPDATED SUCCESSFULLY");
      debugPrint("======================================");
    } catch (e, stackTrace) {
      debugPrint("UPDATE ERROR: $e");
      debugPrint("$stackTrace");

      emit(
        state.copyWith(
          isPosting: false,
          isError: true,
          isPostSuccess: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
bool isNetworkError(Object error) {
  /*
   * Direct socket error
   */
  if (error is SocketException) {
    return true;
  }

  /*
   * Dio network errors
   */
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
      /*
         * Server responded.
         *
         * Therefore this is NOT an offline error.
         */
        return false;

      case DioExceptionType.cancel:
        return false;

      case DioExceptionType.badCertificate:
        return false;

      case DioExceptionType.unknown:
        return error.error is SocketException;
    }
  }

  /*
   * Timeout from Dart
   */
  if (error is TimeoutException) {
    return true;
  }

  return false;
}


String _getMediaTypeFromFile(File file) {
  final path = file.path.toLowerCase();

  if (path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.avi') ||
      path.endsWith('.mkv') ||
      path.endsWith('.webm') ||
      path.endsWith('.m4v')) {
    return "VIDEO";
  }

  return "IMAGE";
}