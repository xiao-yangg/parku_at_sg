import 'dart:async';

import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/place_search.dart';
import 'package:ce2006_project/services/all_services_export.dart';
import 'package:ce2006_project/widget/select_filters.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// This is the DestinationScreen class also known as Destination Page
/// Attributes:
/// endUser - current user
/// initialSearch - initial search for destination if any
/// searchFieldController - controller for search field
/// destination - user desired destination
/// searchResults - search results from Google Places API
class DestinationScreen extends StatefulWidget {
  final AppUser endUser;
  final String initialSearch;

  const DestinationScreen({
    Key? key,
    required this.endUser,
    required this.initialSearch,
  }) : super(key: key);

  @override
  _DestinationScreenState createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  TextEditingController searchFieldController = TextEditingController();

  late PlaceSearch destination;

  final placeSearchService = PlacesSearchService();

  List<PlaceSearch> searchResults = [];

  String previousValue = '';
  bool initialize = true;
  String? errorMessage;
  int isSelected = -1; // differentiate selected item
  bool isNotRecent = false;

  @override
  Widget build(BuildContext context) {
    if (initialize) {
      // use initial search if any
      searchFieldController.value =
          searchFieldController.value.copyWith(text: widget.initialSearch);
      initialize = false;
    }
    String searchValue = searchFieldController.text;

    List recentResults = widget.endUser.recents;

    Color kPrimaryColor =
        !widget.endUser.darkModeStatus ? kLightColor : kDarkColor;
    Color kSecondaryColor =
        !widget.endUser.darkModeStatus ? kDarkColor : kLightColor;

    /// Periodic timer to retrieve search results from Google Places API
    bool _isRunning = true;
    Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
      if (!_isRunning) {
        timer.cancel();
      }
      if (previousValue != searchFieldController.text) {
        // input is changed
        previousValue = searchFieldController.text;
        searchPlaces(searchFieldController.text);

        isSelected = 0; // top result
      }
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kPrimaryColor,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: kPrimaryColor,
          ),
          backgroundColor: kSecondaryColor,
          elevation: 0,
          title: Text(
            'Destination',
            style: kAppTitleStyle.copyWith(fontSize: 20, color: kPrimaryColor),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus(); // hides keyboard

              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pop(context);
              });
            },
            icon: Icon(
              Icons.arrow_back,
              color: kPrimaryColor,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
              decoration: BoxDecoration(
                color: kSecondaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  TextField(
                    controller: searchFieldController,
                    keyboardType: TextInputType.streetAddress,
                    style: TextStyle(color: kSecondaryColor),
                    textAlign: TextAlign.start,
                    onChanged: (value) {
                      searchValue = searchFieldController.text;
                    },
                    decoration: kSearchFieldDecoration.copyWith(
                      hintText: 'Where to?',
                      hintStyle: TextStyle(color: kSecondaryColor),
                      fillColor: kPrimaryColor,
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: kSecondaryColor,
                        size: 28.0,
                      ),
                    ),
                    autofocus: true,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 28,
                      ),
                      color: kSecondaryColor,
                      onPressed: () {
                        try {
                          if (searchFieldController.text.isNotEmpty &&
                              destination != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: buildBottomSheet,
                            );

                            _isRunning = false;
                          }
                        } catch (error) {
                          errorMessage = "Select a destination!";
                          Fluttertoast.showToast(msg: errorMessage!);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: (searchValue == '')
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Recents',
                          style: kCardBoldTextStyle.copyWith(
                              fontSize: 25, color: kSecondaryColor),
                        ),
                        (recentResults.isEmpty)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Nothing found',
                                  style: kCardNormalTextStyle.copyWith(
                                    color: kSecondaryColor,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: recentResults.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: <Widget>[
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();

                                          // use recents as destination search
                                          String desiredAddr =
                                              recentResults[index];
                                          searchFieldController.text =
                                              (desiredAddr.length > 26)
                                                  ? desiredAddr.substring(0, 26)
                                                  : desiredAddr;

                                          searchValue =
                                              searchFieldController.text;
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                              color: kSecondaryColor,
                                              size: 15.0,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              recentResults[index],
                                              style:
                                                  kCardNormalTextStyle.copyWith(
                                                fontSize: 18,
                                                color: kSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 1.0),
                                        child: Divider(
                                          color: kSecondaryColor,
                                          height: 5,
                                          thickness: 1.0,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Search Result',
                          style: kCardBoldTextStyle.copyWith(
                              fontSize: 25, color: kSecondaryColor),
                        ),
                        (searchResults.isEmpty)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Nothing found',
                                  style: kCardNormalTextStyle.copyWith(
                                    color: kSecondaryColor,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: <Widget>[
                                      TextButton(
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0.0, horizontal: 5.0),
                                            backgroundColor:
                                                (isSelected == index &&
                                                        isNotRecent)
                                                    ? kSecondaryColor
                                                    : kPrimaryColor),
                                        onPressed: () {
                                          destination = searchResults[index];

                                          FocusScope.of(context).unfocus();

                                          // select destination
                                          String desiredAddr = destination
                                              .address
                                              .substring(
                                                  0,
                                                  destination.address.length -
                                                      11)
                                              .toUpperCase();

                                          searchFieldController.text =
                                              (desiredAddr.length > 26)
                                                  ? desiredAddr.substring(
                                                          0, 26) +
                                                      '...'
                                                  : desiredAddr;

                                          searchValue =
                                              searchFieldController.text;

                                          setState(() {
                                            isSelected = index;
                                          });

                                          isNotRecent = true;
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.location_searching,
                                              color: (isSelected == index &&
                                                      isNotRecent)
                                                  ? kPrimaryColor
                                                  : kSecondaryColor,
                                              size: 15.0,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              (searchResults[index]
                                                          .address
                                                          .substring(
                                                              0,
                                                              searchResults[
                                                                          index]
                                                                      .address
                                                                      .length -
                                                                  11)
                                                          .length >
                                                      34)
                                                  ? searchResults[index]
                                                      .address
                                                      .substring(0, 34)
                                                      .toUpperCase()
                                                  : searchResults[index]
                                                      .address
                                                      .substring(
                                                          0,
                                                          searchResults[index]
                                                                  .address
                                                                  .length -
                                                              11)
                                                      .toUpperCase(),
                                              style:
                                                  kCardNormalTextStyle.copyWith(
                                                fontSize: 18,
                                                color: (isSelected == index &&
                                                        isNotRecent)
                                                    ? kPrimaryColor
                                                    : kSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 1.0),
                                        child: Divider(
                                          color: kSecondaryColor,
                                          height: 5,
                                          thickness: 1.0,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// This function searches for destinations using Google Places API base on user input
  void searchPlaces(String searchTerm) async {
    var tempResults = await placeSearchService.getAutocomplete(searchTerm);
    searchResults = tempResults;
    setState(() {});
  }

  /// This is the widget that builds SelectFilters class which is also known as Filter Widget
  Widget buildBottomSheet(BuildContext context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SelectFilters(
            destination: destination,
            endUser: widget.endUser,
          ),
        ),
      );
}
