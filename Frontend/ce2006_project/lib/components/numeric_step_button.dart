import 'package:ce2006_project/constants.dart';
import 'package:flutter/material.dart';

/// This is the NumericStepButton class used in SelectCarpark widget
/// Attributes:
/// minValue - minimum value of counter
/// maxValue - maximum value of counter
/// kPrimaryColor - primary color
/// kSecondaryColor - secondary color
/// counter - current count
class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  final ValueChanged<int> onChanged;

  const NumericStepButton({
    Key? key,
    this.minValue = 0,
    this.maxValue = 10,
    required this.onChanged,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.remove,
            color: widget.kSecondaryColor,
          ),
          iconSize: 15.0,
          color: widget.kPrimaryColor,
          onPressed: () {
            subtractCounter();
          },
        ),
        Text(
          '$counter',
          textAlign: TextAlign.center,
          style: kCardNormalTextStyle.copyWith(color: widget.kSecondaryColor),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.add,
            color: widget.kSecondaryColor,
          ),
          iconSize: 15.0,
          color: widget.kPrimaryColor,
          onPressed: () {
            addCounter();
          },
        ),
      ],
    );
  }

  /// This function subtracts counter
  void subtractCounter() {
    setState(() {
      if (counter > widget.minValue) {
        counter--;
      }
      widget.onChanged(counter);
    });
  }

  /// This function adds counter
  void addCounter() {
    setState(() {
      if (counter < widget.maxValue) {
        counter++;
      }
      widget.onChanged(counter);
    });
  }
}
