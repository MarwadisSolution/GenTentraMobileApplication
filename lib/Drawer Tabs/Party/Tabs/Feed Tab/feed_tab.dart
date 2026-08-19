import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_event.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apis.dart';

class FeedTab extends StatefulWidget {
  final int partyId;
  final ScrollController scrollController;
  const FeedTab({super.key, required this.partyId,required this.scrollController,});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  int? selectedIndex;
  bool? isAdmin;

  Future<void> isAdminChecking() async {
    final prefs = await SharedPreferences.getInstance();
    final String? adminPartyId = prefs.getString("AdminOfParty");
    final String currentPartyId = widget.partyId.toString();
    final bool admin = adminPartyId == currentPartyId;

    if (!mounted) return;

    setState(() {
      isAdmin = admin;
    });
  }
  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final feedBloc = context.read<FeedBloc>();
    final feedState = feedBloc.state;

    if (widget.scrollController.position.extentAfter < 500 &&
        !feedState.isLoadingMore &&
        feedState.hasMore) {
      feedBloc.add(
        LoadFeedEvent(
          partyId: widget.partyId,
          page: feedState.currentPage + 1,
          size: 20,
        ),
      );
    }
  }
  @override
  void initState() {
    super.initState();

    isAdminChecking();

    context.read<FeedBloc>().add(
      LoadFeedEvent(
        partyId: widget.partyId,
        page: 0,
        size: 20,
      ),
    );

    widget.scrollController.addListener(_onScroll);
  }
  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
  Future<void> shareFeed(dynamic feed) async {
    final String shareLink =
        'https://gentantrabackend-production.up.railway.app/feed/${feed.uuid}';
    await Share.share('Check out this post: \n$shareLink');
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
              content: Text(state.errorMessage),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Padding(
            padding: EdgeInsets.only(top: h * 0.4),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        if (state.isError) {
          return const SizedBox.shrink();
        }

        if (state.feeds.isEmpty) {
          return const Center(
            child: Text(
              "No Feed Available",
              style: TextStyle(color: Colors.black),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(h * 0.012),
          itemCount: state.feeds.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if(index>=state.feeds.length){
              return const Padding(padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
              );
            }
            final feed = state.feeds[index];
            return Container(
              key: ValueKey(feed.id ?? index),
              margin: EdgeInsets.only(bottom: h * 0.012),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: w * 0.07,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: SizedBox.expand(
                          child: buildImageWidget(
                            feed.author?.photoUrl ?? "",
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      feed.author?.name ?? "-",
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: (w * 0.04).clamp(14.0, 18.0),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.31,
                      ),
                    ),
                    subtitle: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed.author?.state ?? "-",
                          style: TextStyle(
                            fontSize: (w * 0.025).clamp(12.0, 15.0),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.21,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        SizedBox(width: w*0.01,),
                        Text(
                          feed.author?.country ?? "",
                          style: TextStyle(
                            fontSize: (w * 0.025).clamp(12.0, 15.0),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.21,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    trailing: isAdmin == true
                        ? PopupMenuButton<String>(
                      icon: SvgPicture.asset(
                        PartyPageData.threeDots,
                        height: h * 0.005,
                      ),
                      onSelected: (value) async {
                        if (value == 'share') {
                          shareFeed(feed);
                        } else if (value == 'delete') {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: Text(
                                  "Delete Post",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ColorScheme.of(context).onSurface,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to delete this post?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: ColorScheme.of(context).onSurface,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, false),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: ColorScheme.of(context).onSurface,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, true),
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: ColorScheme.of(context).onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete == true && mounted) {
                            context.read<FeedBloc>().add(
                              DeleteFeedEvent(feed.id!, widget.partyId),
                            );
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              SvgPicture.asset(PartyPageData.edit, width: 18),
                              const SizedBox(width: 8),
                              const Text("Edit"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              SvgPicture.asset(PartyPageData.share, width: 18),
                              const SizedBox(width: 8),
                              const Text("Share"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              SvgPicture.asset(PartyPageData.deleteIcon, width: 18),
                              const SizedBox(width: 8),
                              const Text("Delete"),
                            ],
                          ),
                        ),
                      ],
                    )
                        : null,
                  ),

                  // Post content
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, right: w * 0.044, left: w * 0.044),
                    child: ReadMoreText(
                      feed.body ?? "-",
                      trimLines: 3,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: "\nRead More",
                      trimExpandedText: "\nShow Less",
                      moreStyle: const TextStyle(
                        color: Color(0xFFFE3A31),
                        fontWeight: FontWeight.w600,
                      ),
                      lessStyle: const TextStyle(
                        color: Color(0xFFFE3A31),
                        fontWeight: FontWeight.w600,
                      ),
                      style: TextStyle(
                        fontSize: (w * 0.04).clamp(12.0, 16.0),
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  if (feed.media != null &&
                      feed.media!.isNotEmpty &&
                      feed.kind == "POST" &&
                      feed.hidden == false) ...[
                    SizedBox(height: h * 0.012),
                    FeedMediaWidget(media: feed.media!),
                  ] else if (feed.kind == "QUOTE" && feed.hidden == false) ...[
                    SizedBox(height: h * 0.012),
                    FeedQuoteWidget(
                      feed.quote!["quote"],
                      feed.quote!["author"],
                      feed.media!,
                      context,
                    ),
                  ],

                  // Views and Interactions
                  Padding(
                    padding: EdgeInsets.only(top: 8.0, right: w * 0.034, left: w * 0.044),
                    child: Row(
                      children: [
                        Text(
                          feed.viewCount.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: (w * 0.03).clamp(16.0, 18.0),
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Text(
                          "Views",
                          style: TextStyle(
                            fontSize: (w * 0.025).clamp(12.0, 15.0),
                            fontWeight: FontWeight.w400,
                            color: ColorScheme.of(context).onSurface.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        LikeButton(
                          key: ValueKey('like_${feed.id}'),
                          feedId: feed.id,
                          reacted: feed.reacted ?? false,
                        ),
                        SizedBox(width: w * 0.06),
                        InkWell(
                          onTap: () => shareFeed(feed),
                          child: SvgPicture.asset(PartyPageData.share),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.01),
                  Container(
                    color: const Color(0xFF000000).withOpacity(0.08),
                    width: w,
                    height: h * 0.009,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class LikeButton extends StatefulWidget {
  final int? feedId;
  final bool reacted;

  const LikeButton({
    super.key,
    required this.feedId,
    required this.reacted,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final FeedApis feedApis = FeedApis();
  late bool isLiked;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.reacted;
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reacted != widget.reacted) {
      setState(() {
        isLiked = widget.reacted;
      });
    }
  }

  Future<void> likePost() async {
    if (widget.feedId == null || isLoading) return;

    final previousLikedState = isLiked;

    setState(() {
      isLoading = true;
      isLiked = !previousLikedState;
    });

    try {
      final success = await feedApis.likeThePost(widget.feedId!);

      if (!mounted) return;

      if (!success) {
        setState(() {
          isLiked = previousLikedState;
          isLoading = false;
        });
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error liking/unliking post: $e");

      if (!mounted) return;

      setState(() {
        isLiked = previousLikedState;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: likePost,
      child: Center(
        child:Icon(Icons.thumb_up,
        size: MediaQuery.of(context).size.height*0.04 ,
        color: isLiked?Color(0xFFFE3A31):Colors.grey,
        )
      ),
    );
  }
}