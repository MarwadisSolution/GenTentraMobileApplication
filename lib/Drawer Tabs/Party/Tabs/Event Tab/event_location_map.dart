import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class EventLocationMap extends StatefulWidget {
  final String? addressText;
  final String? addressLink;

  const EventLocationMap({
    super.key,
    required this.addressText,
    required this.addressLink,
  });

  @override
  State<EventLocationMap> createState() => _EventLocationMapState();
}

class _EventLocationMapState extends State<EventLocationMap> {
  LatLng? location;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    if (widget.addressText == null ||
        widget.addressText!.trim().isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final geocoding = Geocoding();

      final locations = await geocoding.locationFromAddress(
        widget.addressText!,
      );

      if (locations.isNotEmpty) {
        final result = locations.first;

        if (!mounted) return;

        setState(() {
          location = LatLng(
            result.latitude,
            result.longitude,
          );
          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openGoogleMaps() async {
    if (widget.addressLink == null ||
        widget.addressLink!.isEmpty) {
      return;
    }

    final Uri uri = Uri.parse(widget.addressLink!);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.addressText == null ||
        widget.addressText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _openGoogleMaps,
      child: Container(
        width: double.infinity,
        height: 240,
        margin: const EdgeInsets.only(top: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [

            // =========================
            // MAP
            // =========================
            Positioned.fill(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : location == null
                  ? Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.location_off,
                    size: 45,
                  ),
                ),
              )
                  : FlutterMap(
                options: MapOptions(
                  initialCenter: location!,
                  initialZoom: 15,
                  interactionOptions:
                  const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                    'com.yourcompany.gententra',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: location!,
                        width: 45,
                        height: 45,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =========================
            // BOTTOM GRADIENT
            // =========================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // =========================
            // ADDRESS
            // =========================
            Positioned(
              left: 18,
              right: 60,
              bottom: 15,
              child: Text(
                widget.addressText!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // =========================
            // GOOGLE MAPS ICON
            // =========================
            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}