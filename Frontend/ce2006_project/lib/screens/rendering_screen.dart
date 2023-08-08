import 'dart:convert' as convert;

import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/location.dart';
import 'package:ce2006_project/models/place_search.dart';
import 'package:ce2006_project/screens/mains/trip_screen.dart';
import 'package:ce2006_project/services/all_services_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// This is the RenderingScreen class also known as Rendering Page
/// Attributes:
/// destination - destination selected by user
/// dropdownDistance - distance selected in Filter Widget
/// dropdownParkingRate - parking rate selected in Filter Widget
/// dropdownLotAvailability - lot availability selected in Filter Widget
/// endUser - current user
class RenderingScreen extends StatefulWidget {
  final PlaceSearch destination;
  final String dropdownDistance;
  final String dropdownParkingRate;
  final String dropdownLotAvailability;
  final AppUser endUser;

  const RenderingScreen({
    Key? key,
    required this.destination,
    required this.dropdownDistance,
    required this.dropdownParkingRate,
    required this.dropdownLotAvailability,
    required this.endUser,
  }) : super(key: key);

  @override
  _RenderingScreenState createState() => _RenderingScreenState();
}

class _RenderingScreenState extends State<RenderingScreen> {
  @override
  void initState() {
    super.initState();
    getBackendServerData();
  }

  @override
  Widget build(BuildContext context) {
    Color kPrimaryColor =
        !widget.endUser.darkModeStatus ? kLightColor : kDarkColor;
    Color kSecondaryColor =
        !widget.endUser.darkModeStatus ? kDarkColor : kLightColor;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    color: kSecondaryColor,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'Finding best carparks...',
                    style: kCardNormalTextStyle.copyWith(
                      color: kSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// This function is used to get carparks from backend + server base on user selected destination and preferences, thereafter go to Trip Page
  void getBackendServerData() async {
    const key = kAPIKEY;

    // get lat, lng from destination place id
    String destinationId = widget.destination.placeId;
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$destinationId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    double destLat = json['result']['geometry']['location']['lat'];
    double destLng = json['result']['geometry']['location']['lng'];

    Location finalDestination = Location(
        address: widget.destination.address
            .substring(0, widget.destination.address.length - 11),
        latitude: destLat,
        longitude: destLng);

    // get distance and estimated time of journey
    String originLat = widget.endUser.currentLocation.latitude.toString();
    String originLng = widget.endUser.currentLocation.longitude.toString();

    var url2 =
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=place_id:$destinationId&origins=$originLat,$originLng&key=$key';

    var response2 = await http.get(Uri.parse(url2));
    var json2 = convert.jsonDecode(response2.body);

    String distance = json2['rows'][0]['elements'][0]['distance']['text'];
    String duration = json2['rows'][0]['elements'][0]['duration']['text'];

    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/parking_icon.png');

    // get carparks data
    var carparksProvider = await CarparksService().getCarparks(
        destLat,
        destLng,
        50,
        duration,
        widget.dropdownDistance,
        widget.dropdownParkingRate,
        icon);

    // convert carparks to markers
    var markersProvider =
        MarkerService().getMarkers(carparksProvider, widget.endUser);

    // add destination marker
    MarkerId markerId = MarkerId(finalDestination.address);
    Marker marker = Marker(
      markerId: markerId,
      infoWindow: InfoWindow(
          title: finalDestination.address,
          snippet: distance + "   " + duration),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(destLat, destLng),
    );
    markersProvider.add(marker);

    // add polyline between origin & des
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    Map<PolylineId, Polyline> polylines = {};

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      key,
      PointLatLng(
        double.parse(originLat),
        double.parse(originLng),
      ),
      PointLatLng(
        destLat,
        destLng,
      ),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }

    PolylineId id = const PolylineId("poly");

    Polyline polyline = Polyline(
      polylineId: id,
      color: kDarkColor,
      points: polylineCoordinates,
      width: 5,
    );

    polylines[id] = polyline;

    Future.delayed(const Duration(milliseconds: 200), () {});

    // go to trip screen
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TripScreen(
          finalDestination: finalDestination,
          dropdownDistance: widget.dropdownDistance,
          dropdownParkingRate: widget.dropdownParkingRate,
          dropdownLotAvailability: widget.dropdownLotAvailability,
          carparksProvider: carparksProvider,
          markersProvider: markersProvider,
          polylines: polylines,
          endUser: widget.endUser,
        ),
      ),
    );
  }
}
