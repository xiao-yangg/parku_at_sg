import 'package:ce2006_project/models/carpark_info.dart';
import 'package:ce2006_project/models/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// This is the Carpark class
/// Attributes:
/// id - id of carpark
/// location - location of carpark
/// distance - distance of carpark from destination
/// rate - parking rate of carpark
/// predictions - prediction of available lots in carpark
/// totalLots - total amount of lots in carpark
/// info - more information of carpark
/// icon - parking icon
class Carpark {
  final String id;
  final Location location;
  final double distance;
  final double rate;
  final List predictions;
  final int totalLots;
  final CarparkInfo information;
  final BitmapDescriptor icon;

  Carpark({
    required this.id,
    required this.location,
    required this.distance,
    required this.rate,
    required this.predictions,
    required this.totalLots,
    required this.information,
    required this.icon,
  });

  Carpark.fromJson(Map<String, dynamic> parsedJson,
      this.icon) // interesting direct initializing
      : id = parsedJson['id'],
        location = Location(
            address: parsedJson['address'],
            latitude: parsedJson['lat'],
            longitude: parsedJson['long']),
        distance = parsedJson['distance'],
        rate = parsedJson['rate'],
        predictions = parsedJson['predictions'],
        totalLots = parsedJson['total_lots'],
        information = CarparkInfo(
            parkingSystem: parsedJson['parking_system'],
            type: parsedJson['car_park_type'],
            freeParking: parsedJson['free_parking_text'],
            gantryHeight: parsedJson['gantry_height'],
            nightParking: parsedJson['night_parking']);
}
