/// [STATE ITEM MODEL]
/// Data model for state list items matching `GET /api/v1/civic/countries/{countryId}/states`.
class StateItemModel {
  final int id;
  final String name;
  final String electoralFootprint;

  const StateItemModel({
    required this.id,
    required this.name,
    required this.electoralFootprint,
  });

  factory StateItemModel.fromJson(Map<String, dynamic> json) {
    return StateItemModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: (json['name'] ?? json['stateName'] ?? '').toString().trim(),
      electoralFootprint:
          (json['electoralFootprint'] ?? json['electoral_footprint'] ?? '')
              .toString()
              .trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'electoralFootprint': electoralFootprint,
      };

  /// Extracted Assembly Seats text, e.g. "182 Assembly Seats"
  String get assemblySeatsText {
    if (electoralFootprint.isEmpty) return '';
    final match = RegExp(
      r'(\d+\s+Assembly(?:\s+Seats)?)',
      caseSensitive: false,
    ).firstMatch(electoralFootprint);
    if (match != null) {
      String text = match.group(1)!.trim();
      if (!text.toLowerCase().contains('seats')) {
        text = '$text Seats';
      }
      return text;
    }
    return '';
  }

  /// Extracted Lok Sabha Seats text, e.g. "26 Lok Sabha Seats" or "02 Lok Sabha Seats"
  String get lokSabhaSeatsText {
    if (electoralFootprint.isEmpty) return '';
    final match = RegExp(
      r'(\d+\s+(?:Lok\s*Sabha|Loksabha)(?:\s+Seats)?)',
      caseSensitive: false,
    ).firstMatch(electoralFootprint);
    if (match != null) {
      final raw = match.group(1)!.trim();
      final count = RegExp(r'\d+').firstMatch(raw)?.group(0) ?? '';
      return '$count Lok Sabha Seats';
    }
    return '';
  }

  /// Returns true if both assembly and lok sabha seats were parsed separately.
  bool get hasBothSeats =>
      assemblySeatsText.isNotEmpty && lokSabhaSeatsText.isNotEmpty;

  /// Full formatted electoral footprint fallback
  String get formattedElectoralFootprint {
    if (electoralFootprint.isEmpty) return '';
    String text = electoralFootprint;
    if (text.contains('Assembly Seats') || text.contains('Lok Sabha Seats')) {
      return text;
    }
    text = text.replaceAll(
      RegExp(r'\s+Loksabha|\s+Lok Sabha', caseSensitive: false),
      ' Lok Sabha Seats',
    );
    text = text.replaceAll(
      RegExp(r'\s+Assembly', caseSensitive: false),
      ' Assembly Seats',
    );
    return text;
  }
}
