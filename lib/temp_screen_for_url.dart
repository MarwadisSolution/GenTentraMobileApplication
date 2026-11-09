// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/party_page_data.dart';
// import 'package:gen_tentra_mobile_application/Reusable%20Functions/sliver_app_bar_reusable.dart';
//
// import '../../../../Reusable Functions/reusable_functions.dart';
//
// // Import your BLoC, events, states and models.
// import 'tagging_people_bloc.dart';
// import 'tagging_people_events.dart';
// import 'tagging_people_states.dart';
// import 'tagging_person_model.dart';
//
// class TaggingPeopleReusable extends StatelessWidget {
//   final SearchPeopleFunction searchPeople;
//
//   const TaggingPeopleReusable({
//     super.key,
//     required this.searchPeople,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => TaggingPeopleBloc(
//         searchPeople: searchPeople,
//       ),
//       child: const TaggingPeopleView(),
//     );
//   }
// }
//
// class TaggingPeopleView extends StatefulWidget {
//   const TaggingPeopleView({super.key});
//
//   @override
//   State<TaggingPeopleView> createState() => _TaggingPeopleViewState();
// }
//
// class _TaggingPeopleViewState extends State<TaggingPeopleView> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       body: BlocConsumer<TaggingPeopleBloc, TaggingPeopleState>(
//         listener: (context, state) {
//           if (state.errorMessage != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.errorMessage!),
//               ),
//             );
//
//             context.read<TaggingPeopleBloc>().add(
//               ClearTaggingErrorEvent(),
//             );
//           }
//
//           if (state.saveCompleted) {
//             Navigator.pop(context, state.selectedPeople);
//           }
//         },
//         builder: (context, state) {
//           return CustomScrollView(
//             slivers: [
//               // App bar
//               ReusableSliverAppBar(
//                 title: PartyPageData.tagPeople,
//                 automaticallyImplyLeading: false,
//                 isMenuNeeded: false,
//                 height: h * 0.07,
//                 actions: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: SizedBox(
//                       width: 48,
//                       height: 48,
//                       child: Center(
//                         child: SvgPicture.asset(
//                           PartyPageData.crossIcon,
//                           height: h * 0.023,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Search bar
//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   height: h * 0.12,
//                   child: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Container(
//                         height: h * 0.067,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           gradient: GradientColorsForBellowAppbar
//                               .gradientBelowAppbar,
//                         ),
//                       ),
//                       Positioned(
//                         top: h * 0.025,
//                         left: w * 0.025,
//                         right: w * 0.025,
//                         child: Container(
//                           height: h * 0.068,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: w * 0.035,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(w * 0.04),
//                           ),
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(
//                                 PartyPageData.searchPersonIcon,
//                                 width: w * 0.055,
//                                 height: w * 0.055,
//                               ),
//                               SizedBox(width: w * 0.025),
//                               Expanded(
//                                 child: TextField(
//                                   controller: _searchController,
//                                   textInputAction: TextInputAction.search,
//                                   decoration: const InputDecoration(
//                                     hintText: 'Search people',
//                                     border: InputBorder.none,
//                                   ),
//                                   onChanged: (value) {
//                                     context.read<TaggingPeopleBloc>().add(
//                                       SearchPeopleEvent(value.trim()),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               if (_searchController.text.isNotEmpty)
//                                 IconButton(
//                                   onPressed: () {
//                                     _searchController.clear();
//                                     context.read<TaggingPeopleBloc>().add(
//                                       ClearSearchEvent(),
//                                     );
//                                     setState(() {});
//                                   },
//                                   icon: const Icon(Icons.close),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // Searching indicator
//               if (state.isSearching)
//                 const SliverToBoxAdapter(
//                   child: LinearProgressIndicator(),
//                 ),
//
//               // Selected people
//               if (state.selectedPeople.isNotEmpty)
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: state.selectedPeople.map((person) {
//                         return Chip(
//                           label: Text(person.name),
//                           deleteIcon: const Icon(Icons.close),
//                           onDeleted: () {
//                             context.read<TaggingPeopleBloc>().add(
//                               ToggleSelectedPersonEvent(
//                                 person.politicianId,
//                               ),
//                             );
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//
//               // Search results
//               SliverList(
//                 delegate: SliverChildBuilderDelegate
//                       (context, index) {
//                     final person = state.searchResults[index];
//
//                     final isSelected = state.selectedPeople.any(
//                           (selected) =>
//                       selected.politicianId == person.politicianId,
//                     );
//
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: person.imagePath != null &&
//                             person.imagePath!.isNotEmpty
//                             ? NetworkImage(person.imagePath!)
//                             : null,
//                         child: person.imagePath == null ||
//                             person.imagePath!.isEmpty
//                             ? const Icon(Icons.person)
//                             : null,
//                       ),
//                       title: Text(person.fullName),
//                       subtitle: Text(person.designation),
//                       trailing: Icon(
//                         isSelected
//                             ? Icons.check_circle
//                             : Icons.add_circle_outline,
//                         color: isSelected ? Colors.green : Colors.grey,
//                       ),
//                       onTap: () {
//                         context.read<TaggingPeopleBloc>().add(
//                           TogglePersonSelectionEvent(person),
//                         );
//                       },
//                     );
//                   },
//                   childCount: state.searchResults.length,
//                 ),
//               ),
//
//               // No search results
//               if (!state.isSearching &&
//                   state.searchQuery.isNotEmpty &&
//                   state.searchResults.isEmpty)
//                 const SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Center(
//                       child: Text('No people found'),
//                     ),
//                   ),
//                 ),
//
//               // Save button
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: state.selectedPeople.isEmpty ||
//                           state.isSaving
//                           ? null
//                           : () {
//                         context.read<TaggingPeopleBloc>().add(
//                           SaveTaggedPeopleEvent(),
//                         );
//                       },
//                       child: state.isSaving
//                           ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                         ),
//                       )
//                           : const Text('Save'),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }