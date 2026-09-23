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
import '../../../../Reusable Functions/reusable_functions.dart';
import '../../reusable_functions.dart';
import 'add_event.dart';
import 'apis.dart';
import 'event_modal.dart';
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
  List<EventModel> _getFilteredEvents(
      List<EventModel> events,
      int selectedTab,
      ) {
    switch (selectedTab) {
    // ----------------------------------------------------------
    // ALL EVENTS
    // ----------------------------------------------------------
      case 0:
        return events;

    // ----------------------------------------------------------
    // MY EVENTS
    // ----------------------------------------------------------
      case 1:
      // Current logged-in user ID is not available
      // in EventTab yet.
      //
      // Do not use AdminOfParty here because that is
      // the party-admin ID, not the logged-in user ID.
        return events;

    // ----------------------------------------------------------
    // PRIVATE EVENTS
    // ----------------------------------------------------------
      case 2:
        return events
            .where(
              (event) => event.kind.toUpperCase() == "PRIVATE",
        )
            .toList();

    // ----------------------------------------------------------
    // PAST EVENTS
    // ----------------------------------------------------------
      case 3:
        return events
            .where(_hasEventEnded)
            .toList();

      default:
        return events;
    }
  }
  bool _hasEventEnded(EventModel event) {
    if (event.eventTo == null || event.timeTo == null) {
      return false;
    }

    final endDateTime = DateTime(
      event.eventTo!.year,
      event.eventTo!.month,
      event.eventTo!.day,
      event.timeTo!.hour,
      event.timeTo!.minute,
    );

    return DateTime.now().isAfter(endDateTime) ||
        DateTime.now().isAtSameMomentAs(endDateTime);
  }
  bool _hasEventStarted(EventModel event) {
    if (event.eventFrom == null ||
        event.timeFrom == null) {
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
                state.joiningActionMessage ??
                    "Event updated successfully",
              ),
            ),
          );

          // Consume the message so it cannot appear again
          // when another state change happens.
          context.read<EventsBloc>().add(
            ClearJoinMessageEvent(),
          );
        }

        if (state.isErrorInJoining) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                state.errorMessage ??
                    "Please try again, failed to join the event",
              ),
            ),
          );

          // Consume the error message
          context.read<EventsBloc>().add(
            ClearJoinMessageEvent(),
          );
        }

        // DELETE SUCCESS
        // DELETE SUCCESS
        if (state.isEventDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              content: Text(
                "Event deleted successfully",
              ),
            ),
          );

          // Consume delete success message so it cannot appear again
          // when another BLoC state change happens.
          context.read<EventsBloc>().add(
            ClearDeleteMessageEvent(),
          );
        }

        // DELETE ERROR
        if (state.status == EventStatus.error &&
            !state.isErrorInJoining &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
              content: Text(
                state.errorMessage!,
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
            child: Padding(
              padding: EdgeInsets.all(h*0.1),
              child: CircularProgressIndicator(
                color: ColorScheme.of(context).onSurface,
              ),
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
        final List<EventModel> filteredEvents =
        _getFilteredEvents(
          state.events,
          state.selectedTab,
        );
        return Container(
          width: w,
          color: Colors.white,

          child: Column(
            children: [
              SizedBox(height: h*0.01),
              buildEventTabs(
                context,
                state,
              ),
              SizedBox(height: h*0.01),
              filteredEvents.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 60,
                  horizontal: 20,
                ),
                child: Center(
                  child: Text(
                    emptyMessage(state.selectedTab),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorScheme.of(context).onSurface,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
                  : ListView.separated(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                padding:  EdgeInsets.only(top: h*0.003,),

                // ------------------------------------------------
                // EVENT COUNT + LOADING MORE
                // ------------------------------------------------
                itemCount:
                filteredEvents.length +
                    (state.isLoadingMore ? 1 : 0),

                // ------------------------------------------------
                // EVENT ITEM
                // ------------------------------------------------
                itemBuilder: (context, index) {

                  // ----------------------------------------------
                  // LOAD MORE INDICATOR
                  // ----------------------------------------------
                  if (index >= filteredEvents.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // ----------------------------------------------
                  // CURRENT EVENT
                  // ----------------------------------------------
                  final eventData =filteredEvents[index];
                  // ----------------------------------------------
                  // TIME
                  // ----------------------------------------------



                  final fromDate = eventData.eventFrom.toString().substring(
                    0,
                    10,
                  );



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
                              isAdmin: isAdmin,
                            ),
                          );
                        }
                      );
                    },
                    child: Stack(
                      children: [
                        if (eventData.bgImageUrl != null &&
                            eventData.bgImageUrl!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            height: w*1.2 ,
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
                        Padding(
                          padding: EdgeInsets.only(
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
                          child: ReusableEventCard(
                            eventData: eventData,

                            isAdmin: isAdmin,

                            fromTime: eventData.timeFrom.toString(),

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

                              if (updated == true && mounted) {
                                context.read<EventsBloc>().add(
                                  GetEventEvent(
                                    partyId: widget.partyId,
                                    page: 0,
                                    size: 20,
                                  ),
                                );
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

                              if (shouldDelete == true && mounted) {
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
                              }
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
                  return  SizedBox(height: h*0.02);
                },
              ),
              SizedBox(height: h*0.03,),
            ],
          ),
        );
      },
    );
  }
}
