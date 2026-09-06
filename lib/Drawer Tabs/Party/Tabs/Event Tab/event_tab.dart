import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class EventTab extends StatefulWidget {
  final int partyId;
  final ScrollController scrollController;
  const EventTab({super.key,required this.partyId,required this.scrollController,});

  @override
  State<EventTab> createState() => _EventTabState();
}

class _EventTabState extends State<EventTab> {
  int? selectedIndex;
  bool? isAdmin;
  Future<void> isAdminChecking() async {
    final prefs = await SharedPreferences.getInstance();
    final String? adminPartyId = prefs.getString("AdminOfParty");
    final String currentPartyId = widget.partyId.toString();
    final bool admin = adminPartyId == currentPartyId;

    if (!mounted) return;

    setState(() {
      isAdmin = admin;
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
