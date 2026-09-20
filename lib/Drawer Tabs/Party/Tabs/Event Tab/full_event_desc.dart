import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import '../../reusable_functions.dart';
import '../Feed Tab/apis.dart';
import '../Feed Tab/reusable_functions.dart';
import '../tagged_people_helper.dart';
import 'add_event.dart';
import 'apis.dart';
import 'event._tag_peoples.dart';
import 'event_location_map.dart';
import 'event_modal.dart' show EventModel, MediaModel;
import '../Feed Tab/feed_model.dart' show Tagged;
import 'event_tab_bloc.dart';
import 'event_tab_event.dart';
class FullEventDesc extends StatefulWidget {
  final EventModel eventData;
  final int partyId;
  final bool isAdmin;
  const FullEventDesc({super.key, required this.eventData, required this.partyId, required this.isAdmin});

  @override
  State<FullEventDesc> createState() => _FullEventDescState();
}

class _FullEventDescState extends State<FullEventDesc> {
  final FeedApis api = FeedApis();
  List<Tagged> taggedPeople = [];
  late TaggedPeopleHandler taggedPeopleHandler;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    taggedPeopleHandler = TaggedPeopleHandler(
      context: context,
      api: api,
    );
  }
  bool _hasEventStarted(EventModel event) {
    if (event.eventFrom == null || event.timeFrom == null) {
      return false;
    }

    final startDateTime = DateTime(
      event.eventFrom!.year,
      event.eventFrom!.month,
      event.eventFrom!.day,
      event.timeFrom!.hour,
      event.timeFrom!.minute,
    );

    return DateTime.now().isAfter(startDateTime) ||
        DateTime.now().isAtSameMomentAs(startDateTime);
  }
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    // final eventData = state.events.firstWhere(
    //       (event) => event.id == widget.eventData.id,
    //   orElse: () => widget.eventData,
    // );


    Future<void> shareFeed(dynamic event) async {
      final String shareLink =
          'https://gentantrabackend-production.up.railway.app/event/${event.uuid}';
      await Share.share('Check out this post: \n$shareLink');
    }

    return BlocBuilder<EventsBloc, EventTabState>(
      builder: (context, state){
        final eventData = state.events.firstWhere(
              (event) => event.id == widget.eventData.id,
          orElse: () => widget.eventData,
        );
        final fromTime = timingConversion(
          eventData.eventFrom.toString(),
        );
        return DraggableScrollableSheet(
            initialChildSize: 0.95,
            minChildSize: 0.95,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController){
              return Stack(
                children: [

                  if (eventData.bgImageUrl != null &&
                      eventData.bgImageUrl!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      height: h * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ColorScheme.of(context).surface,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: double.infinity,
                        child: buildImageWidget(
                          eventData.bgImageUrl!,
                          width: double.infinity,
                          height: h * 0.25,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Padding(padding: EdgeInsets.only(
                    top:
                    eventData.bgImageUrl != null &&
                        eventData.bgImageUrl!.isNotEmpty
                        ? h * 0.192
                        : 0,
                    left:
                    eventData.bgImageUrl != null &&
                        eventData.bgImageUrl!.isNotEmpty
                        ? w * 0.04
                        : 0,
                    right:
                    eventData.bgImageUrl != null &&
                        eventData.bgImageUrl!.isNotEmpty
                        ? w * 0.04
                        : 0,
                  ),
                      child:   ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          ReusableEventCard(
                            eventData: eventData,

                            isAdmin: widget.isAdmin,

                            fromTime: fromTime,

                            isJoining:
                            state.joiningEventId == eventData.id,

                            onShare: () {
                              shareFeed(eventData);
                            },

                            onJoin: () {
                              context.read<EventsBloc>().add(
                                joinUnJoinButtonEvent(
                                  eventId: eventData.id!,
                                ),
                              );
                            },

                            onEdit: () async {
                              // ------------------------------------------
                              // CHECK WHETHER EVENT HAS ALREADY STARTED
                              // ------------------------------------------
                              if (_hasEventStarted(eventData)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "This event cannot be edited because it has already started.",
                                    ),
                                  ),
                                );

                                return;
                              }

                              // ------------------------------------------
                              // CLOSE FULL EVENT DESCRIPTION
                              // ------------------------------------------
                              Navigator.pop(context);

                              // ------------------------------------------
                              // OPEN EDIT EVENT PAGE
                              // ------------------------------------------
                              final bool? updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) {
                                    return BlocProvider(
                                      create: (_) => EventsBloc(EventApis()),
                                      child: AddEvent(
                                        partyId: widget.partyId,
                                        eventToEdit: eventData,
                                      ),
                                    );
                                  },
                                ),
                              );

                              // ------------------------------------------
                              // RETURN RESULT TO EVENT TAB
                              // ------------------------------------------
                              if (updated == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            },

                            onDelete: () async {
                              final shouldDelete = await showGeneralDialog<bool>(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Delete',
                                barrierColor: Colors.black.withOpacity(0.25),
                                transitionDuration: const Duration(milliseconds: 250),
                                pageBuilder: (dialogContext, _, __) {
                                  return popUpMessageForDeleteOrCancel(
                                    dialogContext,
                                    PartyPageData.calenderIcon,
                                    "Would you like to Delete Event?",
                                    "Once deleted, this event will be permanently removed.",
                                        () {},
                                  );
                                },
                                transitionBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                    ) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                              );

                              if (shouldDelete != true || !mounted) return;

                              if (eventData.id == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Unable to delete event"),
                                  ),
                                );
                                return;
                              }

                              context.read<EventsBloc>().add(
                                DeleteEvent(eventData.id!),
                              );
                            },
                          ),
