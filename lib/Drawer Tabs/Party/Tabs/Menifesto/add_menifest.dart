import 'dart:io';

import 'package:file_picker/file_picker.dart' show FilePicker, FileType, PlatformFile;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../../../Reusable Functions/reusable_functions.dart';

class AddMenifest extends StatefulWidget {
  const AddMenifest({super.key});

  @override
  State<AddMenifest> createState() => _AddMenifestState();
}

class _AddMenifestState extends State<AddMenifest> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  PlatformFile? selectedPdf;

  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          selectedPdf = result;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select PDF: $e'),
        ),
      );
    }
  }

  void removePdf() {
    setState(() {
      selectedPdf = null;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            ReusableSliverAppBar(
              title: PartyPageData.menifesto,
              automaticallyImplyLeading: false,
              isMenuNeeded: false,
              height: h * 0.06,
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SvgPicture.asset(
                        PartyPageData.crossIcon,
                        height: h * 0.023,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SliverFillRemaining(
              child: Stack(
                children: [
                  Container(
                    height: h * 0.08,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: GradientColorsForBellowAppbar
                          .gradientBelowAppbar,
                    ),
                  ),

                  Positioned.fill(
                    top: h * 0.02,
                    child: Container(
                      height: h,
                      width: w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),

                      child: Padding(
                        padding: EdgeInsets.only(
                          top: h * 0.03,
                          right: w * 0.04,
                          left: w * 0.04,
                        ),

                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Event Name
                              CustomTextField(
                                controller: titleController,
                                labelText: PartyPageData.eventName,
                                isRequired: true,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: ColorScheme.of(context).onSurface,
                                ),
                              ),

                              SizedBox(height: h * 0.04),

                              // Year
                              CustomTextField(
                                controller: yearController,
                                labelText: PartyPageData.year,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: ColorScheme.of(context).onSurface,
                                ),
                              ),

                              SizedBox(height: h * 0.04),

                              // Upload Manifesto
                              Text(
                                PartyPageData.uploadMenifesto,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: h * 0.02,
                                  color: const Color(0xFF656579),
                                ),
                              ),

                              SizedBox(height: h * 0.02),

                              // PDF picker
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: h * 0.09,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.04,
                                  vertical: h * 0.018,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ColorScheme.of(context)
                                        .onSurface
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),

                                child: Row(
                                  children: [

                                    // Selected PDF
                                    if (selectedPdf != null)
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: w * 0.035,
                                            vertical: h * 0.012,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEDEDED),
                                            borderRadius:
                                            BorderRadius.circular(25),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [

                                              // PDF filename
                                              Expanded(
                                                child: Text(
                                                  selectedPdf!.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: h * 0.017,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: w * 0.02),

                                              // Remove PDF
                                              InkWell(
                                                onTap: removePdf,
                                                child: Icon(
                                                  Icons.close,
                                                  size: h * 0.022,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      const Spacer(),

                                    SizedBox(width: w * 0.03),

                                    // Add PDF icon
                                    InkWell(
                                      onTap: pickPdf,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: SvgPicture.asset(
                                          PartyPageData.docAddIcon,
                                          height: h * 0.027,
                                          width: h * 0.027,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: h*0.04,),
                              InkWell(
                                onTap: (){
                                  ///----------Baki hai
                                },
                                child: Center(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                      gradient: GradientColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.height * 0.03,
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFFF2164),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            PartyPageData.addIcon,
                                            color: ColorScheme.of(context).surface,
                                            height: MediaQuery.of(context).size.height * 0.02,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.02,
                                          ),
                                          Text(PartyPageData.publish,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: ColorScheme.of(context).surface,
                                              fontWeight: FontWeight.w500,
                                              fontSize: (MediaQuery.of(context).size.width * 0.04)
                                                  .clamp(14.0, 16.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
