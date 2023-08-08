import 'dart:async';

import 'package:ce2006_project/components/carpark_info_card.dart';
import 'package:ce2006_project/components/carpark_simple_card.dart';
import 'package:ce2006_project/components/custom_text_button.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/carpark.dart';
import 'package:ce2006_project/models/carpark_data.dart';
import 'package:ce2006_project/models/location.dart';
import 'package:ce2006_project/widget/select_carpark.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// This is the TripScreen class also known as Trip Page
/// Attributes:
/// finalDestination - destination selected by user
/// dropdownDistance - distance selected in Filter Widget
/// dropdownParkingRate - parking rate selected in Filter Widget
/// dropdownLotAvailability - lot availability selected in Filter Widget
/// carparkProvider - recommended carparks from backend server + database
/// markersProvider - generated set of markers for display on Google Maps
/// polylines - polyline made for display on Google Maps
/// endUser - current user
class TripScreen extends StatefulWidget {
  final Location finalDestination;
  final String dropdownDistance;
  final String dropdownParkingRate;
  final String dropdownLotAvailability;
  final CarparkData carparksProvider;
  final List<Marker> markersProvider;
  final Map<PolylineId, Polyline> polylines;
  final AppUser endUser;

  const TripScreen({
    Key? key,
    required this.finalDestination,
    required this.dropdownDistance,
    required this.dropdownParkingRate,
    required this.dropdownLotAvailability,
    required this.carparksProvider,
    required this.markersProvider,
    required this.polylines,
    required this.endUser,
  }) : super(key: key);

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool _isVisible = true;

  final Completer<GoogleMapController> _controller = Completer();

  List<String> selectedCategory = <String>[];
  String all = 'All';
  String category1 = 'Distance (km)';
  String category2 = 'Parking Rate (\$)';
  String category3 = 'Lot Availability';
  String choiceOfFilter = 'Distance';
  bool initialize = true; // default

  List<Marker> modifiedMarkers = <Marker>[]; // active markers

  double horizontalListHeight = 0.29;

