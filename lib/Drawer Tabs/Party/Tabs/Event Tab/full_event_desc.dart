import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import '../Feed Tab/apis.dart';
import '../Feed Tab/reusable_functions.dart';
import '../tagged_people_helper.dart';
import 'event._tag_peoples.dart';
import 'event_location_map.dart';
import 'event_modal.dart' show EventModel, MediaModel;
import '../Feed Tab/feed_model.dart' show Tagged;
import 'event_tab_bloc.dart';
import 'event_tab_event.dart';
class FullEventDesc extends StatefulWidget {
  final EventModel eventData;
  final int partyId;
  const FullEventDesc({super.key, required this.eventData, required this.partyId});

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
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    dynamic eventData=widget.eventData;
    print("Medias");
    print(eventData.medias);
    bool isAdmin=false;

    Future<void> checkAdmin() async {
      final admin = await AdminChecking.isAdmin(widget.partyId);

      if (!mounted) return;

      setState(() {
        isAdmin = admin;
      });
    }
    Future<void> shareFeed(dynamic event) async {
      final String shareLink =
          'https://gentantrabackend-production.up.railway.app/event/${event.uuid}';
      await Share.share('Check out this post: \n$shareLink');
    }
    final fromTime = timingConversion(
      eventData.eventFrom.toString(),
    );
    return BlocBuilder<EventsBloc, EventTabState>(
      builder: (context, state){
        return DraggableScrollableSheet(
            initialChildSize: 0.95,
            minChildSize: 0.95,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController){
              return Stack(
                children: [

                  if (eventData.bgImage != null &&
                      eventData.bgImage!.isNotEmpty)
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
                          eventData.bgImage!,
                          width: double.infinity,
                          height: h * 0.25,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Padding(padding: EdgeInsets.only(
                    top:
                    eventData.bgImage != null &&
                        eventData.bgImage!.isNotEmpty
                        ? h * 0.192
                        : 0,
                    left:
                    eventData.bgImage != null &&
                        eventData.bgImage!.isNotEmpty
                        ? w * 0.04
                        : 0,
                    right:
                    eventData.bgImage != null &&
                        eventData.bgImage!.isNotEmpty
                        ? w * 0.04
                        : 0,
                  ),
                      child:   ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          ReusableEventCard(
                            eventData: eventData,

                            isAdmin: isAdmin,

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

                            onEdit: () {
                              // Your edit logic
                            },

                            onDelete: () {
                              // Your delete logic
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
          eventData.aboutEvent,
        style:TextStyle(
          fontSize: h*0.021,
          fontWeight: FontWeight.w400,

        )
        ),
        SizedBox(height: h*0.02,),

        EventLocationMap(
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
                    top: 20,
                    right: 20,
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
