import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/event_tab_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/full_event_desc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Event%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Reusable Functions/reusable_functions.dart';
import 'event_tab_event.dart';

class EventTab extends StatefulWidget {
  final int partyId;
  final ScrollController scrollController;

  const EventTab({
    super.key,
    required this.partyId,
    required this.scrollController,
  });

  @override
  State<EventTab> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {
  int? selectedIndex;
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


  // ------------------------------------------------------------
  // PAGINATION
  // ------------------------------------------------------------
  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final eventBloc = context.read<EventsBloc>();
    final eventState = eventBloc.state;

    if (widget.scrollController.position.extentAfter < 500 &&
        !eventState.isLoadingMore &&
        eventState.hasMore) {
      eventBloc.add(
        GetEventEvent(
          partyId: widget.partyId,
          page: eventState.currentPage + 1,
          size: eventState.pageSize,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // INIT STATE
  // ------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(_onScroll);

    context.read<EventsBloc>().add(
      GetEventEvent(partyId: widget.partyId, page: 0, size: 20),
    );
    checkAdmin();
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------
  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);

    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  final ValueNotifier<bool> isAddSelected = ValueNotifier(false);
  final GlobalKey menuKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocConsumer<EventsBloc, EventTabState>(
      listener: (context, state) {
        if (state.isSuccessInJoining) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
              content: Text(
                state.joiningActionMessage ?? "Event updated successfully",
              ),
            ),
          );
        }

        if (state.isErrorInJoining) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    "Please try again, failed to join the event",
              ),
            ),
          );
        }
      },

      builder: (context, state) {
        // --------------------------------------------------------
        // LOADING
        // --------------------------------------------------------
        if (state.status == EventStatus.loading) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorScheme.of(context).onSurface,
            ),
          );
        }

        // --------------------------------------------------------
        // ERROR
        // --------------------------------------------------------
        if (state.status == EventStatus.error) {
          return Center(
            child: Text(
              "Something went wrong",
              style: TextStyle(color: ColorScheme.of(context).onSurface),
            ),
          );
        }

        // --------------------------------------------------------
        // NO EVENTS
        // --------------------------------------------------------
        if (state.events.isEmpty) {
          return Center(
            child: Text(
              "No events found",
              style: TextStyle(color: ColorScheme.of(context).onSurface),
            ),
          );
        }

        // --------------------------------------------------------
        // MAIN EVENT UI
        // --------------------------------------------------------
        return Container(
          width: w,
          color: Colors.white,

          child: Column(
            children: [
              // --------------------------------------------------
              // WHITE SPACE ABOVE THE EVENT SECTION
              // --------------------------------------------------
              const SizedBox(height: 20),

              // --------------------------------------------------
              // GREY EVENT SECTION
              // --------------------------------------------------
              Container(
                width: w,

                decoration: const BoxDecoration(
                  color: Color(0xFFEFEFEF),

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),

                child: ListView.separated(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  padding: const EdgeInsets.only(top: 12, bottom: 12),

                  // ------------------------------------------------
                  // EVENT COUNT + LOADING MORE
                  // ------------------------------------------------
                  itemCount:
                      state.events.length + (state.isLoadingMore ? 1 : 0),

                  // ------------------------------------------------
                  // EVENT ITEM
                  // ------------------------------------------------
                  itemBuilder: (context, index) {

                    // ----------------------------------------------
                    // LOAD MORE INDICATOR
                    // ----------------------------------------------
                    if (index >= state.events.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    // ----------------------------------------------
                    // CURRENT EVENT
                    // ----------------------------------------------
                    final eventData = state.events[index];
                    print(eventData.address?.addressLink,);
                    // ----------------------------------------------
                    // TIME
                    // ----------------------------------------------
                    final fromTime = timingConversion(
                      eventData.eventFrom.toString(),
                    );

                    // ----------------------------------------------
                    // DATE
                    // ----------------------------------------------
                    final fromDate = eventData.eventFrom.toString().substring(
                      0,
                      10,
                    );

                    final DateTime parsedDate = DateTime.parse(fromDate);

                    final String formattedDate = DateFormat(
                      'dd-MM-yyyy',
                    ).format(parsedDate);

                    // ----------------------------------------------
                    // INDIVIDUAL EVENT CARD
                    // ----------------------------------------------
                    return InkWell(
                      onTap: () {
                        final eventBloc=context.read<EventsBloc>();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context){
                            return BlocProvider.value(value: eventBloc,
                              child: FullEventDesc(
                                eventData: eventData,
                                partyId: widget.partyId,
                              ),
                            );
                          }
                        );
                      },
                      child: Stack(
                        children: [
                          if (eventData.bgImage != null &&
                              eventData.bgImage!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              height: h * 0.5,
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
                          Padding(
                            padding: EdgeInsets.only(
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
                            child: ReusableEventCard(
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
                            )
                          ),
                        ],
                      ),
                    );
                  },

                  // ------------------------------------------------
                  // GAP BETWEEN CARDS
                  // ------------------------------------------------
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                ),
              ),
              SizedBox(height: h*0.03,),
            ],
          ),
        );
      },
    );
  }
}
