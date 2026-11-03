import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Development/development_model.dart';

abstract class DevelopmentEvent extends Equatable {
  const DevelopmentEvent();

  @override
  List<Object?> get props => [];
}

///--------Load development
class LoadDevelopmentEvent extends DevelopmentEvent {
  final int id;
  final int page;
  final int size;
  final String fromWhichPage;

  const LoadDevelopmentEvent({
    required this.id,
    this.page = 0,
    this.size = 20,
    required this.fromWhichPage,

  });

  @override
  List<Object?> get props => [id, page, size, fromWhichPage,];
}

///--------------Year wise filtering
class YearWiseDevelopmentEvent extends DevelopmentEvent {
  final String year;

  const YearWiseDevelopmentEvent(this.year);

  @override
  List<Object?> get props => [year];
}

///-----------------Add new development
class AddNewDevelopmentEvent extends DevelopmentEvent {
  final int partyId;
  final DevelopmentModel development;
  final List<File> mediaFiles;
  final String fromWhichPage;
  final int politicianId;

  const AddNewDevelopmentEvent({
    required this.partyId,
    required this.development,
    required this.mediaFiles,
    required this.fromWhichPage,
    required this.politicianId,
  });

  @override
  List<Object?> get props => [
    partyId,
    development,
    mediaFiles,
    fromWhichPage,
    politicianId,
  ];
}

///---------------Edit Development
class EditDevelopmentEvent extends DevelopmentEvent {
  final int id;
  final int partyId;
  final DevelopmentModel development;
  final List<File> mediaFiles;
  final List<int> deletedMediaIds;
  final String fromWhichPage;
  final int politicianId;

  const EditDevelopmentEvent({
    required this.id,
    required this.partyId,
    required this.development,
    required this.mediaFiles,
    this.deletedMediaIds = const [],
    required this.fromWhichPage,
    required this.politicianId,
  });

  @override
  List<Object?> get props => [
    id,
    partyId,
    development,
    mediaFiles,
    deletedMediaIds,
    fromWhichPage,
    politicianId,
  ];
}
///-------------------Deleted development
class DeleteDevelopmentEvent extends DevelopmentEvent{
  final int id;
  final int partyId;
  final String fromWhichPage;
  final int politicianId;
  const DeleteDevelopmentEvent(
      this.id, this.partyId,
  {
    required this.fromWhichPage, required this.politicianId,

  }
      );
  @override
  List<Object?> get props => [
    id,
    partyId,
    fromWhichPage,
    politicianId,
  ];
}


///-------------------- UPDATE DEVELOPMENT

class UpdateDevelopmentEvent extends DevelopmentEvent {
  final DevelopmentModel development;
  final List<File> mediaFiles;
  final List<int> deletedMediaIds;
  final int partyId;
  final String fromWhichPage;
  final int politicianId;

  const UpdateDevelopmentEvent({
    required this.development,
    required this.mediaFiles,
    required this.deletedMediaIds,
    required this.partyId,
    required this.fromWhichPage,
    required this.politicianId,
  });

  @override
  List<Object?> get props => [
    development,
    mediaFiles,
    deletedMediaIds,
    partyId,
    fromWhichPage,
    politicianId,
  ];
}
/// ----------------------REPORT DEVELOPMENT VIEW

class ReportDevelopmentViewEvent extends DevelopmentEvent {
  final int postId;

  const ReportDevelopmentViewEvent({
    required this.postId,
  });

  @override
  List<Object?> get props => [postId];
}