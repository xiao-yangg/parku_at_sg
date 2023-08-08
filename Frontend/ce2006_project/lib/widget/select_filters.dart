import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/place_search.dart';
import 'package:ce2006_project/screens/rendering_screen.dart';
import 'package:flutter/material.dart';

/// This is the AccountTab class also known as Account Page
/// Attributes:
/// destination - user selected destination
/// endUser - current user
/// dropdownDistance - user select preferred distance of carpark from destination
/// dropdownParkingRate - user select preferred parking rate of carpark
/// dropdownLotAvailabiltiy - user select preferred lot availability of carpark
class SelectFilters extends StatefulWidget {
  final PlaceSearch destination;
  final AppUser endUser;

  const SelectFilters({
    Key? key,
    required this.destination,
    required this.endUser,
  }) : super(key: key);

  @override
  _SelectFiltersState createState() => _SelectFiltersState();
}

class _SelectFiltersState extends State<SelectFilters> {
  String dropdownDistance = '5.0';
  String dropdownParkingRate = '1.20';
  String dropdownLotAvailability = 'High';

  @override
  Widget build(BuildContext context) {
    // no change in color
    Color kPrimaryColor = kLightColor;
    Color kSecondaryColor = kDarkColor;

    return Container(
      color: (!widget.endUser.darkModeStatus)
          ? const Color(0xff757575)
          : const Color(0xff191822),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 50,
        ),
        decoration: kBottomContainer.copyWith(color: kPrimaryColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Carpark Choices",
              style: kCardBoldTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Destination:",
              style: kCardNormalTextStyle.copyWith(
                color: kSecondaryColor,
              ),
            ),
            Text(
              widget.destination.address
                  .substring(0, widget.destination.address.length - 11)
                  .toUpperCase(),
              style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Distance (km)',
                  style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
                ),
                DropdownButton<String>(
                  value: dropdownDistance,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: kSecondaryColor,
                  ),
                  elevation: 16,
                  style: TextStyle(color: kSecondaryColor),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownDistance = newValue!;
                    });
                  },
                  items: <String>[
                    '10.0',
                    '7.5',
                    '5.0',
                    '2.5',
                    '1.0',
                  ].map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: kSecondaryColor),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Parking Rate (\$)',
                  style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
                ),
                DropdownButton<String>(
                  value: dropdownParkingRate,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: kSecondaryColor,
                  ),
                  elevation: 16,
                  style: TextStyle(color: kSecondaryColor),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownParkingRate = newValue!;
                    });
                  },
                  items: <String>[
                    '2.80',
                    '2.40',
                    '2.00',
                    '1.60',
                    '1.20',
                  ].map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: kSecondaryColor),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Lot Availability',
                  style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
                ),
                DropdownButton<String>(
                  value: dropdownLotAvailability,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: kSecondaryColor,
                  ),
                  elevation: 16,
                  style: TextStyle(color: kSecondaryColor),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownLotAvailability = newValue!;
                    });
                  },
                  items: <String>['Low', 'Med', 'High']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: kSecondaryColor),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: raisedButtonStyle.copyWith(
                  backgroundColor: MaterialStateProperty.all(kSecondaryColor)),
              onPressed: () {
                // go to Rendering Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RenderingScreen(
                      destination: widget.destination,
                      dropdownDistance: dropdownDistance,
                      dropdownParkingRate: dropdownParkingRate,
                      dropdownLotAvailability: dropdownLotAvailability,
                      endUser: widget.endUser,
                    ),
                  ),
                );
              },
              child: Text(
                'Find Carparks!',
                style: TextStyle(
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
