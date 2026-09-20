import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/reusable_functions.dart';

import 'add_menifest.dart';
import 'manifesto_bloc.dart';
import 'manifesto_event.dart';
import 'manifesto_model.dart';
import 'manifesto_state.dart';

class ManifestoTab extends StatefulWidget {
  final int partyId;
  final ScrollController scrollController;
  final bool isAdmin;
  const ManifestoTab({
    super.key,
    required this.partyId,
    required this.scrollController,
    required this.isAdmin,
  });

  @override
  State<ManifestoTab> createState() => _ManifestoTabState();
}

class _ManifestoTabState extends State<ManifestoTab> {
  List<ManifestoModel> _filteredManifestos(
      List<ManifestoModel> manifestos,
      ) {
    if (_selectedYear == null) {
      return manifestos;
    }

    return manifestos.where((manifesto) {
      return manifesto.year == _selectedYear;
    }).toList();
  }
  int? _selectedYear;
  Widget _yearFilterChip({
    required BuildContext context,
    required String title,
    required int? year,
  }) {
    final bool isSelected = _selectedYear == year;

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        filterByYear(year);
      },
      child: Container(
        margin: EdgeInsets.only(
          right: w * 0.025,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.055,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF4B3A)
              : const Color(0xFFBDBDBD),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: h * 0.018,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    // Use the controller provided by PartyFetchedData.
    widget.scrollController.addListener(_onScroll);

    // Initial GET
    context.read<ManifestoBloc>().add(
      GetManifestosEvent(
        partyId: widget.partyId,
      ),
    );
  }
  void filterByYear(int? year) {
    setState(() {
      _selectedYear = year;
    });
  }
  List<int> _availableYears(List<ManifestoModel> manifestos) {
    final years = manifestos
        .map((manifesto) => manifesto.year)
        .whereType<int>()
        .toSet()
        .toList();

    years.sort();

    return years;
  }

  // ==========================================================
  // PAGINATION
  // ==========================================================

  void _onScroll() {
    if (!widget.scrollController.hasClients) {
      return;
    }

    if (widget.scrollController.position.extentAfter < 500) {
      context.read<ManifestoBloc>().add(
        const LoadMoreManifestosEvent(),
      );
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w=MediaQuery.of(context).size.width;
    final h=MediaQuery.of(context).size.height;
    return BlocConsumer<ManifestoBloc, ManifestoState>(
      // ========================================================
      // LISTENER
      // ========================================================

      listener: (context, state) {

        // ------------------------------------------------------
        // UPLOAD SUCCESS
        // ------------------------------------------------------

        if (state.postStatus ==
            ManifestoActionStatus.success) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Manifesto uploaded successfully",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // UPLOAD FAILED
        // ------------------------------------------------------

        if (state.postStatus ==
            ManifestoActionStatus.error) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ??
                    "Failed to upload manifesto",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // UPDATE SUCCESS
        // ------------------------------------------------------

        if (state.updateStatus ==
            ManifestoActionStatus.success) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Manifesto updated successfully",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // UPDATE FAILED
        // ------------------------------------------------------

        if (state.updateStatus ==
            ManifestoActionStatus.error) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ??
                    "Failed to update manifesto",
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // GET FAILED
        // ------------------------------------------------------

        if (state.status ==
            ManifestoStatus.error) {

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ??
                    "Failed to load manifestos",
              ),
            ),
          );
        }
      },

      // ========================================================
      // BUILDER
      // ========================================================

