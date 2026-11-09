import 'package:flutter_bloc/flutter_bloc.dart';

import 'development_apis.dart';
import 'development_events.dart';
import 'development_model.dart';
import 'development_states.dart';

class DevelopmentBloc
    extends Bloc<DevelopmentEvent, DevelopmentState> {

  final DevelopmentApis developmentApis;

  DevelopmentBloc(this.developmentApis)
      : super(DevelopmentState()) {

    // GET DEVELOPMENT
    on<LoadDevelopmentEvent>(_loadDevelopment);

    // YEAR WISE DEVELOPMENT
    on<YearWiseDevelopmentEvent>(_yearWiseDevelopment);

    // ADD DEVELOPMENT
    on<AddNewDevelopmentEvent>(_addDevelopment);

    // EDIT DEVELOPMENT
    on<EditDevelopmentEvent>(_editDevelopment);

    // DELETE DEVELOPMENT
    on<DeleteDevelopmentEvent>(_deleteDevelopment);

    // UPDATE DEVELOPMENT
    on<UpdateDevelopmentEvent>(_updateDevelopment);

    // REPORT DEVELOPMENT VIEW
    on<ReportDevelopmentViewEvent>(_reportDevelopmentView);
  }

  // ==================================================
  // GET DEVELOPMENT
  // ==================================================

  Future<void> _loadDevelopment(
      LoadDevelopmentEvent event,
      Emitter<DevelopmentState> emit,
      ) async {

    final bool isPagination = event.page > 0;

    if (isPagination && state.isLoadingMore) return;

    if (isPagination && !state.hasMore) return;

    if (isPagination) {
      emit(state.copyWith(
        isLoadingMore: true,
        clearError: true,
        clearSuccess: true,
      ));
    } else {
      emit(state.copyWith(
        isLoading: true,
        page: 0,
        hasMore: true,
        clearError: true,
        clearSuccess: true,
      ));
    }

    try {

      final result = await developmentApis.getTheDevelopment(
        id: event.id,
        fromWhichPage: event.fromWhichPage,
        page: event.page,
        size: event.size,
      );

      List<DevelopmentModel> updatedList;

      if (isPagination) {
        updatedList = [
          ...state.developments,
          ...result,
        ];
      } else {
        updatedList = result;
      }

      // Remove duplicate development IDs
      final uniqueDevelopments = <int, DevelopmentModel>{};

      for (final development in updatedList) {
        uniqueDevelopments[development.id] = development;
      }

      final finalList = uniqueDevelopments.values.toList();

      emit(state.copyWith(
        developments: finalList,
        filteredDevelopments: _filterByYear(
          finalList,
          state.selectedYear,
        ),
        page: event.page,
        size: event.size,
        hasMore: result.length >= event.size,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      ));

    } catch (e) {

      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  // ==================================================
  // YEAR WISE DEVELOPMENT
  // ==================================================

  Future<void> _yearWiseDevelopment(
      YearWiseDevelopmentEvent event,
      Emitter<DevelopmentState> emit,
      ) async {

    try {

      final filteredList = _filterByYear(
        state.developments,
        event.year,
      );

      emit(state.copyWith(
        selectedYear: event.year,
        filteredDevelopments: filteredList,
        clearError: true,
      ));

    } catch (e) {

      emit(state.copyWith(
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  // ==================================================
  // YEAR FILTER HELPER
  // ==================================================

  List<DevelopmentModel> _filterByYear(
      List<DevelopmentModel> developments,
      String? year,
      ) {
    if (year == null) {
      return developments;
    }

    return developments.where((development) {
      final developmentYear =
          "${development.from ?? ''}-${development.to ?? development.from ?? ''}";

      return developmentYear == year;
    }).toList();
  }

  // ==================================================
  // ADD DEVELOPMENT
  // ==================================================


  Future<void> _addDevelopment(
      AddNewDevelopmentEvent event,
      Emitter<DevelopmentState> emit,
      ) async {
    emit(state.copyWith(
      isAdding: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      // Call POST Development API
      final DevelopmentModel createdDevelopment =
      await developmentApis.postTheDevelopment(
        development: event.development,
        mediaFiles: event.mediaFiles,
      );

      // Add newly created development to the existing list
      final List<DevelopmentModel> updatedList = [
        createdDevelopment,
        ...state.developments.where(
              (development) => development.id != createdDevelopment.id,
        ),
      ];

      emit(state.copyWith(
        developments: updatedList,

        // Apply currently selected year filter
        filteredDevelopments: _filterByYear(
          updatedList,
          state.selectedYear,
        ),

        isAdding: false,
        isSuccess: true,
        successMessage: 'Development added successfully.',
        clearError: true,
      ));

    } catch (e) {
      emit(state.copyWith(
        isAdding: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }


  // ==================================================
  // EDIT DEVELOPMENT
  // ==================================================

  Future<void> _editDevelopment(
      EditDevelopmentEvent event,
      Emitter<DevelopmentState> emit,
      ) async {

    emit(state.copyWith(
      isEditing: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {

      // TODO:
      // Connect your PATCH API here.
      //
      // Pass:
      // event.id
      // event.partyId
      // event.fromWhichPage
      // event.politicianId
      // event.development
      // event.mediaFiles
      // event.deletedMediaIds

      emit(state.copyWith(
        isEditing: false,
        isSuccess: true,
        successMessage: 'Edit Development API not connected yet.',
      ));

    } catch (e) {

      emit(state.copyWith(
        isEditing: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  // ==================================================
  // DELETE DEVELOPMENT
  // ==================================================

  Future<void> _deleteDevelopment(
      DeleteDevelopmentEvent event,
      Emitter<DevelopmentState> emit,
      ) async {

    emit(state.copyWith(
      isDeleting: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {

      // TODO:
      // Connect your DELETE API here.
      //
      // Pass:
      // event.id
      // event.partyId
      // event.fromWhichPage
      // event.politicianId

      emit(state.copyWith(
        isDeleting: false,
        isSuccess: true,
        successMessage: 'Delete Development API not connected yet.',
      ));

    } catch (e) {

      emit(state.copyWith(
        isDeleting: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  // ==================================================
  // UPDATE DEVELOPMENT
  // ==================================================

  Future<void> _updateDevelopment(
      UpdateDevelopmentEvent event,
      Emitter<DevelopmentState> emit,
      ) async {

    emit(state.copyWith(
      isUpdating: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {

      // TODO:
      // Connect your PATCH API here.
      //
      // Pass:
      // event.development
      // event.mediaFiles
      // event.deletedMediaIds
      // event.partyId

      emit(state.copyWith(
        isUpdating: false,
        isSuccess: true,
        successMessage: 'Update Development API not connected yet.',
      ));

    } catch (e) {

      emit(state.copyWith(
        isUpdating: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  // ==================================================
  // REPORT DEVELOPMENT VIEW
  // ==================================================

  Future<void> _reportDevelopmentView(
      ReportDevelopmentViewEvent event,
      Emitter<DevelopmentState> emit,
      ) async {
final postId=event.postId;

// Already successfully viewed in this FeedBloc session.
if(state.viewedPostIds.contains(postId))return;

    // Request for this post is already in progress.
    if(state.reportingViewIds.contains(postId))return;
    try {

      // TODO:
      // Connect your Report Development View API here.
      //
      // Pass:
      // event.postId

      emit(state.copyWith(
        isReporting: false,
      ));

    } catch (e) {

      emit(state.copyWith(
        isReporting: false,
        isError: true,
        errorMessage: e.toString(),
      ));
    }
  }
}