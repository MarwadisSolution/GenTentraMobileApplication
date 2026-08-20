import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/reusable_functions.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';
import 'package:image_picker/image_picker.dart';

import 'feed_model.dart';

class AddQuote extends StatefulWidget {
  final List<Tagged> taggedPeople;

  final Future<void> Function() onAddTaggedPeople;
  final Future<void> Function() onShowTaggedPeople;
  final Future<void> Function(
      String quote,
      String authorName,
      XFile? image,
      ) onPublishQuote;
  final String? initialQuote;
  final String? initialAuthor;
  final String? initialImage;
  const AddQuote({super.key,
    required this.taggedPeople,
    required this.onAddTaggedPeople,
    required this.onShowTaggedPeople,
    required this.onPublishQuote,
    this.initialQuote,
    this.initialAuthor,
    this.initialImage,
  });
  @override
  State<AddQuote> createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {

  TextEditingController quoteController = TextEditingController();
  TextEditingController authorNameController = TextEditingController();

  XFile? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 85
      );
      if(image!=null){
        setState(() {
          selectedImage=image;
        });
      }
    }
    catch(e){
      debugPrint("Error picking image: $e");
    }
  }
  bool removeInitialImage = false;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    quoteController.text = widget.initialQuote ?? "";
    authorNameController.text = widget.initialAuthor ?? "";
  }
  @override
  void dispose() {
    quoteController.dispose();
    authorNameController.dispose();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: h*0.02,),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: w * 0.75,
            height: h * 0.28,
            child: TextFormField(
              controller: quoteController,

              maxLines: 3,
              maxLength: 50,

              keyboardType: TextInputType.multiline,

              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,

              style: TextStyle(
                fontSize: h * 0.038,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.31,
              ),

              decoration: InputDecoration(
                hintText: PartyPageData.sampleQuote,

                hintStyle: TextStyle(
                  fontSize: h * 0.038,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC0C0C0).withOpacity(0.3),
                  letterSpacing: 0.31,
                ),

                counter: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: quoteController,
                  builder: (context, value, child) {
                    final remaining = 50 - value.text.length;

                    return SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Max $remaining characters",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: h * 0.022,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),

                label: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: PartyPageData.addQuote,
                        style: TextStyle(
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .width * 0.044,
                          color: ColorScheme
                              .of(context)
                              .onSurface
                              .withOpacity(0.3),
                        ),
                      ),
                      const TextSpan(
                        text: " *",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.015,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorScheme
                        .of(context)
                        .onSurface
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorScheme
                        .of(context)
                        .onSurface
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),


        SizedBox(height: h * 0.05,),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: w * 0.75,
            height: h * 0.18,
            child: TextFormField(
              controller: authorNameController,

              maxLines: 2,

              keyboardType: TextInputType.multiline,

              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,

              style: TextStyle(
                fontSize: h * 0.038,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: 0.31,
              ),

              decoration: InputDecoration(
                hintText: PartyPageData.sampleAuthorName,

                hintStyle: TextStyle(
                  fontSize: h * 0.038,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC0C0C0).withOpacity(0.3),
                  letterSpacing: 0.31,
                ),


                label: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: PartyPageData.authorName,
                        style: TextStyle(
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .width * 0.044,
                          color: ColorScheme
                              .of(context)
                              .onSurface
                              .withOpacity(0.3),
                        ),
                      ),
                      const TextSpan(
                        text: " *",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.02,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorScheme
                        .of(context)
                        .onSurface
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ColorScheme
                        .of(context)
                        .onSurface
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: h * 0.05,),
        Center(
          child: Text(
            PartyPageData.addImage,
            style: TextStyle(
              fontSize: w * 0.045,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF656579),
            ),
          ),
        ),
        SizedBox(height: h * 0.025),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      width: w * 0.12,
      height: w * 0.12,
      decoration: BoxDecoration(
        color: selectedImage == null &&
            (widget.initialImage == null || removeInitialImage)
            ? Colors.black
            : Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: selectedImage == null &&
              (widget.initialImage == null || removeInitialImage)
              ? pickImage
              : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: SvgPicture.asset(
              PartyPageData.addIcon,
              color: ColorScheme.of(context).surface,
              height: w * 0.045,
              width: w * 0.045,
            ),
          ),
        ),
      ),
    ),
    SizedBox(width: w * 0.07),
    Container(
      width: w * 0.29,
      height: w * 0.29,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: ClipOval(
        child: selectedImage != null
            ? Image.file(
          File(selectedImage!.path),
          fit: BoxFit.cover,
        )
            : widget.initialImage != null && !removeInitialImage
            ? buildImageWidget(
          widget.initialImage!,
          fit: BoxFit.cover,
        )
            : Icon(
          Icons.image,
          size: w * 0.17,
          color: ColorScheme.of(context)
              .onSurface
              .withOpacity(0.2),
        ),

      ),
    ),
    SizedBox(width: w * 0.07),
    InkWell(
      onTap: () {
        if (selectedImage != null ) {
          setState(() {
            selectedImage = null;
          });
        }
        else if (widget.initialImage != null && !removeInitialImage) {
          setState(() {
            removeInitialImage = true;
          });
        }
      },
      customBorder: const CircleBorder(),
      child: Container(
        width: w * 0.12,
        height: w * 0.12,
        decoration: BoxDecoration(
          color: selectedImage != null ||
              (widget.initialImage != null && !removeInitialImage)
              ? Colors.black
              : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            PartyPageData.deleteIcon,
            color: Colors.white,

            height: w * 0.045,
            width: w * 0.045,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
],),
        SizedBox(height: h * 0.04),

        /// ---------------- TAGGING ----------------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  await widget.onAddTaggedPeople();
                },
                child: Container(
                  height: h * 0.057,
                  width: w * 0.27,
                  decoration: BoxDecoration(
                    gradient: GradientColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "@Tag",
                      style: TextStyle(
                        color: ColorScheme.of(context).surface,
                        fontWeight: FontWeight.w400,
                        fontSize: (w * 0.05).clamp(13.0, 16.0),
                      ),
                    ),
                  ),
                ),
              ),

              if (widget.taggedPeople.isNotEmpty) ...[
                SizedBox(width: w * 0.02),

                InkWell(
                  onTap: () async {
                    await widget.onShowTaggedPeople();
                  },
                  child: Container(
                    height: h * 0.057,
                    width: w * 0.63,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context)
                          .onSurface
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(h * 0.02),
                    ),
                    child: Row(
                      children: [
                        buildTaggedPeopleAvatars(
                          widget.taggedPeople,
                          h,
                          w,
                        ),

                        SizedBox(width: w * 0.02),

                        Text(
                          PartyPageData.taggedPeople,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: (w * 0.04).clamp(12.0, 14.0),
                          ),
                        ),

                        SizedBox(width: w * 0.02),

                        Transform.rotate(
                          angle: -1,
                          child: SvgPicture.asset(
                            PartyPageData.arrow,
                            color: const Color(0xFFFE3A31),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: h * 0.04),
        Center(
          child: InkWell(
            onTap: () async {
              if (quoteController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter quote"),
                  ),
                );
                return;
              }

              if (authorNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter author name"),
                  ),
                );
                return;
              }

              await widget.onPublishQuote(
                quoteController.text.trim(),
                authorNameController.text.trim(),
                selectedImage,
              );
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                gradient: GradientColors.primaryGradient,
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*0.03),
                border: Border.all(color: Color(0xFFFF2164)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.015,
                  right: MediaQuery.of(context).size.width * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      PartyPageData.addIcon,
                      color: ColorScheme.of(context).surface,
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Text(
                      PartyPageData.publish,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorScheme.of(context).surface,
                        fontWeight: FontWeight.w500,
                        fontSize: (MediaQuery.of(context).size.width * 0.04).clamp(14.0, 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: h * 0.04),
      ],
    );
  }
}