      builder: (context, state) {

        // ------------------------------------------------------
        // INITIAL LOADING
        // ------------------------------------------------------

        if (state.status ==
            ManifestoStatus.loading &&
            state.manifestos.isEmpty) {

          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ------------------------------------------------------
        // ERROR + NO DATA
        // ------------------------------------------------------

        if (state.status ==
            ManifestoStatus.error &&
            state.manifestos.isEmpty) {

          return Center(
            child: Text(
              state.message ??
                  "Failed to load manifesto",
            ),
          );
        }

        // ------------------------------------------------------
        // EMPTY
        // ------------------------------------------------------

        // if (state.manifestos.isEmpty) {
        //   return const Center(
        //     child: Padding(
        //       padding: EdgeInsets.all(30),
        //       child: Text(
        //         "No manifesto found",
        //       ),
        //     ),
        //   );
        // }

        // ------------------------------------------------------
        // MANIFESTO LIST
        // ------------------------------------------------------
        final years = _availableYears(state.manifestos);

        final filteredManifestos =
        _filteredManifestos(state.manifestos);
        return Container(
          width: w,
          color: ColorScheme.of(context).surface,
          child: Column(
            children: [
              SizedBox(height: h*0.02),
              SizedBox(
                height: h * 0.055,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                  ),
                  children: [
                    _yearFilterChip(
                      context: context,
                      title: "All",
                      year: null,
                    ),
                    ...years.map(
                          (year) => _yearFilterChip(
                        context: context,
                        title: year.toString(),
                        year: year,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.015),
              if (filteredManifestos.isEmpty)

                Padding(
                  padding: EdgeInsets.all(h * 0.04),
                  child: const Center(
                    child: Text(
                      "No manifesto found",
                    ),
                  ),
                )
              else
              ListView.separated(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: filteredManifestos.length +
                    (state.isLoadingMore && _selectedYear == null ? 1 : 0),
                  itemBuilder: (context,index){
                        if (index == filteredManifestos.length &&  state.isLoadingMore &&
                            _selectedYear == null) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final ManifestoModel manifesto =
                        filteredManifestos[index];

                        return _manifestoCard(
                          context,
                          manifesto,
                          widget.isAdmin,
                          h,
                          w,
                        );
                  },
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

  // ==========================================================
  // MANIFESTO CARD
  // ==========================================================

  Widget _manifestoCard(
      BuildContext context,
      ManifestoModel manifesto,
      bool isAdmin,
      double h, double w,
      ) {
    return InkWell(
      onTap: () {
        final fileUrl = manifesto.fileUrl;

        if (fileUrl == null || fileUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Manifesto PDF is not available"),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManifestoPdfViewer(
              fileUrl: fileUrl,
              title: manifesto.title,
            ),
          ),
        );
      },
      // onTap: () {
      //   showDialog(
      //     context: context,
      //     builder: (dialogContext) {
      //       debugPrint(manifesto.fileUrl);
      //       return AlertDialog(
      //         contentPadding: EdgeInsets.zero,
      //         content: buildImageWidget(manifesto.fileUrl ?? ""),
      //       );
      //     },
      //   );
      // },

      child: Card(
        color: ColorScheme.of(context).surface,
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(w*0.03),
            side: BorderSide(color: Colors.black.withOpacity(0.1))
        ),
        margin:  EdgeInsets.only(
          bottom: h*0.01,
          right: w*0.02, left: w*0.02,
        ),
        child: Padding(
          padding:  EdgeInsets.only(right: w*0.04, left: w*0.02, top: w*0.02, bottom: w*0.02),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Image.asset(PartyPageData.pdfIcon, height: w*0.085,),
              SizedBox(width: w*0.03,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${PartyPageData.manifestoCard} ${manifesto.year}",style: TextStyle(
                    fontSize: h*0.025,
                    fontWeight: FontWeight.w600,
                  ),),
                  Text("View",style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: h*0.019,
                    color: Color(0xFF666666)
                  ),)
                ],
              ),
              if(isAdmin==true)...[
              Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ManifestoBloc>(),
                          child: AddManifest(
                            partyId: widget.partyId,
                            manifesto: manifesto,
                          ),
                        ),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    PartyPageData.addIconMenifesto,
                    width: w * 0.06,
                  ),
                ),  SizedBox(width: w*0.06,),
                GestureDetector(
                  onTap: () {
                    _showDeleteConfirmation(
                      context,
                      manifesto,
                    );
                  },
                  child: SvgPicture.asset(
                    PartyPageData.deleteIcon,
                    color: const Color(0xFFFE3A31),
                    width: w * 0.045,
                  ),
                ), ],

                ],
          ),
        ),
      ),
    );
  }
}


Future<void> _showDeleteConfirmation(
    BuildContext context,
    ManifestoModel manifesto,
    ) async {
  final bool? shouldDelete =
  await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(
          "Delete Manifesto",
        ),
        content: Text(
          "Are you sure you want to delete "
              "\"${manifesto.title}\"?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                false,
              );
            },
            child: const Text(
              "Cancel",
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                true,
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Color(0xFFFE3A31),
              ),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) {
    return;
  }

  context.read<ManifestoBloc>().add(
    DeleteManifestoEvent(
      manifestoId: manifesto.id!,
    ),
  );

}
