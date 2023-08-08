import 'dart:convert' as convert;

import 'package:ce2006_project/models/carpark.dart';
import 'package:ce2006_project/models/carpark_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// This is the CarparkService class used in Rendering Page
class CarparksService {
  /// This function is for getting carparks from backend + server
  Future<CarparkData> getCarparks(
      double lat,
      double lng,
      int dataCount,
      String duration,
      String distance,
      String rate,
      BitmapDescriptor icon) async {
    CarparkData _carparks = CarparkData(carparks: []);

    DateTime now = DateTime.now();
    duration =
        duration.replaceAll(RegExp(r'[^0-9]'), ''); // clear all non-numbers

    int min = 0;
    int hr = 0;
    if (duration.length <= 2) {
      min = int.parse(duration);
    } else {
      min = int.parse(duration.substring(duration.length - 2, duration.length));
      hr = int.parse(duration.substring(0, duration.length - 2));
    }

    now = now.add(Duration(hours: hr, minutes: min));
    String formatDateTime = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

    var url = 'http://172.21.148.166:8001/searchCarPark';

    var response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode({
          "location": {"latitude": lat, "longitude": lng},
          "max_distance": double.parse(distance),
          "max_rate": double.parse(rate),
          "count": dataCount,
          "time": formatDateTime
        }));

    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;

    for (var carpark in jsonResults) {
      _carparks.carparks.add(Carpark.fromJson(carpark, icon));
    }

    return _carparks;
  }
}
