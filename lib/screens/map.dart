import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick your Location' : 'Your Location',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
              icon: Icon(Icons.save),
            ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          initialZoom: 16,
          interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
          onTap: widget.isSelecting
              ? (tapPosition, latLng) {
                  setState(() {
                    _pickedLocation = latLng;
                  });
                }
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.favorite_places',
          ),
          MarkerLayer(
            markers: (_pickedLocation == null && widget.isSelecting)
                ? []
                : [
                    Marker(
                      point:
                          _pickedLocation ??
                          LatLng(
                            widget.location.latitude,
                            widget.location.longitude,
                          ),
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
