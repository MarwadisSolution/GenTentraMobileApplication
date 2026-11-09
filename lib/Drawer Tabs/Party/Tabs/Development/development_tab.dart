import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_events.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_states.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import '../../party_page_data.dart';

import '../../reusable_functions.dart';
import '../Feed Tab/functions.dart';
import '../Feed Tab/reusable_functions.dart';
import 'development_model.dart';

class DevelopmentTab extends StatefulWidget {
  final int id;
  final ScrollController scrollController;
  final bool isVisible;
  final String fromWhichPage;

  const DevelopmentTab({
    super.key,
    required this.id,
    required this.scrollController,
    required this.isVisible,
    required this.fromWhichPage,
  });

  @override
  State<DevelopmentTab> createState() => _DevelopmentTabState();
}

class _DevelopmentTabState extends State<DevelopmentTab> {
  bool? isAdmin;
  bool isPolitician = false;

  void _refreshIfNeeded() {
    if (!widget.isVisible) return;
    final developmentBloc = context.read<DevelopmentBloc>();
    final developmentState = developmentBloc.state;
    const refreshAfter = Duration(minutes: 1);
    final shouldFetch =
        developmentState.developments.isEmpty ||
        developmentState.lastFetchedAt == null ||
        DateTime.now().difference(developmentState.lastFetchedAt!) >
            refreshAfter;

    if (shouldFetch && !developmentState.isLoading) {
      developmentBloc.add(
        LoadDevelopmentEvent(
          id: widget.id,
          fromWhichPage: widget.fromWhichPage,
        ),
      );
    }
  }

  Future<void> checkPolitician() async {
    final prefs = await SharedPreferences.getInstance();
    isPolitician = prefs.getString("role") == "ROLE_POLITICIAN";
  }

