import 'package:equatable/equatable.dart';
import 'development_model.dart';

class DevelopmentState extends Equatable {
  // Development List
  final List<DevelopmentModel> developments;
  final List<DevelopmentModel> filteredDevelopments;

  // Loading States
  final bool isLoading;
  final bool isLoadingMore;
  final bool isAdding;
  final bool isEditing;
  final bool isDeleting;
  final bool isUpdating;
  final bool isReporting;
  final DateTime? lastFetchedAt;
  // Pagination
  final int page;
  final int size;
  final bool hasMore;
  final Set<int> viewedPostIds;
  final Set<int> reportingViewIds;
  // Year Filter
  final String? selectedYear;

  // Status
  final bool isError;
  final String errorMessage;
  final bool isSuccess;
  final String successMessage;

  const DevelopmentState({
    this.developments = const [],
    this.filteredDevelopments = const [],

    this.isLoading = false,
    this.isLoadingMore = false,
    this.isAdding = false,
    this.isEditing = false,
    this.isDeleting = false,
    this.isUpdating = false,
    this.isReporting = false,
    this.lastFetchedAt,
    this.page = 0,
    this.size = 20,
    this.hasMore = true,
    this.viewedPostIds = const {},
    this.reportingViewIds = const {},
    this.selectedYear,

    this.isError = false,
    this.errorMessage = '',
    this.isSuccess = false,
    this.successMessage = '',
  });

  DevelopmentState copyWith({
    List<DevelopmentModel>? developments,
    List<DevelopmentModel>? filteredDevelopments,

    bool? isLoading,
    bool? isLoadingMore,
    bool? isAdding,
    bool? isEditing,
    bool? isDeleting,
    bool? isUpdating,
    bool? isReporting,
    DateTime? lastFetchedAt,

    int? page,
    int? size,
    bool? hasMore,
    Set<int>? viewedPostIds,
    Set<int>? reportingViewIds,
    String? selectedYear,
    bool clearSelectedYear = false,

    bool? isError,
    String? errorMessage,
    bool clearError = false,

    bool? isSuccess,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return DevelopmentState(
      developments: developments ?? this.developments,
      filteredDevelopments:
      filteredDevelopments ?? this.filteredDevelopments,

      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isAdding: isAdding ?? this.isAdding,
      isEditing: isEditing ?? this.isEditing,
      isDeleting: isDeleting ?? this.isDeleting,
      isUpdating: isUpdating ?? this.isUpdating,
      isReporting: isReporting ?? this.isReporting,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,

      page: page ?? this.page,
      size: size ?? this.size,
      hasMore: hasMore ?? this.hasMore,
      viewedPostIds: viewedPostIds ?? this.viewedPostIds,
      reportingViewIds: reportingViewIds ?? this.reportingViewIds,
      selectedYear: clearSelectedYear
          ? null
          : selectedYear ?? this.selectedYear,

      isError: clearError ? false : isError ?? this.isError,
      errorMessage:
      clearError ? '' : errorMessage ?? this.errorMessage,

      isSuccess: clearSuccess ? false : isSuccess ?? this.isSuccess,
      successMessage:
      clearSuccess ? '' : successMessage ?? this.successMessage,
    );
  }
  factory DevelopmentState.initial()=> DevelopmentState();
  @override
  List<Object?> get props => [
    developments,
    filteredDevelopments,
    isLoading,
    isLoadingMore,
    isAdding,
    isEditing,
    isDeleting,
    isUpdating,
    isReporting,
    lastFetchedAt,
    page,
    size,
    hasMore,
    viewedPostIds,
    reportingViewIds,
    selectedYear,
    isError,
    errorMessage,
    isSuccess,
    successMessage,
  ];
}