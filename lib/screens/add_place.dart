import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/providers/user_places.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final TextEditingController _placeController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  void _savePlace() {
    final enteredTitle = _placeController.text;

    if (enteredTitle.isEmpty ||
        _selectedImage == null ||
        _selectedLocation == null) {
      return;
    }

    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enteredTitle, _selectedImage!, _selectedLocation!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _placeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new Place", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _placeController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 10),
            ImageInput(
              onPickedImage: (image) {
                _selectedImage = image;
              },
            ),
            SizedBox(height: 10),
            LocationInput(
              onSelectLocation: (PlaceLocation location) {
                _selectedLocation = location;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _savePlace,
              icon: Icon(Icons.add),
              label: Text("Add Place"),
            ),
          ],
        ),
      ),
    );
  }
}
