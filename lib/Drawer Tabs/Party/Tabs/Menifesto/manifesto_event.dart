import 'package:equatable/equatable.dart';

import 'manifesto_model.dart';

abstract class ManifestoEvent extends Equatable {
  const ManifestoEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// GET INITIAL MANIFESTOS
// ============================================================

class GetManifestosEvent extends ManifestoEvent {
  final int? partyId;
  final int? politicianId;
  final int? year;
  final String? kind;
  final String? search;

  const GetManifestosEvent({
    this.partyId,
    this.politicianId,
    this.year,
    this.kind,
    this.search,
  });

  @override
  List<Object?> get props => [
    partyId,
    politicianId,
    year,
    kind,
    search,
  ];
}

// ============================================================
// LOAD MORE MANIFESTOS
// ============================================================

class LoadMoreManifestosEvent extends ManifestoEvent {
  const LoadMoreManifestosEvent();
}

// ============================================================
// SEARCH MANIFESTOS
// ============================================================

class SearchManifestosEvent extends ManifestoEvent {
  final String search;

  const SearchManifestosEvent({
    required this.search,
  });

  @override
  List<Object?> get props => [
    search,
  ];
}

// ============================================================
// POST MANIFESTO
// ============================================================

class PostManifestoEvent extends ManifestoEvent {
  final ManifestoModel manifesto;
  final String? filePath;

  const PostManifestoEvent({
    required this.manifesto,
    this.filePath,
  });

  @override
  List<Object?> get props => [
    manifesto,
    filePath,
  ];
}

// ============================================================
// UPDATE MANIFESTO
// ============================================================

class UpdateManifestoEvent extends ManifestoEvent {
  final ManifestoModel manifesto;
  final String? filePath;

  const UpdateManifestoEvent({
    required this.manifesto,
    this.filePath,
  });

  @override
  List<Object?> get props => [
    manifesto,
    filePath,
  ];
}

// ============================================================
// RESET MESSAGE
// ============================================================

class ResetManifestoMessageEvent extends ManifestoEvent {
  const ResetManifestoMessageEvent();
}