SizedBox(height: h*0.02,),
Container(
 // height: double.infinity,
  width: double.infinity,
  decoration: BoxDecoration(
    color: ColorScheme.of(context).surface,
    borderRadius: BorderRadius.circular(w*0.07)
  ),
  child: Padding(
    padding:  EdgeInsets.all(w*0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(PartyPageData.aboutEvent,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: h*0.021
        ),),
        Text(
          eventData.aboutEvent??"",
        style:TextStyle(
          fontSize: h*0.021,
          fontWeight: FontWeight.w400,

        )
        ),
        SizedBox(height: h*0.02,),
        if(eventData.address?.addressLink=="")...[
        Text("Address: ${eventData.address?.addressText}", style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: h * 0.021,
          ),),
        ],
          if(eventData.address?.addressLink!="")  EventLocationMap(
          addressText: eventData.address?.addressText,
          addressLink: eventData.address?.addressLink,
        ),

SizedBox(height: h*0.02,),
        if (eventData.medias != null && eventData.medias!.isNotEmpty)
          ReusableMediaWidget<MediaModel>(
            media: eventData.medias!,

            // Check whether the media is a video
            isVideo: (item) {
              return item.mediaType == "VIDEO";
            },

            // Build image/video preview
            mediaPreview: (item) {
              final url = item.url ?? "";

              if (item.mediaType == "VIDEO") {
                return VideoPreview(
                  url: url,
                );
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

                loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                    ) {
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
            },

            // Open full-screen reusable viewer
            onMediaTap: (context, index) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReusableMediaViewer<MediaModel>(
                    media: eventData.medias!,
                    initialIndex: index,

                    // Check video
                    isVideo: (item) {
                      return item.mediaType == "VIDEO";
                    },

                    // Video screen
                    videoBuilder: (item) {
                      return FullScreenVideo(
                        url: item.url ?? "",
                      );
                    },

                    // Image URL
                    imageUrlBuilder: (item) {
                      return item.url;
                    },
                  ),
                ),
              );
            },
          ),
        if(eventData.tags!=null)  SizedBox(height: h*0.03,),
        if(eventData.tags!=null)
        FeedQuoteTab(
          title: PartyPageData.taggedPeople,
          isSelected: false,
          onTap: () async {
            await EventTaggedPeopleDialog.show(
              context: context,
              taggedPeople: eventData.tags ?? [],
            );
          },
          iconName: PartyPageData.tagPeopleIcon,
          height: h * 0.05,
          width: w * 0.45,
        ),
        SizedBox(height: h*0.03,),

      ],
    ),
  )
)
                        ],
                      )
                  ),
                  Positioned(
                    top: h*0.01,
                    right: w*0.05,
                    child: Container(
                      height: h*0.03,
                      width: h*0.03,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),

                      child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SvgPicture.asset(

                              PartyPageData.crossIcon,color: Colors.black,),
                          ))
                    ),
                  ),
                ],
              );

            });
      },
    );
  }
}
