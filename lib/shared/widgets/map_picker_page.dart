import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/location_service.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialCenter;
  final LatLngBounds? bounds;
  final List<LatLng>? polygon;

  const MapPickerPage({
    super.key,
    required this.initialCenter,
    this.bounds,
    this.polygon,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialCenter;
  }


  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.mapLocation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, selectedLocation),
            child: Text(t.save, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.initialCenter,
          initialZoom: 16,
          minZoom: 14,
          maxZoom: 19,
          onTap: (tapPosition, point) {
            // Validación visual y lógica del marcador (Paso 2.2 Roadmap)
            if (widget.polygon != null && widget.polygon!.isNotEmpty) {
              final isInside = LocationService.isPointInPolygon(point, widget.polygon!);
              if (!isInside) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.errorLocationOutsideCenter),
                    backgroundColor: theme.colorScheme.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }
            }
            setState(() {
              selectedLocation = point;
            });
          },
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          cameraConstraint: const CameraConstraint.unconstrained(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.lostfound',
          ),
          if (widget.polygon != null && widget.polygon!.isNotEmpty)
            PolygonLayer(
              polygons: [
                Polygon(
                  points: widget.polygon!,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderColor: theme.colorScheme.primary,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: selectedLocation,
                width: 40,
                height: 40,
                alignment: Alignment.topCenter,
                child: Icon(
                  Icons.location_on_rounded,
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(widget.initialCenter, 16);
          setState(() {
            selectedLocation = widget.initialCenter;
          });
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
