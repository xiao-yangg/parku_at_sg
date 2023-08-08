import 'package:geolocator/geolocator.dart';

/// This is the GeolocatorService class used in Loading Page and Home Page
class GeolocatorService {
  /// This function is for getting user current location
  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied by user');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions');
    }

    Position _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return _position;
  }
}
