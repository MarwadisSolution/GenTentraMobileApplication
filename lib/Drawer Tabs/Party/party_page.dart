import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_bloc_in_one.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_fetched_data.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_apis.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../Reusable Functions/reusable_functions.dart';

class PartyPage extends StatefulWidget {
  const PartyPage({super.key});

  @override
  State<PartyPage> createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage> {
  final apiService = PartyPageApis();
  bool _isLoadingParty = false;
final ScrollController _scrollController = ScrollController();
  late PartyBloc _partyBloc;
  @override
  void initState() {
    super.initState();
   _scrollController.addListener(_onScroll);
  }
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 300) {
      final currentState = _partyBloc.state;

      if (currentState is PartyLoaded &&
          currentState.hasMore &&
          !currentState.isLoadingMore) {
        _partyBloc.add(
          FetchPartiesEvent(loadMore: true),
        );
      }
    }
  }
Future<void>_openParty(dynamic party)async{
    if(_isLoadingParty) return;
    setState(() {
      _isLoadingParty = true;
    });
    try{
      final partyData = await apiService.fetchPartySingleWithId(party["id"]);
      if(!mounted)return;
      Navigator.push(
          context,
        MaterialPageRoute(
          builder: (_) => PartyFetchedData(
            partyData: partyData,
          ),
        ),
      );
    }
    catch(e){
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          backgroundColor: ColorScheme.of(context).error,
          content: Text("Failed to load party details"),
        ),
      );
    } finally{
      if(mounted){
        setState(() {
          _isLoadingParty= false;
        });
      }
    }

}
  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery
        .of(context)
        .size
        .width;
    final h = MediaQuery
        .of(context)
        .size
        .height;
    final isMobile = w < 600;
    final isTablet = w >= 600 && w < 900;
    final isDesktop = w >= 900;

    final gridCount = isDesktop
        ? 6
        : isTablet
        ? 5
        : 3;
    return BlocProvider(
      create: (context){
        _partyBloc=PartyBloc(apiService)..add(FetchPartiesEvent());
        return _partyBloc;
      },
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            body: Stack(
              children: [
                CustomScrollView(
                    slivers: [
                      ReusableSliverAppBar(
                        title: "PARTY'S",
                          automaticallyImplyLeading: true,
                          height: h*0.07
                      ),
                      SliverFillRemaining(
                        child: Stack(
                          children: [
                            Container(
                              height: h * 0.08,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: GradientColorsForBellowAppbar.gradientBelowAppbar,
                              ),
                            ),
                            Positioned.fill(
                              top: h * 0.02,
                              child: Container(

                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25))
                                  ),
                                  child: BlocBuilder<PartyBloc, PartyState>(
                                      builder: (context,state){
                                        if(state is PartyLoading || state is PartyInitial){
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: ColorScheme.of(context)
                                                  .onSurface,
                                            ),
                                          );
                                        }
                                        if(state is PartyError){
                                          return Center(
                                            child: Text("Please come back and try."),
                                          );
                                        }
                                      if(state is PartyLoaded){
                                        final parties = state.parties;
                                        if(parties.isEmpty){
                                          return const Center(
                                            child: Text("No parties found"),
                                          );
                                        }
                                        return Padding(
                                                padding:  EdgeInsets.only(
                                                    right: MediaQuery.of(context).size.width*0.025,
                                                    left: MediaQuery.of(context).size.width*0.025,
                                                    top: MediaQuery.of(context).size.height*0.025),
                                                child: GridView.builder(
                                                  controller: _scrollController,
                                                  physics: const AlwaysScrollableScrollPhysics(),
                                                  padding:  EdgeInsets.all(MediaQuery.of(context).size.height*0.005),
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: gridCount,
                                                    crossAxisSpacing: 5,
                                                    mainAxisSpacing: 15,
                                                    childAspectRatio: 0.9,
                                                  ),
                                                  itemCount: parties.length+ (state.isLoadingMore ? 1 : 0),
                                                  itemBuilder: (context, index) {
                                                    if (index >= parties.length) {
                                                      return  Center(
                                                        child:
                                                        CircularProgressIndicator(color: ColorScheme.of(context).onSurface,),
                                                      );
                                                    }
                                                    final party = parties[index];
                                                    return InkWell(
                                                      
                                                     onTap:()=>_openParty(party) ,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [

                                                          Container(
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,

                                                            ),
                                                            child: CircleAvatar(
                                                              radius:  MediaQuery.of(context).size.width*0.11,
                                                              backgroundColor: Colors.white,
                                                              child: ClipOval(
                                                                child: SizedBox.expand(
                                                                  child:  (party["partySymbolUrl"] != null &&
                                                                      (party["partySymbolUrl"] as String)
                                                                          .isNotEmpty)
                                                                      ? buildImageWidget(
                                                                    party["partySymbolUrl"],
                                                                    fit: BoxFit.contain,
                                                                  )
                                                                      : Icon(
                                                                    Icons.image,
                                                                    color: ColorScheme
                                                                        .of(context)
                                                                        .onSurface,
                                                                  ),
                                                                ),
                                                              )

                                                            ),
                                                          ),
                                                          SizedBox(height: h*0.01),
                                                          Text(
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            party["partyInitial"] ?? "",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(fontSize: w*0.04, fontWeight: FontWeight.w600
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                      }
                                        return const SizedBox.shrink();
                                      }

                                  ),

                              ),
                            ),
                          ],
                        ),

                      ),
                SliverToBoxAdapter(
                  child: SizedBox(height: h*0.055,),
                )
                    ],
                ),
          if (_isLoadingParty)...[
          Positioned.fill(
            child: Container(
              color: ColorScheme.of(context).onSurface.withValues(alpha: 0.2),
              child: Center(
                child: CircularProgressIndicator(
                  color:  ColorScheme.of(context).onSurface,
                ),
              ),
            ),
          )
          ],

              ],
            ),

          );
        }
      ),
    );
  }
}
