import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/carpark_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// This is the MarkerService class used in Rendering Page
class MarkerService {
  /// This function is for making markers of carparks for Google Maps
  List<Marker> getMarkers(CarparkData _carparks, AppUser endUser) {
    List<Marker> _markers = <Marker>[];

    for (var carpark in _carparks.carparks) {
      Marker _marker = Marker(
        markerId: MarkerId(carpark.location.address.toString()),
        infoWindow: InfoWindow(
            title: carpark.location.address,
            snippet: "\$" +
                carpark.rate.toStringAsFixed(2) +
                "   " +
                carpark.distance.toStringAsFixed(2) +
                "km"),
        position: LatLng(carpark.location.latitude, carpark.location.longitude),
        icon: carpark.icon,
      );

      _markers.add(_marker);
    }

    return _markers;
  }
}
