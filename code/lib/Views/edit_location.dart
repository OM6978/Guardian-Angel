import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  LatLng? currentLocation;
  MapScreen({
    super.key,
    this.currentLocation,
  });
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng markerPosition = LatLng(0, 0);
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.currentLocation!.latitude,
                    widget.currentLocation!.longitude), // Initial map center
                zoom: 18.0, // Initial zoom level
              ),
              onCameraMove: (CameraPosition position) {
                // Start or reset the timer
                _startTimer(position);
              },
              markers: {
                Marker(
                  markerId: MarkerId('myMarker'),
                  position: markerPosition,
                  draggable: false,
                ),
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (markerPosition != null) {
                return Navigator.pop(context, markerPosition);
                // Here you can use the coordinates as you wish, for example, you can pass them to another function, or store them in variables.
              } else {
                print('Marker not selected');
              }
            },
            child: Text('Select Location'),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _startTimer(CameraPosition position) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel(); // Cancel the previous timer if active
    }
    _timer = Timer(Duration(milliseconds: 1), () {
      // Update marker position after 500 milliseconds
      setState(() {
        markerPosition = position.target;
      });
    });
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }
}
