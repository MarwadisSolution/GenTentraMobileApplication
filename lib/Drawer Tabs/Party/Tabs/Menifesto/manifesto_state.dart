import 'package:equatable/equatable.dart';

import 'manifesto_model.dart';

enum ManifestoStatus {
  initial,
  loading,
  success,
  error,
}

enum ManifestoActionStatus {
  initial,
  loading,
  success,
  error,
}

class ManifestoState extends Equatable {
  // ==========================================================
  // LIST
  // ==========================================================

  final List<ManifestoModel> manifestos;

  // ==========================================================
  // GET STATUS
  // ==========================================================

  final ManifestoStatus status;

  // ==========================================================
  // PAGINATION
  // ==========================================================

  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final bool isLoadingMore;

  // ==========================================================
  // FILTERS
  // ==========================================================

  final int? partyId;
  final int? politicianId;
  final int? year;
  final String? kind;
  final String search;

  // ==========================================================
  // POST STATUS
  // ==========================================================

  final ManifestoActionStatus postStatus;

  // ==========================================================
  // UPDATE STATUS
  // ==========================================================

  final ManifestoActionStatus updateStatus;

  // ==========================================================
  // MESSAGE
  // ==========================================================

  final String? message;

  const ManifestoState({
    this.manifestos = const [],
    this.status = ManifestoStatus.initial,
    this.currentPage = 0,
    this.pageSize = 20,
    this.hasNext = true,
    this.isLoadingMore = false,
    this.partyId,
    this.politicianId,
    this.year,
    this.kind,
    this.search = '',
    this.postStatus = ManifestoActionStatus.initial,
    this.updateStatus = ManifestoActionStatus.initial,
    this.message,
  });

  ManifestoState copyWith({
    List<ManifestoModel>? manifestos,
    ManifestoStatus? status,
    int? currentPage,
    int? pageSize,
    bool? hasNext,
    bool? isLoadingMore,
    int? partyId,
    int? politicianId,
    int? year,
    String? kind,
    String? search,
    ManifestoActionStatus? postStatus,
    ManifestoActionStatus? updateStatus,
    String? message,

    // Allows explicitly clearing nullable values.
    bool clearMessage = false,
  }) {
    return ManifestoState(
      manifestos: manifestos ?? this.manifestos,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,

      partyId: partyId ?? this.partyId,
      politicianId: politicianId ?? this.politicianId,
      year: year ?? this.year,
      kind: kind ?? this.kind,
      search: search ?? this.search,

      postStatus: postStatus ?? this.postStatus,
      updateStatus: updateStatus ?? this.updateStatus,

      message: clearMessage
          ? null
          : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    manifestos,
    status,
    currentPage,
    pageSize,
    hasNext,
    isLoadingMore,
    partyId,
    politicianId,
    year,
    kind,
    search,
    postStatus,
    updateStatus,
    message,
  ];
}