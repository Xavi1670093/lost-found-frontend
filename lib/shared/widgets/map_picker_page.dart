import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:unilost_found/core/localization/app_strings.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialCenter;
  final LatLngBounds? bounds;

  const MapPickerPage({
    super.key,
    required this.initialCenter,
    this.bounds,
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

  LatLngBounds _expandBounds(LatLngBounds bounds) {
    // Añadimos un margen de 0.02 grados (~2km) para permitir mayor exploración lateral y vertical
    const double margin = 0.020;
    
    return LatLngBounds(
      LatLng(bounds.south - margin, bounds.west - margin),
      LatLng(bounds.north + margin, bounds.east + margin),
    );
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
            setState(() {
              selectedLocation = point;
            });
          },
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          cameraConstraint: widget.bounds != null 
            ? CameraConstraint.contain(bounds: _expandBounds(widget.bounds!))
            : const CameraConstraint.unconstrained(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.lostfound',
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
