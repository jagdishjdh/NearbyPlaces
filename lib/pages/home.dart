import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geohash/geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_places/pages/places/place_details.dart';
import 'package:nearby_places/pages/user/add_place.dart';
import 'package:nearby_places/pages/user/my_places.dart';
import 'package:nearby_places/pages/user/my_reviews.dart';
import 'package:nearby_places/services/auth.dart';
import 'package:nearby_places/services/database.dart';
import 'package:nearby_places/services/map_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  GoogleMapController _controller;
  LatLng _tap;
  Marker _tappedMarker;
  Set<Marker> _placesMarkers;

  static final CameraPosition _home = CameraPosition(
    target: LatLng(24.88, 72.85),
    zoom: 15.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                await _authService.signOut();
              },
              icon: Icon(Icons.person),
              label: Text("logout")),
        ],
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _home,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          markers: _createMarker(),
          onTap: (LatLng pos) {
            print("tapped on $pos");
            setState(() {
              _tap = pos;
            });
          },
          onLongPress: (LatLng pos) {
            print("Long press on $pos");
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onCameraIdle: _onCameraIdle,
        ),
      ]),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(AuthService.user.email),
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
            ),
            myListTile("Add Restaurant", (context) => AddPlace()),
            myListTile("My Places", (context) => MyPlaces()),
            myListTile("My Reviews", (context) => MyReviews()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: _goToMyLocation,
      ),
    );
  }

  Widget myListTile(String name, Function builder) {
    return ListTile(
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: builder));
      },
    );
  }

  Future<void> _goToMyLocation() async {
    if (await Permission.location.request().isGranted) {
      Position position = await MapUtils().getLocation();

      setState(() {
        _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        )));
      });
    } else {
      print("Location permission not granted");
    }
  }

  void _onCameraIdle() async {
    LatLngBounds latLngBounds = await _controller.getVisibleRegion();
    String startHash = Geohash.encode(
        latLngBounds.southwest.latitude, latLngBounds.southwest.longitude);
    String endHash = Geohash.encode(
        latLngBounds.northeast.latitude, latLngBounds.northeast.longitude);

    QuerySnapshot result = await _databaseService.getRestaurants(
        startHash: startHash, endHash: endHash);
    if (result != null) {
      setState(() {
        _placesMarkers = result.documents
            .map((e) => Marker(
                markerId: MarkerId(e.documentID),
                position: LatLng(
                    e.data["position"].latitude, e.data["position"].longitude),
                icon: BitmapDescriptor.defaultMarker,
                onTap: (){
                  print("${e.data["name"]} tapped");
                },
                infoWindow: InfoWindow(
                    title: e.data['name'],
                    snippet: e.data["desc"],
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                              builder: (context) => PlaceDetails(placeRef: e.reference)));
                    })))
            .toSet();
      });
      print(_placesMarkers.length);
    }
//    double zoom = await _controller.getZoomLevel();
  }

  Set<Marker> _createMarker() {
    if (_tap != null) {
      _tappedMarker = Marker(
        markerId: MarkerId("tapped"),
        position: _tap,
        icon: BitmapDescriptor.defaultMarkerWithHue(120),
        infoWindow: InfoWindow(title: "My Marker"),
        draggable: true,
      );
    }
    if (_tappedMarker != null && _placesMarkers != null) {
      return _placesMarkers.union({_tappedMarker});
    } else if (_tappedMarker != null) {
      return {_tappedMarker};
    } else if (_placesMarkers != null) {
      return _placesMarkers;
    } else {
      return {};
    }
  }
}
