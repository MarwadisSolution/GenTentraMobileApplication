import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

// Change this import to wherever your EventApis and models are located.
import '../../../../Reusable Functions/reusable_functions.dart';
import 'event_modal.dart';
import 'apis.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import 'event_tab_bloc.dart';
import 'event_tab_event.dart';
import 'event_tab_state.dart';
import 'event_modal.dart';
import 'apis.dart';

class AttendanceCountPage extends StatefulWidget {
  final int eventId;

  const AttendanceCountPage({
    super.key,
    required this.eventId,
  });

  @override
  State<AttendanceCountPage> createState() =>
      _AttendanceCountPageState();
}

class _AttendanceCountPageState
    extends State<AttendanceCountPage> {

  // ----------------------------------------------------------
  // CONTROLLERS
  // ----------------------------------------------------------

  final EventsBloc _eventsBloc = EventsBloc(EventApis());

  final TextEditingController _searchController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();
  Timer? _searchDebounce;

  // ----------------------------------------------------------
  // INIT
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _eventsBloc.add(
      GetAttendanceEvent(
        eventId: widget.eventId,
        page: 0,
        size: 20,
      ),
    );
  }
  @override
  void dispose() {
    _searchDebounce?.cancel();

    _searchController.dispose();
    _scrollController.dispose();
    _eventsBloc.close();

    super.dispose();
  }


  // ----------------------------------------------------------
  // PAGINATION
  // ----------------------------------------------------------

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.extentAfter < 500) {
      final state = _eventsBloc.state;

      // Do not load another API page while local search is active.
      if (state.attendanceSearch.isNotEmpty) {
        return;
      }

      if (state.attendanceHasMore &&
          !state.isLoadingMoreAttendance &&
          !state.isLoadingAttendance &&
          !state.isSearchingAttendance) {

        _eventsBloc.add(
          GetAttendanceEvent(
            eventId: widget.eventId,
            page: state.attendanceCurrentPage + 1,
            size: state.attendancePageSize,
          ),
        );
      }
    }
  }

  // ----------------------------------------------------------
  // SEARCH
  // ----------------------------------------------------------

  void _search() {
    _eventsBloc.add(
      SearchAttendanceEvent(
        eventId: widget.eventId,
        search: _searchController.text.trim(),
      ),
    );
  }
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
          () {
        if (!mounted) return;

        _search();
      },
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocProvider.value(
      value: _eventsBloc,

      child: Builder(
        builder: (context) {

          return Scaffold(
            body: Stack(
              children: [

                // ==================================================
                // SCROLLABLE CONTENT
                // ==================================================

                CustomScrollView(
                  controller: _scrollController,

                  slivers: [

                    // ------------------------------------------------
                    // APP BAR
                    // ------------------------------------------------

                    ReusableSliverAppBar(
                      title: "COUNT",

                      automaticallyImplyLeading: false,

                      isMenuNeeded: false,

                      height: h * 0.09,

                      actions: [

                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: Padding(
                            padding: EdgeInsets.only(
                              right: w * 0.04,
                            ),

                            child: SvgPicture.asset(
                              PartyPageData.crossIcon,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ------------------------------------------------
                    // CONTENT
                    // ------------------------------------------------

                    SliverFillRemaining(
                      hasScrollBody: true,

                      child: Container(
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEFEF),

                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              h * 0.025,
                            ),

                            topRight: Radius.circular(
                              h * 0.025,
                            ),
                          ),
                        ),

                        padding: EdgeInsets.only(
                          top: h * 0.055,

                          left: w * 0.025,

                          right: w * 0.025,
                        ),

                        child: BlocBuilder<
                            EventsBloc,
                            EventTabState>(
                          builder: (
                              context,
                              state,
                              ) {

                            // ========================================
                            // INITIAL LOADING
                            // ========================================

                            if (
                            state.isLoadingAttendance &&
                                state.attendees.isEmpty
                            ) {

                              return const Center(
                                child:
                                CircularProgressIndicator(),
                              );
                            }

                            // ========================================
                            // ERROR
                            // ========================================

                            if (
                            state.attendanceError != null &&
                                state.attendees.isEmpty
                            ) {

                              return Center(
                                child: Text(
                                  state.attendanceError!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            // ========================================
                            // EMPTY
                            // ========================================

                            if (state.attendees.isEmpty) {

                              return Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,

                                  children: [

                                    Icon(
                                      Icons.people_outline,
                                      size: h * 0.07,

                                      color: Colors.grey,
                                    ),

                                    SizedBox(
                                      height: h * 0.015,
                                    ),

                                    Text(
                                      state.attendanceSearch
                                          .isNotEmpty
                                          ? "No person found"
                                          : "No attendees yet",

                                      style:
                                      const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // ========================================
                            // ATTENDEE LIST
                            // ========================================

                            return ListView.builder(

                              padding: EdgeInsets.zero,

                              itemCount:
                              state.attendees.length +
                                  (state.isLoadingMoreAttendance
                                      ? 1
                                      : 0),

                              itemBuilder: (
                                  context,
                                  index,
                                  ) {

                                // ------------------------------------
                                // PAGINATION LOADER
                                // ------------------------------------

                                if (
                                index >=
                                    state.attendees.length
                                ) {

                                  return const Padding(
                                    padding:
                                    EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),

                                    child: Center(
                                      child:
                                      CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final attendee =
                                state.attendees[index];

                                return _buildAttendeeTile(
                                  attendee,
                                  w,
                                  h,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // ==================================================
                // FIXED SEARCH BAR
                // ==================================================

                Positioned(
                  top: h * 0.13,

                  left: w * 0.025,

                  right: w * 0.025,

                  child: _buildSearchBar(
                    w,
                    h,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(
      double w,
      double h,
      ) {

    return Container(
      height: h * 0.07,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(
          h * 0.018,
        ),
      ),

      child: Row(
        children: [

          SizedBox(
            width: w * 0.04,
          ),

          // ----------------------------------------------------
          // PERSON SEARCH ICON
          // ----------------------------------------------------

          SvgPicture.asset(
            PartyPageData.personSearchIcon,

            height: h * 0.025,

            width: h * 0.025,
          ),

          SizedBox(
            width: w * 0.025,
          ),

          // ----------------------------------------------------
          // TEXT FIELD
          // ----------------------------------------------------

          Expanded(
            child: TextField(

              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction:
              TextInputAction.search,

              onSubmitted: (_) {
                _search();
              },

              decoration: const InputDecoration(
                border: InputBorder.none,

                enabledBorder:
                InputBorder.none,

                focusedBorder:
                InputBorder.none,

                isDense: true,

                hintText: "Search person",
              ),
            ),
          ),

          // ----------------------------------------------------
          // SEARCH
          // ----------------------------------------------------

          InkWell(
            onTap:
              _search,

            child: Padding(
              padding: EdgeInsets.only(
                right: w * 0.04,
              ),
              child: Text(
                "Search",
                style: TextStyle(
                  color: const Color(0xFFFE3A31),
                  fontSize: h * 0.017,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDEE TILE
  // ============================================================

  Widget _buildAttendeeTile(
      AttendeePreview attendee,
      double w,
      double h,
      ) {

    final user = attendee.user;

    final String name =
    user?.name?.trim().isNotEmpty == true
        ? user!.name!
        : "Unknown User";

    final String? imageUrl =
        user?.imageUrl;

    return Container(

      margin: EdgeInsets.only(
        bottom: h * 0.012,
      ),

      padding: EdgeInsets.symmetric(
        horizontal: w * 0.035,

        vertical: h * 0.012,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(
          h * 0.018,
        ),
      ),

      child: Row(
        children: [

          // ----------------------------------------------------
          // PROFILE
          // ----------------------------------------------------

          _buildProfileImage(
            imageUrl: imageUrl,
            h: h,
          ),

          SizedBox(
            width: w * 0.035,
          ),

          // ----------------------------------------------------
          // NAME + LOCATION
          // ----------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: h * 0.02,

                    fontWeight:
                    FontWeight.w700,
letterSpacing: 0.31,
                    color: Colors.black,
                  ),
                ),

                SizedBox(
                  height: h * 0.004,
                ),

                // Text(
                //   "MUMBAI, MH",
                //
                //   style: TextStyle(
                //     fontSize: h * 0.0145,
                //
                //     color: Colors.grey,
                //
                //     fontWeight:
                //     FontWeight.w400,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage({

    String? imageUrl,

    required double h,
  }) {

    final bool hasImage =
        imageUrl != null &&
            imageUrl.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,

      ),
      child: CircleAvatar(

        radius: h * 0.035,

        backgroundColor: Colors.white,
        child: ClipOval(
          child: SizedBox.expand(
            child: hasImage?
            buildImageWidget(imageUrl!,fit: BoxFit.fitWidth)
                :Icon(Icons.person),
          ),


        ),
      ),
    );
  }

}