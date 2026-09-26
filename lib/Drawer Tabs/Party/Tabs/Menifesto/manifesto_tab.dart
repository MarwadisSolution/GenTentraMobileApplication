import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Menifesto/reusable_function_manifesto.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';

import '../../reusable_functions.dart';
import '../Event Tab/reusable_functions.dart';
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
  List<ManifestoModel> _filteredManifestos(List<ManifestoModel> manifestos) {
    if (_selectedYear == null) {
      return manifestos;
    }

    return manifestos.where((manifesto) {
      return manifesto.year == _selectedYear;
    }).toList();
  }

  int? _selectedYear;

  // Widget _yearFilterChip({
  //   required BuildContext context,
  //   required String title,
  //   required int? year,
  // }) {
  //   final bool isSelected = _selectedYear == year;
  //
  //   final w = MediaQuery.of(context).size.width;
  //   final h = MediaQuery.of(context).size.height;
  //
  //   return GestureDetector(
  //     onTap: () {
  //       filterByYear(year);
  //     },
  //     child: Container(
  //       margin: EdgeInsets.only(
  //         right: w * 0.025,
  //       ),
  //       padding: EdgeInsets.symmetric(
  //         horizontal: w * 0.055,
  //       ),
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? const Color(0xFFFF4B3A)
  //             : const Color(0xFFBDBDBD),
  //         borderRadius: BorderRadius.circular(30),
  //       ),
  //       alignment: Alignment.center,
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: h * 0.018,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  void initState() {
    super.initState();

    // Use the controller provided by PartyFetchedData.
    widget.scrollController.addListener(_onScroll);

    // Initial GET
    context.read<ManifestoBloc>().add(
      GetManifestosEvent(partyId: widget.partyId),
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
      context.read<ManifestoBloc>().add(const LoadMoreManifestosEvent());
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);

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
    return BlocConsumer<ManifestoBloc, ManifestoState>(
      // ========================================================
      // LISTENER
      // ========================================================
      listener: (context, state) {
        // ------------------------------------------------------
        // UPLOAD SUCCESS
        // ------------------------------------------------------

        if (state.postStatus == ManifestoActionStatus.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green,
                content: Text("Manifesto uploaded successfully",
                    style: TextStyle(color: ColorScheme
                        .of(context)
                        .surface))),
          );
        }

        // ------------------------------------------------------
        // UPLOAD FAILED
        // ------------------------------------------------------

        if (state.postStatus == ManifestoActionStatus.error) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorScheme
                  .of(context)
                  .error,
              content: Text(state.message ?? "Failed to upload manifesto",
                style: TextStyle(color: ColorScheme
                    .of(context)
                    .surface),),
            ),
          );
        }

        // ------------------------------------------------------
        // UPDATE SUCCESS
        // ------------------------------------------------------

        if (state.updateStatus == ManifestoActionStatus.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(
                backgroundColor: Colors.green,
                content: Text("Manifesto updated successfully",
                    style: TextStyle(color: ColorScheme
                        .of(context)
                        .surface))),
          );
        }

        // ------------------------------------------------------
        // UPDATE FAILED
        // ------------------------------------------------------

        if (state.updateStatus == ManifestoActionStatus.error) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorScheme
                  .of(context)
                  .error,
              content: Text("Failed to update manifesto",
                  style: TextStyle(color: ColorScheme
                      .of(context)
                      .surface)),
            ),
          );
        }

        // ------------------------------------------------------
        // GET FAILED
        // ------------------------------------------------------

        if (state.status == ManifestoStatus.error) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorScheme
                  .of(context)
                  .error,
              content: Text("Failed to load manifestos",
                  style: TextStyle(color: ColorScheme
                      .of(context)
                      .surface)),
            ),
          );
        }
        // ------------------------------------------------------
// DELETE SUCCESS
// ------------------------------------------------------

        if (state.deleteStatus == ManifestoActionStatus.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Manifesto deleted successfully",
                style: TextStyle(
                  color: ColorScheme
                      .of(context)
                      .surface,
                ),
              ),
            ),
          );

          context.read<ManifestoBloc>().add(
            const ResetManifestoMessageEvent(),
          );
        }

// ------------------------------------------------------
// DELETE FAILED
// ------------------------------------------------------

        if (state.deleteStatus == ManifestoActionStatus.error) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ColorScheme
                  .of(context)
                  .error,
              content: Text(
                state.message ?? "Failed to delete manifesto",
                style: TextStyle(
                  color: ColorScheme
                      .of(context)
                      .surface,
                ),
              ),
            ),
          );

          context.read<ManifestoBloc>().add(
            const ResetManifestoMessageEvent(),
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

        if (state.status == ManifestoStatus.loading &&
            state.manifestos.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(h * 0.1),
              child: CircularProgressIndicator(color: Colors.black,),
            ),
          );
        }

        // ------------------------------------------------------
        // ERROR + NO DATA
        // ------------------------------------------------------

        if (state.status == ManifestoStatus.error && state.manifestos.isEmpty) {
          return Center(
            child: Text(state.message ?? "Failed to load manifesto"),
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

        final filteredManifestos = _filteredManifestos(state.manifestos);
        return Container(
          width: w,
          color: ColorScheme
              .of(context)
              .surface,
          child: Column(
            children: [
              SizedBox(height: h * 0.01),
              SizedBox(
                height: w * 0.1,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  children: [
                    ReusableFilterChip(
                      title: "All",
                      isSelected: _selectedYear == null,
                      onTap: () {
                        filterByYear(null);
                      },
                    ),

                    ...years.map(
                          (year) =>
                          ReusableFilterChip(
                            title: year.toString(),
                            isSelected: _selectedYear == year,
                            onTap: () {
                              filterByYear(year);
                            },
                          ),
                    ),
                  ],
                ),
              ),

              //SizedBox(height: h * 0.0),
              if (filteredManifestos.isEmpty)
                Padding(
                  padding: EdgeInsets.all(h * 0.04),
                  child: const Center(child: Text("No manifesto found")),
                )
              else
                ListView.separated(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  padding: EdgeInsets.only(
                      top: h * 0.013, right: w * 0.013, left: w * 0.013),
                  itemCount:
                  filteredManifestos.length +
                      (state.isLoadingMore && _selectedYear == null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredManifestos.length &&
                        state.isLoadingMore &&
                        _selectedYear == null) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final ManifestoModel manifesto = filteredManifestos[index];

                    return manifestoCard(
                      context,
                      manifesto,
                      widget.isAdmin,
                      h,
                      w,
                      widget.partyId,
                      mounted,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: h * 0.006);
                  },
                ),
              SizedBox(height: h * 0.03),
            ],
          ),
        );
      },
    );
  }
}