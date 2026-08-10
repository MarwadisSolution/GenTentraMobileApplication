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
import 'package:shared_preferences/shared_preferences.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  bool threeDotsSelected=false;
  int? selectedIndex;
   String? roles;
   int? partyAdminId=1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roleChecking();
    context.read<FeedBloc>().add(const LoadFeedEvent());
  }
  void roleChecking()async{
    final prefs = await SharedPreferences.getInstance();
    roles=prefs.getString("roles");
    //partyAdminId=prefs.getString("partyAdminId")! as int;
  }

  @override
  Widget build(BuildContext context) {
    final w=MediaQuery.of(context).size.width;
    final h=MediaQuery.of(context).size.height;
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }
        if (state.isError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.red,
                content: Text(state.errorMessage),
              ),
            );
          });

          return const SizedBox();
        }
        if (state.feeds.isEmpty) {
          return const Center(
            child: Text(
              "No Feed Available",
              style: TextStyle(color: Colors.black),
            ),
          );
        }
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  threeDotsSelected = false;
                  selectedIndex = null;
                });
                FocusScope.of(context).unfocus();
              },
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(h * 0.012),
                itemCount: state.feeds.length,
                itemBuilder: (context, index) {
                  final feed = state.feeds[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              
                      ListTile(
                        leading: CircleAvatar(
                              radius: w*0.07,
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
                          maxLines: 2,
                          feed.author?.name??"-",
                          style: TextStyle(
                            fontSize: (w * 0.04).clamp(14.0, 18.0),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.31,
                          ),
                        ),
                        subtitle: Text(
                          feed.author?.region??"-",
                          style: TextStyle(
                            fontSize: (w*0.025).clamp(12, 15),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.21,
                            color: Color(0xFF666666)
                          ),
                        ),
                          trailing: InkWell(
                            onTap: (){
                              setState(() {
                                threeDotsSelected=true;
                                selectedIndex=index;
                              });
                            },
                            child: SizedBox(
                              height: h*0.044,
                              width: w*0.044,
                              child: SvgPicture.asset(PartyPageData.threeDots,
                              height: h*0.004,
                              ),
                            ),
                          ),
                      ),
                     ///-------------Yeha pe tagged wale aayege
                      Padding(
                        padding:  EdgeInsets.only(top: 8.0,right: w*0.044,left: w*0.044),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReadMoreText(
                              feed.body??"-",
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
                              style:  TextStyle(
                                fontSize: (w*0.04).clamp(12, 16),
                                color: Colors.black,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                            ///---------Images will come
              
                            if (feed.media != null && feed.media!.isNotEmpty) ...[
                              SizedBox(height: h * 0.012),
              
                              FeedMediaWidget(
                                media: feed.media!,
                              ),
                            ],
              
                            ///-----Views
                            Row(
                              children: [
                                Text(feed.viewCount.toString(),
                                  style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                    fontSize: (w*0.03).clamp(16, 18),
                                ),),
                                SizedBox(width: w*0.03,),
                                Text("Views",style: TextStyle(
                                  fontSize: (w*0.025).clamp(12, 15),
                                  fontWeight: FontWeight.w400,
                                  color: ColorScheme.of(context).onSurface.withOpacity(0.6),
                                ),)
                              ],
                            )
                          ],
                        ),
                      ),
                    SizedBox(height: h*0.01,),
                    Container(
              
                    color: Color(0xFF000000).withOpacity(0.08),
                      width: w,
                      height: h*0.009,)
                    ],
              
                  );
                },
              ),
            ),

            if(threeDotsSelected)
              Positioned(
                right: w*0.028,
                top: h*0.04 + (
                    selectedIndex!* 10),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: w*0.18,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      //shape: BoxShape.circle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        (MediaQuery.of(context).size.width * 0.1).clamp(16.0, 40.0),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(
                        //roles=="SuperAdmin" || roles=="PartyAdmin" &&
                            partyAdminId == 1
                        //     state.feeds[
                        // selectedIndex! ].author?.id
                        )...[
                          InkWell(
                            onTap: (){
                              ///------Baki hai
                            },
                            child: SizedBox(
                              height: h*0.044,
                              width: w*0.044,
                              child: SvgPicture.asset(PartyPageData.edit,
                                height: h*0.004,
                              ),
                            ),
                          ),

                        Text(
                          "Edit",style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: (w*0.027).clamp(12, 15),
                        ),)
        ],
                        SizedBox(height: h*0.017,),
                        InkWell(
                          onTap:(){
                            ///------Baki hai
                          },
                          child: SizedBox(
                            height: h*0.044,
                            width: w*0.044,
                            child: SvgPicture.asset(PartyPageData.share,
                              height: h*0.004,
                            ),
                          ),
                        ),

                        Text(
                          "Share",style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: (w*0.027).clamp(12, 15),
                        ),),
                        SizedBox(height: h*0.017,),
                        if(
                       // roles=="SuperAdmin" || roles=="PartyAdmin" &&
                            partyAdminId== 1)...[
                        InkWell(
                          onTap:(){
                        ///------Baki hai
                          },
                          child: SizedBox(
                            height: h*0.044,
                            width: w*0.044,
                            child: SvgPicture.asset(PartyPageData.deleteIcon,
                              height: h*0.004,
                            ),
                          ),
                        ),

                        Text(
                          "Delete",style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: (w*0.027).clamp(12, 15),
                        ),),
                          SizedBox(height: h*0.017,),
                      ],
                      ],
                    ),
                  ),
                ),

              )
          ],
        );

      },
    );
  }
}
