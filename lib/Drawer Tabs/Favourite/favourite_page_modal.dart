import 'dart:convert';

class FavouritePageModal {
  final int id;
  final String name;
  final String partySymbolUrl;

  const FavouritePageModal({
    required this.id,
    required this.name,
    required this.partySymbolUrl,
  });

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "partySymbolUrl": partySymbolUrl};
  }

  factory FavouritePageModal.fromJson(Map<String, dynamic> json) {
    return FavouritePageModal(
      id: json["id"],
      name: json["name"] ?? "",
      partySymbolUrl: json["partySymbolUrl"] ?? "",
    );
  }

  static String encode(List<FavouritePageModal> parties) {
    return jsonEncode(parties.map((e) => e.toJson()).toList());
  }

  static List<FavouritePageModal> decode(String value) {
    final List<dynamic> list = jsonDecode(value);
    return list
        .map((e) => FavouritePageModal.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
