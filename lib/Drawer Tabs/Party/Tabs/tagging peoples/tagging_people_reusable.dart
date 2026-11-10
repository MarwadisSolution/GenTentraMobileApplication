import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_bloc.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_event.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_model.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/tagging%20peoples/tagging_people_state.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';

import '../../../../Reusable Functions/reusable_functions.dart';

class TaggingPeopleReusable extends StatefulWidget {
  final SearchPeopleFunction searchPeople;
  final List<SelectedTaggingPersonModel> initialSelectedPeople;

  const TaggingPeopleReusable({
    super.key,
    required this.searchPeople,
    this.initialSelectedPeople = const [],
  });

  @override
  State<TaggingPeopleReusable> createState() => _TaggingPeopleReusableState();
}

class _TaggingPeopleReusableState extends State<TaggingPeopleReusable> {
  late final TaggingPeopleBloc _taggingPeopleBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _taggingPeopleBloc = TaggingPeopleBloc(
      searchPeople: widget.searchPeople,
      initialSelectedPeople: widget.initialSelectedPeople,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    _taggingPeopleBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocProvider.value(
      value: _taggingPeopleBloc,
      child: Scaffold(
        body: BlocConsumer<TaggingPeopleBloc, TaggingPeopleState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: ColorScheme.of(context).error,
                  content: Text(
                    state.errorMessage!,
                    style: TextStyle(color: ColorScheme.of(context).surface),
                  ),
                ),
              );
              context.read<TaggingPeopleBloc>().add(ClearTaggingErrorEvent());
            }
            if (state.saveCompleted) {
              Navigator.pop(context, state.selectedPeople);
            }
          },

          builder: (context, state) {
            print("Initial Selected People:");
            print(widget.initialSelectedPeople.isNotEmpty?widget.initialSelectedPeople.first.name:"");

            print("Currently Selected People:");
            print(state.selectedPeople.isNotEmpty?state.selectedPeople.first.name:"");
            return CustomScrollView(
              slivers: [
                ReusableSliverAppBar(
                  title: PartyPageData.tagPeople,
                  automaticallyImplyLeading: false,
                  isMenuNeeded: false,
                  height: h * 0.07,
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

                ///---------------SearchBar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: h * 0.12,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: h * 0.067,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: GradientColorsForBellowAppbar
                                .gradientBelowAppbar,
                          ),
                        ),
                        Positioned(
                          top: h * 0.025,
                          left: w * 0.025,
                          right: w * 0.025,
                          child: Container(
                            height: h * 0.068,
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.035,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(w * 0.04),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  PartyPageData.searchPersonIcon,
                                  width: w * 0.055,
                                  height: w * 0.055,
                                ),
                                SizedBox(width: w * 0.025),

                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    textInputAction: TextInputAction.search,
                                    onChanged: (value) {
                                      _taggingPeopleBloc.add(
                                        SearchPeopleEvent(value.trim()),
                                      );
                                    },
                                    style: TextStyle(
                                      fontSize: w * 0.038,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search leaders',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: w * 0.038,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                SizedBox(width: w * 0.02),
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    _taggingPeopleBloc.add(
                                      SearchPeopleEvent(
                                        _searchController.text.trim(),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: h * 0.012,
                                      horizontal: w * 0.01,
                                    ),
                                    child: Text(
                                      'SEARCH',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: w * 0.033,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final person = state.searchResults[index];

                    final isSelected = state.selectedPeople.any(
                      (selected) =>
                          selected.politicianId == person.politicianId,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            person.imagePath != null &&
                                person.imagePath!.isNotEmpty
                            ? NetworkImage(person.imagePath!)
                            : null,
                        child:
                            person.imagePath == null ||
                                person.imagePath!.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(person.fullName),
                      subtitle: Text(person.designation),
                      trailing: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      onTap: () {
                        context.read<TaggingPeopleBloc>().add(
                          TogglePersonSelectionEvent(person),
                        );
                      },
                    );
                  }, childCount: state.searchResults.length),
                ),
                // No search results
                if (!state.isSearching &&
                    state.searchQuery.isNotEmpty &&
                    state.searchResults.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No people found')),
                    ),
                  ),
                // Save button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state.selectedPeople.isEmpty || state.isSaving
                            ? null
                            : () {
                                context.read<TaggingPeopleBloc>().add(
                                  SaveTaggedPeopleEvent(),
                                );
                              },
                        child: state.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
