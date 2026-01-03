import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:favorite_places/widgets/map_preview.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  bool _isGettingLocation = false;

  Future<void> _savePlace(double lat, double lng) async {
    final address = await _getAddressFromLatLng(lat, lng);
    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );

      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isEmpty) return 'No address found';

    final place = placemarks.first;

    return [
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }

  void _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) return;

    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
    LatLng? pickedLocation = await Navigator.of(
      context,
    ).push<LatLng>(MaterialPageRoute(builder: (ctx) => MapScreen()));

    if (pickedLocation == null) return;

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      "No location chosen",
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );

    if (_isGettingLocation) {
      previewContent = CircularProgressIndicator();
    } else if (_pickedLocation != null) {
      previewContent = MapPreview(
        key: ValueKey(
          '${_pickedLocation!.latitude},${_pickedLocation!.longitude}',
        ),
        pickedLocation: _pickedLocation!,
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: Text('Get Current Location'),
              icon: Icon(Icons.location_on),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              label: Text('Select on Map'),
              icon: Icon(Icons.map),
            ),
          ],
        ),
      ],
    );
  }
}
