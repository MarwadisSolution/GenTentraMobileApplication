import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ManifestoModel {
  final int? id;
  final String? uuid;
  final String title;
  final String? description;
  final int? year;
  final String? fileUrl;
  final String? fileName;
  final String? kind;
  final int? authorUserId;
  final int? authorPartyId;
  final String? authorType;
  final ManifestoAuthor? author;
  final ManifestoMeta? meta;

  const ManifestoModel({
    this.id,
    this.uuid,
    required this.title,
    this.description,
    this.year,
    this.fileUrl,
    this.fileName,
    this.kind,
    this.authorUserId,
    this.authorPartyId,
    this.authorType,
    this.author,
    this.meta,
  });

  factory ManifestoModel.fromJson(Map<String, dynamic> json) {
    return ManifestoModel(
      id: json['id'],
      uuid: json['uuid'],
      title: json['title'] ?? '',
      description: json['description'],
      year: json['year'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      kind: json['kind'],
      authorUserId: json['authorUserId'],
      authorPartyId: json['authorPartyId'],
      authorType: json['authorType'],
      author: json['author'] != null
          ? ManifestoAuthor.fromJson(json['author'])
          : null,
      meta: json['meta'] != null
          ? ManifestoMeta.fromJson(json['meta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'description': description,
      'year': year,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'kind': kind,
      'authorUserId': authorUserId,
      'authorPartyId': authorPartyId,
      'authorType': authorType,
      'author': author?.toJson(),
      'meta': meta?.toJson(),
    };
  }

  ManifestoModel copyWith({
    int? id,
    String? uuid,
    String? title,
    String? description,
    int? year,
    String? fileUrl,
    String? fileName,
    String? kind,
    int? authorUserId,
    int? authorPartyId,
    String? authorType,
    ManifestoAuthor? author,
    ManifestoMeta? meta,
  }) {
    return ManifestoModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      year: year ?? this.year,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      kind: kind ?? this.kind,
      authorUserId: authorUserId ?? this.authorUserId,
      authorPartyId: authorPartyId ?? this.authorPartyId,
      authorType: authorType ?? this.authorType,
      author: author ?? this.author,
      meta: meta ?? this.meta,
    );
  }
}

class ManifestoAuthor {
  final String? kind;
  final int? id;
  final String? name;
  final String? imageUrl;
  final String? partyInitial;

  const ManifestoAuthor({
    this.kind,
    this.id,
    this.name,
    this.imageUrl,
    this.partyInitial,
  });

  factory ManifestoAuthor.fromJson(Map<String, dynamic> json) {
    return ManifestoAuthor(
      kind: json['kind'],
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      partyInitial: json['partyInitial'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'partyInitial': partyInitial,
    };
  }
}

class ManifestoMeta {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  const ManifestoMeta({
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory ManifestoMeta.fromJson(Map<String, dynamic> json) {
    return ManifestoMeta(
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'version': version,
    };
  }
}

class ManifestoPaginationResponse {
  final List<ManifestoModel> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool hasNext;

  const ManifestoPaginationResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
  });

  factory ManifestoPaginationResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return ManifestoPaginationResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ManifestoModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
      page: json['page'] ?? 0,
      size: json['size'] ?? 20,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'page': page,
      'size': size,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'hasNext': hasNext,
    };
  }
}



class ManifestoPdfViewer extends StatefulWidget {
  final String fileUrl;
  final String title;

  const ManifestoPdfViewer({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  State<ManifestoPdfViewer> createState() => _ManifestoPdfViewerState();
}

class _ManifestoPdfViewerState extends State<ManifestoPdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey =
  GlobalKey<SfPdfViewerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(
        widget.fileUrl,
        key: _pdfViewerKey,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                details.description.isNotEmpty
                    ? details.description
                    : 'Failed to load PDF',
              ),
            ),
          );
        },
      ),
    );
  }
}