  Future<void> isAdminChecking() async {
    final prefs = await SharedPreferences.getInstance();
    final String? adminPartyId = prefs.getString("AdminOfParty");
    final String currentPartyId = widget.id.toString();
    final bool admin = adminPartyId == currentPartyId;

    if (!mounted) return;

    setState(() {
      isAdmin = admin;
    });
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final developmentBloc = context.read<DevelopmentBloc>();
    final developmentState = developmentBloc.state;

    if (widget.scrollController.position.extentAfter < 500 &&
        !developmentState.isLoading &&
        developmentState.hasMore) {
      developmentBloc.add(
        LoadDevelopmentEvent(
          id: widget.id,
          page: developmentState.page + 1,
          size: 20,
          fromWhichPage: widget. fromWhichPage,
        ),
      );
    }
  }
  @override
  void didUpdateWidget(covariant DevelopmentTab oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(!oldWidget.isVisible && widget.isVisible){
      _refreshIfNeeded();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isAdminChecking();
    checkPolitician();
    if(widget.isVisible){
      WidgetsBinding.instance.addPostFrameCallback((_){
        if(mounted){
          _refreshIfNeeded();
        }
      });
    }
    widget.scrollController.addListener(_onScroll);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
  Future<void>shareDevelopment(dynamic development)async{
    final String shareLink='$api/development/${development.uuid}';
    await Share.share('Check out the development:\n$shareLink');
  }
  final Map<int, Timer> _viewTimer = {};

  void _onDevelopmentVisibilityChanged(int? postId, double visibleFraction){
    if(postId==null)return;
    final developmentState= context.read<DevelopmentBloc>().state;
    //Already successfully reported
    if(developmentState.viewedPostIds.contains(postId))return;
    // Api requested
    if(developmentState.reportingViewIds.contains(postId)) return;

    ///-----------development is >=50% visible
    if(visibleFraction>=0.5){
      //Timer already running.
      if(_viewTimer.containsKey(postId))return;
      _viewTimer[postId]=Timer(const Duration(seconds: 2), (){
        _viewTimer.remove(postId);
        if(!mounted)return;
        final currentState = context.read<DevelopmentBloc>().state;
        if(currentState.viewedPostIds.contains(postId))return;
        if(currentState.reportingViewIds.contains(postId))return;
        context.read<DevelopmentBloc>().add(ReportDevelopmentViewEvent(postId: postId));
      });
      return;
    }
    _cancelViewTimer(postId);
  }
void _cancelViewTimer(int postId){
    final timer= _viewTimer.remove(postId);
    if(timer!=null){
      timer.cancel();
    }
}
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocConsumer<DevelopmentBloc, DevelopmentState>(
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
      builder: (context,state){
        if(state.isLoading && state.developments.isEmpty){
          return Padding(
            padding: EdgeInsets.only(top: h * 0.1),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }
        if (state.isError) {
          return const SizedBox.shrink();
        }
        if(state.developments.isEmpty){
          return Padding(padding: EdgeInsets.all(h * 0.045),
              child: Center(
                child: Text(
                  "No Development found",
                  style: TextStyle(
                    color: ColorScheme.of(context).onSurface,
                    fontSize: w * 0.045,
                  ),
                ),
              ),
          );
        }
        return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: state.developments.length + (state.isLoading?1:0),
            itemBuilder:(context, index){
              if(index>=state.developments.length){
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ColorScheme.of(context).onSurface,
                    ),
                  ),
                );
              }
              final developments=state.developments[index];
              return VisibilityDetector(
                  key: Key('development_visibility_${developments.id??index}'),
                  onVisibilityChanged: (info){
                    _onDevelopmentVisibilityChanged(developments.id, info.visibleFraction);
                  },
              child: Container(
                key: ValueKey(developments.id),
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
                              developments.author?.photoUrl ?? "",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        developments.author?.name??"-",
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: (w * 0.045),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.31,
                        ),
                      ),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTimeAgo(developments.timeStamp),
                            style: TextStyle(
                              fontSize: (w * 0.025).clamp(12.0, 15.0),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.21,
                              color: const Color(0xFF666666),
                            ),
                          ),
                          SizedBox(width: w * 0.01),
                          Text(
                            "•",
                            style: TextStyle(
                              fontSize: (w * 0.025).clamp(12.0, 15.0),
                              color: ColorScheme.of(context).error,
                            ),
                          ),
                          SizedBox(width: w * 0.03),
                          Padding(
                            padding: EdgeInsets.only(top: h * 0.0027),
                            child: SvgPicture.asset(
                              PartyPageData.headquarterIcon,
                              height: (h * 0.017),
                            ),
                          ),
                          SizedBox(width: w * 0.01),
                          Text(
                            developments.author?.state ?? "-",
                            style: TextStyle(
                              fontSize: (w * 0.025).clamp(12.0, 15.0),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.21,
                              color: const Color(0xFF666666),
                            ),
                          ),
                          SizedBox(width: w * 0.01),
                          Text(
                            developments.author?.country ?? "",
                            style: TextStyle(
                              fontSize: (w * 0.025).clamp(12.0, 15.0),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.21,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),

                      ///----------------Need to be checked-------------------------
                      trailing:
                      isAdmin == true ||
                          (isPolitician == true &&
                              widget.fromWhichPage == "Politician")
                          ? PopupMenuButton<String>(
                        icon: Transform.translate(
                          offset: const Offset(20, 0),
                          child: SvgPicture.asset(
                            PartyPageData.threeDots,
                            height: h * 0.004,
                          ),
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {

                          } else if (value == 'share') {
                            shareDevelopment(developments);
                          } else if (value == 'delete') {
                            final shouldDelete =
                            await showGeneralDialog<bool>(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Delete',
                              barrierColor: Colors.black.withValues(
                                alpha: 0.25,
                              ),
                              transitionDuration: const Duration(
                                milliseconds: 250,
                              ),
                             pageBuilder: (dialogContext, _, _) {
                                return popUpMessageForDeleteOrCancel(
                                  dialogContext,
                                 PartyPageData.addFeedIcon,
                                  "Would you like to Delete?",
                                  "Once deleted, this post will be permanently removed.",
                                      () {},
                                );
                              },
                              transitionBuilder:
                                  (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                  ) {
                                return SlideTransition(
                                  position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve:
                                      Curves.easeOutCubic,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            );

                            if (shouldDelete == true && mounted) {
                              context.read<DevelopmentBloc>().add(
                                DeleteDevelopmentEvent(
                                  developments.id,
                                  widget.id,
                                  fromWhichPage: widget.fromWhichPage,
                                ),
                              );
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  PartyPageData.editIcon,
                                  width: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text("Edit"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  PartyPageData.share,
                                  width: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text("Share"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  PartyPageData.deleteIcon,
                                  width: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text("Delete"),
                              ],
                            ),
                          ),
                        ],
                      )
                          : null,
                    ),
                    ///------------------------Need to be checked--------------------------
                    ShowingTaggedPersons(
                      tagged:[]
                    //  developments.taggedPoliticians,
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                        top: h * 0.001,
                        right: w * 0.044,
                        left: w * 0.044,
                      ),
                      child: ReadMoreText(
                        developments.description ?? "-",
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
                          fontSize: (w * 0.042),
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ),
                    if(developments.media!=null && developments.media!.isNotEmpty)...[
                      SizedBox(height: h * 0.012),
                      FeedMediaWidget<DevelopmentMedia>(
                        media: developments.media ?? [],
                        getMediaUrl: (item) => item.url,
                        getMediaType: (item) => item.mediaType,
                      )
                    ],
                    Padding(   padding: EdgeInsets.only(
                      top:  h * 0.012,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: w * 0.034,
                            left: w * 0.044,
                          ),
                          child: Row(
                            children: [
                              Text(
                              "20",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: (w * 0.05),
                                ),
                              ),
                              SizedBox(width: w * 0.03),
                              Text(
                                "Views",
                                style: TextStyle(
                                  fontSize: (w * 0.025).clamp(12.0, 15.0),
                                  fontWeight: FontWeight.w400,
                                  color: ColorScheme.of(
                                    context,
                                  ).onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const Spacer(),
                              // LikeButton(
                              //   key: ValueKey('like_${developments.id}'),
                              //   feedId: developments.id,
                              // ),
                              SizedBox(width: w * 0.08),
                              Padding(
                                padding: EdgeInsets.only(right: w * 0.015),
                                child: InkWell(
                                  onTap: () => shareDevelopment(developments),
                                  child: SvgPicture.asset(
                                    PartyPageData.share,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ),
                    SizedBox(height: h * 0.01),
                    Container(
                      color: const Color(0xFF000000).withValues(alpha: 0.08),
                      width: w,
                      height: h * 0.009,
                    ),
                  ],

                ),
              ),
              );
            }

        );
      }
    );
  }
}
//
// class LikeButton extends StatefulWidget {
//   final int? feedId;
//   // final bool reacted;
//
//   const LikeButton({super.key, required this.feedId,
//     //required this.reacted
//   });
//
//   @override
//   State<LikeButton> createState() => _LikeButtonState();
// }
//
// class _LikeButtonState extends State<LikeButton> {
//   final DevelopmentApis feedApis = DevelopmentApis();
//   late bool isLiked;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // isLiked = widget.reacted;
//   }
//
//   @override
//   void didUpdateWidget(covariant LikeButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.reacted != widget.reacted) {
//       setState(() {
//         isLiked = widget.reacted;
//       });
//     }
//   }
//
//   Future<void> likePost() async {
//     if (widget.feedId == null || isLoading) return;
//
//     final previousLikedState = isLiked;
//
//     setState(() {
//       isLoading = true;
//       isLiked = !previousLikedState;
//     });
//
//     try {
//       final success = await feedApis.likeThePost(widget.feedId!);
//
//       if (!mounted) return;
//
//       if (!success) {
//         setState(() {
//           isLiked = previousLikedState;
//           isLoading = false;
//         });
//         return;
//       }
//
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Error liking/unliking post: $e");
//
//       if (!mounted) return;
//
//       setState(() {
//         isLiked = previousLikedState;
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: likePost,
//       child: Center(
//         child: Icon(
//           Icons.thumb_up,
//           size: MediaQuery.of(context).size.height * 0.028,
//           color: isLiked
//               ? Color(0xFFFE3A31)
//               : ColorScheme.of(context).onSurface.withValues(alpha: 0.22),
//         ),
//       ),
//     );
//   }
// }