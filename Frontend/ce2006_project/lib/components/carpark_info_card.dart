import 'package:ce2006_project/components/custom_material_button.dart';
import 'package:ce2006_project/components/custom_rounded_bars.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/models/carpark.dart';
import 'package:ce2006_project/widget/select_carpark.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

/// This is the CarparkInfoCard class used in Trip Page
/// Attributes:
/// carpark - a specific carpark
/// endUser - current user
/// dataUnavailable - if prediction data is unavailable
/// bookmark - if carpark is bookmarked
class CarparkInfoCard extends StatefulWidget {
  final Carpark carpark;
  final AppUser endUser;

  const CarparkInfoCard({
    Key? key,
    required this.carpark,
    required this.endUser,
  }) : super(key: key);

  @override
  _CarparkInfoCardState createState() => _CarparkInfoCardState();
}

class _CarparkInfoCardState extends State<CarparkInfoCard> {
  bool dataUnavailable = false;
  bool bookmark = false;

  @override
  Widget build(BuildContext context) {
    checkBookmarkStatus();

    Color kPrimaryColor = kLightColor;
    Color kSecondaryColor = kDarkColor;

    return Container(
      width: 5 * MediaQuery.of(context).size.width / 6,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: kSecondaryColor,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
        color: kPrimaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.carpark.id,
                style: kCardBoldTextStyle.copyWith(
                  color: kSecondaryColor,
                  fontSize: 18.0,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Icon(
                  bookmark ? Icons.bookmark : Icons.bookmark_border,
                  color: kSecondaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
          Text(
            widget.carpark.location.address,
            style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
          ),
          Text(
            'Free Parking: ' + widget.carpark.information.freeParking,
            style: kCardNormalTextStyle.copyWith(
                color: kSecondaryColor, fontSize: 13.0),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Parking Rate: \$' + widget.carpark.rate.toStringAsFixed(2),
                style: kCardItalicsTextStyle.copyWith(color: kSecondaryColor),
              ),
              Text(
                'Distance: ' +
                    widget.carpark.distance.toStringAsFixed(2) +
                    'km',
                style: kCardItalicsTextStyle.copyWith(color: kSecondaryColor),
              ),
            ],
          ),
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: CustomRoundedBars(
              _createData(),
              animate: true,
              dataUnavailable: dataUnavailable,
              maxVal: widget.carpark.totalLots,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                0.17 * MediaQuery.of(context).size.width, 20, 0, 0),
            child: CustomMaterialButton(
              function: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: buildBottomSheet,
                );
              },
              text: 'SELECT CARPARK',
              kPrimaryColor: kPrimaryColor,
              kSecondaryColor: kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// This is the widget that builds SelectCarpark class which is also known as Carpark Widget
  Widget buildBottomSheet(BuildContext context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SelectCarpark(
            carpark: widget.carpark,
            endUser: widget.endUser,
            infoView: true,
          ),
        ),
      );

  /// This function checks if carpark is bookmarked by user previously
  void checkBookmarkStatus() {
    for (String addr in widget.endUser.bookmarks) {
      if (addr == widget.carpark.location.address) {
        bookmark = true;
        break;
      }
    }
  }

  /// This function sets the bookmark status of a carpark
  void setBookmarkStatus() {
    setState(() {
      bookmark = !bookmark;
    });
    if (bookmark) {
      widget.endUser.bookmarks.insert(0, widget.carpark.location.address);
    } else {
      widget.endUser.bookmarks.remove(widget.carpark.location.address);
    }
  }

  /// This function creates data for generating barchart
  List<charts.Series<CrowdTimings, String>> _createData() {
    final data = List.generate(
      widget.carpark.predictions.length,
      (index) => CrowdTimings(
          widget.carpark.predictions[index]['time'],
          (widget.carpark.predictions[index]['lot_count'] == -1)
              ? 0
              : widget.carpark.predictions[index]['lot_count']),
    );

    if (data.every((element) => element.lotCount == 0)) {
      dataUnavailable = true;
    }

    return [
      charts.Series<CrowdTimings, String>(
        id: 'Lot Availability',
        colorFn: (CrowdTimings c, _) => (c.lotCount != 0)
            ? charts.ColorUtil.fromDartColor(kDarkColor)
            : charts.ColorUtil.fromDartColor(Colors.red),
        domainFn: (CrowdTimings times, _) => times.time,
        measureFn: (CrowdTimings times, _) => times.lotCount,
        data: data,
      )
    ];
  }
}

/// This is the CrowdTiming class used in barchart
/// Attributes:
/// time - time of carpark lot count
/// lotCount - count of carpark lot
class CrowdTimings {
  final String time;
  final int lotCount;

  CrowdTimings(this.time, this.lotCount);
}
