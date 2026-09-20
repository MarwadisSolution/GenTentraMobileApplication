import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'manifesto_apis.dart';
import 'manifesto_event.dart';
import 'manifesto_model.dart';
import 'manifesto_state.dart';

class ManifestoBloc extends Bloc<ManifestoEvent, ManifestoState> {
  final ManifestoApis api;

  ManifestoBloc(this.api)
      : super(const ManifestoState()) {
    on<GetManifestosEvent>(
      _getManifestos,
    );

    on<LoadMoreManifestosEvent>(
      _loadMoreManifestos,
    );

    on<SearchManifestosEvent>(
      _searchManifestos,
    );

    on<PostManifestoEvent>(
      _postManifesto,
    );

    on<UpdateManifestoEvent>(
      _updateManifesto,
    );

    on<ResetManifestoMessageEvent>(
      _resetMessage,
    );
    on<DeleteManifestoEvent>(
      _deleteManifesto,
    );
  }

  // ==========================================================
  // GET MANIFESTOS
  // ==========================================================

  Future<void> _getManifestos(
      GetManifestosEvent event,
      Emitter<ManifestoState> emit,
      ) async {
    emit(
      state.copyWith(
        status: ManifestoStatus.loading,
        manifestos: [],
        currentPage: 0,
        hasNext: true,
        partyId: event.partyId,
        politicianId: event.politicianId,
        year: event.year,
        kind: event.kind,
        search: event.search ?? '',
      ),
    );

    try {
      final ManifestoPaginationResponse response =
      await api.getManifestosPaginated(
        partyId: event.partyId,
        politicianId: event.politicianId,
        year: event.year,
        kind: event.kind,
        search: event.search,
        page: 0,
        size: state.pageSize,
      );

      emit(
        state.copyWith(
          status: ManifestoStatus.success,
          manifestos: response.items,
          currentPage: response.page,
          hasNext: response.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      debugPrint(
        "GET MANIFESTOS BLOC ERROR: $e",
      );

      emit(
        state.copyWith(
          status: ManifestoStatus.error,
          message: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  // ==========================================================
  // LOAD MORE
  // ==========================================================

  Future<void> _loadMoreManifestos(
      LoadMoreManifestosEvent event,
      Emitter<ManifestoState> emit,
      ) async {
    // Don't make another request if already loading.
    if (state.isLoadingMore) {
      return;
    }

    // No more pages.
    if (!state.hasNext) {
      return;
    }

    emit(
      state.copyWith(
        isLoadingMore: true,
      ),
    );

    try {
      final int nextPage =
          state.currentPage + 1;

      final ManifestoPaginationResponse response =
      await api.getManifestosPaginated(
        partyId: state.partyId,
        politicianId: state.politicianId,
        year: state.year,
        kind: state.kind,
        search: state.search,
        page: nextPage,
        size: state.pageSize,
      );

      final List<ManifestoModel> updatedList = [
        ...state.manifestos,
        ...response.items,
      ];

      emit(
        state.copyWith(
          manifestos: updatedList,
          currentPage: response.page,
          hasNext: response.hasNext,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      debugPrint(
        "LOAD MORE MANIFESTOS ERROR: $e",
      );

      emit(
        state.copyWith(
          isLoadingMore: false,
          message: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Future<void> _searchManifestos(
      SearchManifestosEvent event,
      Emitter<ManifestoState> emit,
      ) async {
    emit(
      state.copyWith(
        status: ManifestoStatus.loading,
        manifestos: [],
        currentPage: 0,
        hasNext: true,
        search: event.search,
      ),
    );

    try {
      final ManifestoPaginationResponse response =
      await api.getManifestosPaginated(
        partyId: state.partyId,
        politicianId: state.politicianId,
        year: state.year,
        kind: state.kind,
        search: event.search,
        page: 0,
        size: state.pageSize,
      );

      emit(
        state.copyWith(
          status: ManifestoStatus.success,
          manifestos: response.items,
          currentPage: response.page,
          hasNext: response.hasNext,
        ),
      );
    } catch (e) {
      debugPrint(
        "SEARCH MANIFESTOS ERROR: $e",
      );

      emit(
        state.copyWith(
          status: ManifestoStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // POST MANIFESTO
  // ==========================================================

  Future<void> _postManifesto(
      PostManifestoEvent event,
      Emitter<ManifestoState> emit,
      ) async {
    emit(
      state.copyWith(
        postStatus:
        ManifestoActionStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      debugPrint(
        "POST MANIFESTO STARTED",
      );

      final ManifestoModel createdManifesto =
      await api.postManifesto(
        manifesto: event.manifesto,
        filePath: event.filePath,
      );

      // Add newly created manifesto to the beginning
      // of the existing list.
      final List<ManifestoModel> updatedList = [
        createdManifesto,
        ...state.manifestos,
      ];

      emit(
        state.copyWith(
          postStatus:
          ManifestoActionStatus.success,
          manifestos: updatedList,
          message:
          "Manifesto uploaded successfully",
        ),
      );
    } catch (e) {
      debugPrint(
        "POST MANIFESTO BLOC ERROR: $e",
      );

      emit(
        state.copyWith(
          postStatus:
          ManifestoActionStatus.error,
          message:
          "Failed to upload manifesto",
        ),
      );
    }
  }

  // ==========================================================
  // UPDATE MANIFESTO
  // ==========================================================

  Future<void> _updateManifesto(
      UpdateManifestoEvent event,
      Emitter<ManifestoState> emit,
      ) async {

    emit(
      state.copyWith(
        updateStatus:
        ManifestoActionStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      debugPrint(
        "UPDATE MANIFESTO STARTED",
      );

      final ManifestoModel updatedManifesto =
      await api.updateManifesto(
        manifesto: event.manifesto,
        filePath: event.filePath,
      );

      // ======================================================
      // REPLACE OLD MANIFESTO
      // ======================================================

      final List<ManifestoModel> updatedList =
      state.manifestos.map((manifesto) {

        if (manifesto.id ==
            updatedManifesto.id) {
          return updatedManifesto;
        }

        return manifesto;
      }).toList();

      emit(
        state.copyWith(
          updateStatus:
          ManifestoActionStatus.success,
          manifestos: updatedList,
          message:
          "Manifesto updated successfully",
        ),
      );

    } catch (e) {

      debugPrint(
        "UPDATE MANIFESTO BLOC ERROR: $e",
      );

      emit(
        state.copyWith(
          updateStatus:
          ManifestoActionStatus.error,
          message:
          "Failed to update manifesto",
        ),
      );
    }
  }

  // ==========================================================
  // RESET MESSAGE
  // ==========================================================

  void _resetMessage(
      ResetManifestoMessageEvent event,
      Emitter<ManifestoState> emit,
      ) {
    emit(
      state.copyWith(
        clearMessage: true,
      ),
    );
  }
  // ==========================================================
// DELETE MANIFESTO
// ==========================================================

  Future<void> _deleteManifesto(
      DeleteManifestoEvent event,
      Emitter<ManifestoState> emit,
      ) async {
    emit(
      state.copyWith(
        deleteStatus: ManifestoActionStatus.loading,
        clearMessage: true,
      ),
    );

    try {
      debugPrint(
        "DELETE MANIFESTO STARTED: ${event.manifestoId}",
      );

      await api.deleteManifesto(
        manifestoId: event.manifestoId,
      );

      // Remove deleted manifesto from the current list.
      final List<ManifestoModel> updatedList =
      state.manifestos
          .where(
            (manifesto) =>
        manifesto.id != event.manifestoId,
      )
          .toList();

      emit(
        state.copyWith(
          deleteStatus:
          ManifestoActionStatus.success,
          manifestos: updatedList,
          message:
          "Manifesto deleted successfully",
        ),
      );
    } catch (e) {
      debugPrint(
        "DELETE MANIFESTO BLOC ERROR: $e",
      );

      emit(
        state.copyWith(
          deleteStatus:
          ManifestoActionStatus.error,
          message:
          "Failed to delete manifesto",
        ),
      );
    }
  }
}