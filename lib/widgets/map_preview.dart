import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPreview extends StatelessWidget {
  const MapPreview({super.key, required this.pickedLocation});

  final PlaceLocation pickedLocation;

  @override
  Widget build(BuildContext context) {
    final latitude = pickedLocation.latitude;
    final longitude = pickedLocation.longitude;

    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 16,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.favorite_places',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
