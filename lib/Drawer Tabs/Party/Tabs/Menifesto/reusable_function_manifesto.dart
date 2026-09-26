
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../party_page_data.dart';
import '../../reusable_functions.dart';
import 'add_menifest.dart';
import 'manifesto_bloc.dart';
import 'manifesto_event.dart';
import 'manifesto_model.dart';

Widget manifestoCard(
    BuildContext context,
    ManifestoModel manifesto,
    bool isAdmin,
    double h,
    double w,
 int partyId,
bool mounted,
    ) {
  return InkWell(
    onTap: () {
      final fileUrl = manifesto.fileUrl;

      if (fileUrl == null || fileUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
              backgroundColor: ColorScheme.of(context).error,
              content: Text("Manifesto PDF is not available",style: TextStyle(color: ColorScheme.of(context).surface))),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ManifestoPdfViewer(fileUrl: fileUrl, title: manifesto.title),
        ),
      );
    },

    child: Card(
      color: ColorScheme.of(context).surface,
      shadowColor: Colors.black.withOpacity(0.2),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
        side: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      margin: EdgeInsets.only(
        bottom: h * 0.01,
        right: w * 0.02,
        left: w * 0.02,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: w * 0.04,
          left: w * 0.02,
          top: w * 0.02,
          bottom: w * 0.02,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(PartyPageData.pdfIcon, height: w * 0.085),
            SizedBox(width: w * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${PartyPageData.manifestoCard} ${manifesto.year}",
                  style: TextStyle(
                    fontSize: h * 0.025,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "View",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: h * 0.019,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            if (isAdmin == true) ...[
              Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ManifestoBloc>(),
                        child: AddManifest(
                          partyId: partyId,
                          manifesto: manifesto,
                        ),
                      ),
                    ),
                  );

                  if (result == true && mounted) {
                    context.read<ManifestoBloc>().add(
                      GetManifestosEvent(
                        partyId: partyId,
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: w * 0.12,
                  height: w * 0.12,
                  child: Center(
                    child: SvgPicture.asset(
                      PartyPageData.addIconMenifesto,
                      width: w * 0.06,
                    ),
                  ),
                ),
              ),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: ()async{
                  final shouldDelete= await showGeneralDialog<bool>(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Delete',
                      barrierColor: Colors.black.withOpacity(0.25),
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (dialogContext, _, __){
                        return popUpMessageForDeleteOrCancel(
                          dialogContext,
                          PartyPageData.deleteIcon,
                          "Would you like to Delete?",
                          "Once deleted, this manifesto will be permanently removed.",
                              () {},
                        );
                      },
                      transitionBuilder: (context, animation, secondaryAnimation, child){
                        return SlideTransition( position: Tween<Offset>(
                          begin: const Offset(0,1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                          child: child,
                        );

                      }
                  );

                  if(shouldDelete==true && mounted){
                    context.read<ManifestoBloc>().add(
                      DeleteManifestoEvent(manifestoId: manifesto.id!),
                    );
                  }
                  // _showDeleteConfirmation(context, manifesto);
                },
                child: SizedBox(
                  width: w * 0.12,
                  height: w * 0.12,
                  child: Center(
                    child: SvgPicture.asset(
                      PartyPageData.deleteIcon,
                      color: const Color(0xFFFE3A31),
                      width: w * 0.045,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}