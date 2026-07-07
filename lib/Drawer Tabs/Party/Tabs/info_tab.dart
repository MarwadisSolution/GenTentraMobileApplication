import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:readmore/readmore.dart';
class InfoTab extends StatelessWidget {
  final Map<String, dynamic> partyData;
  const InfoTab({super.key, required this.partyData});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpandableQuillContent(
            content: partyData["info"] ?? "",
          ),
SizedBox(height: MediaQuery.of(context).size.height*0.05,),
          infoData(context, PartyPageData.foundedIcon,PartyPageData.founded,partyData["foundedOn"] ?? "-"  ),
          infoData(context, PartyPageData.flagIcon,PartyPageData.founded,partyData["founder"] ?? "-"  ),
          infoData(context, PartyPageData.personIcon,PartyPageData.founded,partyData["president"]?["name"] ?? "-"  ),
          infoData(context, PartyPageData.personIcon,PartyPageData.founded,partyData["generalSecretary"] ?? "-"  ),
          infoData(context, PartyPageData.headquarterIcon,PartyPageData.founded,partyData["headquarters"] ?? "-"  ),
          infoData(context, PartyPageData.globalIcon,PartyPageData.founded,partyData["website"] ?? "-"  ),
          //infoData(context, PartyPageData.foundedIcon,PartyPageData.founded,partyData["foundedOn"] ?? ""  ),
        ],
      ),
    );
  }
}

Widget infoData(BuildContext context,String icon,String title, String data){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
      padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
      child: SvgPicture.asset(icon,),
    ),
    SizedBox(width: MediaQuery.of(context).size.width*0.07,),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.21,
            color: Color(0xFF666666),
          ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01,),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              data,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize:16,letterSpacing: 0.31
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03,)
        ],
      )
    ]
  );
}

class ExpandableQuillContent extends StatefulWidget {
  final String content;

  const ExpandableQuillContent({
    super.key,
    required this.content,
  });

  @override
  State<ExpandableQuillContent> createState() =>
      _ExpandableQuillContentState();
}

class _ExpandableQuillContentState
    extends State<ExpandableQuillContent> {

  bool isExpanded = false;
  late QuillController controller;

  @override
  void initState() {
    super.initState();

    controller = QuillController(
      document: _buildDocument(widget.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Document _buildDocument(String content) {
    if (content.isEmpty) {
      return Document();
    }

    try {
      return Document.fromJson(
        jsonDecode(content),
      );
    } catch (_) {
      return Document()..insert(0, content);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints: isExpanded
              ? const BoxConstraints()
              : const BoxConstraints(maxHeight: 120),
          child: QuillEditor.basic(
            controller: controller,
            config: const QuillEditorConfig(
              showCursor: false,
            ),
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded
                ? "Read Less"
                : "Read More",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFFE3A31),
            ),
          ),
        ),
      ],
    );
  }
}