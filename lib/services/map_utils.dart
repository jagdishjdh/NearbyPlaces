import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtils {

  CameraPosition mumbai = CameraPosition(
    target: LatLng(19.076090, 72.877426),
    zoom: 14,
  );

  Future<Position> getLocation() async{
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        locationPermissionLevel: GeolocationPermission.locationWhenInUse);
    return position;
  }

}