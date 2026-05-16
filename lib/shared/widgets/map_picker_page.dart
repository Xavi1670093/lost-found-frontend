import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/location_service.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialCenter;
  final LatLngBounds? bounds;
  final List<LatLng>? polygon;
  final double radius; // Radio en metros

  const MapPickerPage({
    super.key,
    required this.initialCenter,
    this.bounds,
    this.polygon,
    this.radius = 1500,
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
          initialZoom: 13.5,
          minZoom: 10,
          maxZoom: 19,
          onTap: (tapPosition, point) {
            bool isAllowed = true;
            
            // 1. Prioridad: Validación por Polígono
            if (widget.polygon != null && widget.polygon!.isNotEmpty) {
              isAllowed = LocationService.isPointInPolygon(point, widget.polygon!);
            } else {
              // 2. Fallback: Validación por Radio desde el centro inicial (1500m solicitado)
              isAllowed = LocationService.isWithinRadius(
                point.latitude, 
                point.longitude, 
                widget.initialCenter.latitude, 
                widget.initialCenter.longitude, 
                widget.radius
              );
            }

            if (!isAllowed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.errorLocationOutsideRecinct),
                  backgroundColor: theme.colorScheme.error,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
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
            userAgentPackageName: 'com.unilost.app',
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
          if (widget.polygon == null || widget.polygon!.isEmpty)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: widget.initialCenter,
                  radius: widget.radius,
                  useRadiusInMeter: true,
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
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