  bool splash = false; // to wait for Google Maps to completely build finish
  @override
  void initState() {
    super.initState();

    setActiveMarkers();
    setMapFitToTour(Set<Polyline>.of(widget.polylines.values));

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        splash = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (initialize) {
      selectedCategory.add(category1);
      choiceOfFilter = 'Distance';
      sortDistance();
      initialize = false;
    }

    Color kPrimaryColor =
        !widget.endUser.darkModeStatus ? kLightColor : kDarkColor;
    Color kSecondaryColor =
        !widget.endUser.darkModeStatus ? kDarkColor : kLightColor;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: <Widget>[
          Expanded(
            child: splash
                ? Stack(
                    children: <Widget>[
                      ClipRRect(
                        // child: Container(
                        //   color: Colors.black,
                        // ),
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              widget.endUser.currentLocation.latitude,
                              widget.endUser.currentLocation.longitude,
                            ),
                            zoom: 13,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomGesturesEnabled: true,
                          zoomControlsEnabled: false,
                          markers: modifiedMarkers.toSet(),
                          polylines: Set<Polyline>.of(widget.polylines.values),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                        child: Stack(
                          children: <Widget>[
                            TextField(
                              readOnly: true,
                              textAlign: TextAlign.start,
                              decoration: kSearchFieldDecoration.copyWith(
                                hintText: widget.finalDestination.address
                                    .toUpperCase(),
                                filled: true,
                                fillColor: kLightColor,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 28,
                                ),
                                color: kDarkColor,
                                onPressed: () {
                                  int count = 0;
                                  Navigator.of(context).popUntil((_) =>
                                      count++ >= 2); // pop to Filter Widget
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // --> Floating Filters
                        padding: const EdgeInsets.fromLTRB(15, 100, 15, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory.add(all);
                                  selectedCategory.add(category1);
                                  selectedCategory.add(category2);
                                  selectedCategory.add(category3);
                                  choiceOfFilter = 'Everything';

                                  sortAll();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: selectedCategory.contains(all)
                                      ? kSecondaryColor
                                      : kPrimaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0)),
                                ),
                                child: Text(
                                  'All',
                                  style: TextStyle(
                                      color: selectedCategory.contains(all)
                                          ? kPrimaryColor
                                          : kSecondaryColor,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = <String>[];
                                  selectedCategory.add(category1);
                                  choiceOfFilter = 'Distance';

                                  sortDistance();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: selectedCategory.contains(category1)
                                      ? kSecondaryColor
                                      : kPrimaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0)),
                                ),
                                child: Text(
                                  category1,
                                  style: TextStyle(
                                      color:
                                          selectedCategory.contains(category1)
                                              ? kPrimaryColor
                                              : kSecondaryColor,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = <String>[];
                                  selectedCategory.add(category2);
                                  choiceOfFilter = 'Parking Rate';

                                  sortParkingRate();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: selectedCategory.contains(category2)
                                      ? kSecondaryColor
                                      : kPrimaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0)),
                                ),
                                child: Text(
                                  category2,
                                  style: TextStyle(
                                      color:
                                          selectedCategory.contains(category2)
                                              ? kPrimaryColor
                                              : kSecondaryColor,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6.0,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = <String>[];
                                  selectedCategory.add(category3);
                                  choiceOfFilter = 'Lot Availability';

                                  sortLotAvailability();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: selectedCategory.contains(category3)
                                      ? kSecondaryColor
                                      : kPrimaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0)),
                                ),
                                child: Text(
                                  category3,
                                  style: TextStyle(
                                      color:
                                          selectedCategory.contains(category3)
                                              ? kPrimaryColor
                                              : kSecondaryColor,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        // --> Horizontal Carpark List
                        visible: _isVisible,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: horizontalListHeight *
                                  MediaQuery.of(context).size.height,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      widget.carparksProvider.carparks.length,
                                  itemBuilder: (context, index) {
                                    return CarparkSimpleCard(
                                      carpark: widget
                                          .carparksProvider.carparks[index],
                                      endUser: widget.endUser,
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        // --> Filter Labels
                        visible: _isVisible,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 15.0,
                              bottom: ((horizontalListHeight + 0.02) *
                                  MediaQuery.of(context).size.height),
                            ),
                            child: Text(
                              'Filters:\nDistance: ' +
                                  widget.dropdownDistance +
                                  'km\nParking Rate: \$' +
                                  widget.dropdownParkingRate +
                                  '\nLot Availability: ' +
                                  widget.dropdownLotAvailability,
                              style: kCardNormalTextStyle.copyWith(
                                  color: kDarkColor),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        // --> Change View
                        visible: _isVisible,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: ((horizontalListHeight + 0.04) *
                                  MediaQuery.of(context).size.height),
                              right: 15.0,
                            ),
                            child: SizedBox(
                              width: (0.29 * MediaQuery.of(context).size.width),
                              child: CustomTextButton(
                                function: () {
                                  showToast();
                                  zoomOnDestNotVisible();
                                },
                                icon: const Icon(
                                  Icons.view_list,
                                  color: kDarkColor,
                                  size: 15.0,
                                ),
                                text: 'Info View',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 15.0,
                          top: (0.24 * MediaQuery.of(context).size.height),
                        ),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                (_isVisible)
                                    ? zoomOnDest()
                                    : zoomOnDestNotVisible();
                              },
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.zoom_in,
                                    color: kDarkColor,
                                    size: 25.0,
                                  ),
                                  Text(
                                    "Zoom Dest",
                                    style: kCardNormalTextStyle.copyWith(
                                        color: kDarkColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            GestureDetector(
                              onTap: () {
                                setMapFitToTour(
                                    Set<Polyline>.of(widget.polylines.values));
                              },
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.zoom_out,
                                    color: kDarkColor,
                                    size: 25.0,
                                  ),
                                  Text(
                                    "Zoom Trip",
                                    style: kCardNormalTextStyle.copyWith(
                                        color: kDarkColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        // --> Draggable Vertical Carpark List
                        visible: !_isVisible,
                        child: SizedBox.expand(
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.55,
                            minChildSize: 0.38,
                            maxChildSize: 0.79,
                            builder: (BuildContext context,
                                ScrollController scrollController) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 30,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Best $choiceOfFilter',
                                            style: kCardBoldTextStyle.copyWith(
                                                color: kSecondaryColor),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showToast();
                                              zoomOnDest();
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.autorenew,
                                                  color: kSecondaryColor,
                                                  size: 15.0,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Change View',
                                                  style: kCardNormalTextStyle
                                                      .copyWith(
                                                    color: kSecondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          controller: scrollController,
                                          itemCount: widget
                                              .carparksProvider.carparks.length,
                                          itemBuilder: (context, index) {
                                            return CarparkInfoCard(
                                              carpark: widget.carparksProvider
                                                  .carparks[index],
                                              endUser: widget.endUser,
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
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
                          'We are almost there!',
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

  /// This function is used for changing views
  void showToast() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  /// This function is used for sorting carparks according to preference 'All'
  void sortAll() {
    List tempResults = [];
    int counter = 0;
    int availabilityConvert = (widget.dropdownLotAvailability == 'High')
        ? 50
        : (widget.dropdownLotAvailability == 'Med')
            ? 30
            : 10;

    while (counter < widget.carparksProvider.carparks.length) {
      Carpark i = widget.carparksProvider.carparks[counter];

      if (i.distance < double.parse(widget.dropdownDistance) &&
          i.rate < double.parse(widget.dropdownParkingRate) &&
          double.parse(i.predictions[4]['lot_count']) > availabilityConvert) {
        // fulfil all criteria
        tempResults.add(i);
        widget.carparksProvider.carparks.remove(i);
      } else if (i.distance < double.parse(widget.dropdownDistance)) {
        // sort by best distance
        tempResults.add(i);
        widget.carparksProvider.carparks.remove(i);
      } else if (i.rate < double.parse(widget.dropdownParkingRate)) {
        // sort by best parking rate
        tempResults.add(i);
        widget.carparksProvider.carparks.remove(i);
      } else if (double.parse(i.predictions[4]['lot_count']) >
          availabilityConvert) {
        // sort by lot availability
        tempResults.add(i);
        widget.carparksProvider.carparks.remove(i);
      }
      counter++;
    }

    widget.carparksProvider.carparks.sort(
        (a, b) => a.distance.compareTo(b.distance)); // rest sort by distance

    for (int i = 0; i < tempResults.length; i++) {
      widget.carparksProvider.carparks.insert(i, tempResults[i]);
    }
  }

  /// This function is used for sorting carparks according to distance (low to high)
  void sortDistance() {
    widget.carparksProvider.carparks
        .sort((a, b) => a.distance.compareTo(b.distance));
  }

  /// This function is used for sorting carparks according to parking rate (low to high)
  void sortParkingRate() {
    widget.carparksProvider.carparks.sort((a, b) => a.rate.compareTo(b.rate));
  }

  /// This function is used for sorting carparks according to lot availability (high to low)
  void sortLotAvailability() {
    widget.carparksProvider.carparks.sort((b, a) =>
        a.predictions[4]['lot_count'].compareTo(b.predictions[4]['lot_count']));
  }

  /// This function is used to set active markers
  void setActiveMarkers() {
    for (Marker m in widget.markersProvider) {
      Marker _marker = Marker(
          markerId: m.markerId,
          infoWindow: m.infoWindow,
          position: m.position,
          icon: m.icon,
          onTap: () {
            Carpark? c = findCarparkUsingMarker(m.markerId.value);

            if (c != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (builder) => SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SelectCarpark(
                      carpark: c,
                      endUser: widget.endUser,
                      infoView: false,
                    ),
                  ),
                ),
              );
            }
          });

      modifiedMarkers.add(_marker);
    }
  }

  /// This function is used to find carparks using marker information
  Carpark? findCarparkUsingMarker(String carparkAddr) {
    for (Carpark c in widget.carparksProvider.carparks) {
      if (c.location.address.contains(carparkAddr)) {
        return c;
      }
    }
    return null;
  }

  /// This function is used to fit map that shows entire trip
  void setMapFitToTour(Set<Polyline> p) {
    // initialize using first values
    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;

    // search for min max values
    for (var poly in p) {
      for (var point in poly.points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      }
    }

    Future<void> showOnMap() async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: (_isVisible)
                  ? LatLng(minLat, minLong)
                  : LatLng(minLat - 0.11, minLong + 0.10),
              northeast: (_isVisible)
                  ? LatLng(maxLat, maxLong)
                  : LatLng(maxLat - 0.11, maxLong + 0.10)),
          (_isVisible) ? 20 : 145));
    }

    showOnMap();
    if (initialize) {
      Future.delayed(const Duration(seconds: 3), () {
        zoomOnDest();
      });
    }
  }

  /// This function is used to zoom map on destination
  Future<void> zoomOnDest() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(
          widget.finalDestination.latitude,
          widget.finalDestination.longitude,
        ),
        zoom: 14,
      ),
    ));
  }

  /// This function is used to zoom map on destination when map view is shrinked
  Future<void> zoomOnDestNotVisible() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(
          widget.finalDestination.latitude - 0.011,
          widget.finalDestination.longitude,
        ),
        zoom: 14,
      ),
    ));
  }
}
