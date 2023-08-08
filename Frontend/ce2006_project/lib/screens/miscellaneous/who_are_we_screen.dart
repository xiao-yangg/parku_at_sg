import 'package:ce2006_project/constants.dart';
import 'package:flutter/material.dart';

/// This is the WhoAreWeScreen class also known as Who Are We Page
/// Attributes:
/// kPrimaryColor - primary color
/// kSecondaryColor - secondary color
class WhoAreWeScreen extends StatelessWidget {
  final Color kPrimaryColor;
  final Color kSecondaryColor;

  const WhoAreWeScreen({
    Key? key,
    required this.kPrimaryColor,
    required this.kSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: kSecondaryColor,
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Text(
          'WHO ARE WE?',
          style: kAppTitleStyle.copyWith(fontSize: 20, color: kSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _kAboutUsDescription,
            style: kCardNormalTextStyle.copyWith(color: kSecondaryColor),
          ),
        ),
      ),
    );
  }
}

/// This is the developer's description
const _kAboutUsDescription = """
Hi,
      
        We are Future Employees, a gang of degen NTU SCSE Computer Engineering undergraduates.
        
        Proudly presenting our AY21/22 Sem 2 CE2006 Software Engineering lab project!
        
        ParkU@SG seeks to inspire generations of vehicle owners to enjoy their little road trip, with informative and user-friendly guidance.
        
        Through ParkU@SG, we hope to bring about convenience and joy to the mobility of its users.
        
        All in all, DOWNLOAD OUR APP NOW!
        
        
        
Powered with ❤,
Future Employees
""";
