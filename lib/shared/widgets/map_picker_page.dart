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
    this.radius = 1100,
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

  bool get _isLocationValid {
    if (widget.polygon != null && widget.polygon!.isNotEmpty) {
      return LocationService.isPointInPolygon(selectedLocation, widget.polygon!);
    }
    return LocationService.isWithinRadius(
      selectedLocation.latitude,
      selectedLocation.longitude,
      widget.initialCenter.latitude,
      widget.initialCenter.longitude,
      widget.radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final isValid = _isLocationValid;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.mapLocation),
        actions: [
          TextButton(
            onPressed: isValid ? () => Navigator.pop(context, selectedLocation) : null,
            child: Text(
              t.save,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isValid ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: isValid ? 0 : null,
            color: theme.colorScheme.errorContainer,
            curve: Curves.easeInOut,
            child: isValid
                ? const SizedBox.shrink()
                : SafeArea(
                    bottom: false,
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onErrorContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t.errorLocationOutsideRecinct,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 13.5,
                minZoom: 10,
                maxZoom: 19,
                onTap: (tapPosition, point) {
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
                        borderStrokeWidth: 3,
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
                        borderStrokeWidth: 3,
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
                        color: isValid ? theme.colorScheme.primary : theme.colorScheme.error,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

