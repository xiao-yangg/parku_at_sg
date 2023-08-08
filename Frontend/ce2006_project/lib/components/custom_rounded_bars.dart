import 'package:ce2006_project/constants.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

/// This is the CustomRoundedBars class used in CarparkInfoCard
/// Attributes:
/// seriesList - data in series list
/// animate - to animate barchart
/// dataUnavailable - if data is unavailable
/// maxVal - max value in y-axis
class CustomRoundedBars extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;
  final bool dataUnavailable;
  final int maxVal;

  const CustomRoundedBars(
    this.seriesList, {
    Key? key,
    required this.animate,
    required this.dataUnavailable,
    required this.maxVal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        charts.BarChart(
          seriesList,
          animate: animate,

          // It is important when using both primary and secondary axes to choose
          // the same number of ticks for both sides to get the gridlines to line
          // up.
          // Previous primaryMeasureAxis - charts.BasicNumericTickProviderSpec(desiredTickCount: 4)
          primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec: StaticNumericTickProviderSpec(
              <TickSpec<num>>[
                const TickSpec<num>(0),
                TickSpec<num>((0.5 * maxVal).ceil()),
                TickSpec<num>(maxVal),
              ],
            ),
          ),

          defaultRenderer: charts.BarRendererConfig(
              // By default, bar renderer will draw rounded bars with a constant
              // radius of 100.
              // To not have any rounded corners, use [NoCornerStrategy]
              // To change the radius of the bars, use [ConstCornerStrategy]
              cornerStrategy: const charts.ConstCornerStrategy(30)),
        ),
        if (dataUnavailable)
          Center(
            child: Text(
              'Data Unavailable',
              style: kCardNormalTextStyle.copyWith(color: kDarkColor),
            ),
          ),
      ],
    );
  }
}
