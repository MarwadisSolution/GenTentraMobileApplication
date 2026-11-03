import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_events.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_states.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Reusable Functions/reusable_functions.dart';

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

    return BlocConsumer<DevelopmentBloc, DevelopmentState>(listener: listener);
  }
}
