import 'package:avatar_glow/avatar_glow.dart';
import 'package:ce2006_project/constants.dart';
import 'package:ce2006_project/models/app_user.dart';
import 'package:ce2006_project/screens/mains/destination_screen.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// This is the AccountTab class also known as Account Page
/// Attributes:
/// endUser - current user
/// _words - display words spoken by user and recognized by voice recognition
/// _confidence - confidence of correct word recognized
class SpeechToTextDialog extends StatefulWidget {
  final AppUser endUser;

  const SpeechToTextDialog({
    Key? key,
    required this.endUser,
  }) : super(key: key);

  @override
  _SpeechToTextDialogState createState() => _SpeechToTextDialogState();
}

class _SpeechToTextDialogState extends State<SpeechToTextDialog> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _words = '';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 150.0, horizontal: 30.0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          color: kLightColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(
              'Press button and speak',
              style: kCardItalicsTextStyle.copyWith(
                  color: kDarkColor, fontSize: 20.0),
            ),
            SingleChildScrollView(
              reverse: true,
              child: Text(
                _words,
                style: kCardNormalTextStyle.copyWith(
                    color: kDarkColor, fontSize: 20.0),
              ),
            ),
            Column(
              children: [
                Text(
                  'Confidence: ' + (_confidence * 100).toStringAsFixed(2) + '%',
                  style: kCardItalicsTextStyle.copyWith(
                      color: kDarkColor, fontSize: 20.0),
                ),
                AvatarGlow(
                  animate: _isListening,
                  glowColor: kDarkColor,
                  endRadius: 75.0,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: MaterialButton(
                    shape: const CircleBorder(),
                    color: kDarkColor,
                    padding: const EdgeInsets.all(15),
                    onPressed: () {
                      _listen();
                    },
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: kLightColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back',
                    style: kCardItalicsTextStyle.copyWith(
                        color: kDarkColor, fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// This function is used for initialize voice recognition
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onState: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => _onSpeechResult(val));
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    }
  }

  /// This function is used for showing result from voice detection
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _words = result.recognizedWords;
      print(_words);
    });

    if (result.hasConfidenceRating && result.confidence > 0) {
      _confidence = result.confidence;
    }

    // direct to Destination Page
    if (_words.contains('go to')) {
      Future.delayed(const Duration(milliseconds: 3500), () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DestinationScreen(
              endUser: widget.endUser,
              initialSearch: _words.substring(6, _words.length),
            ),
          ),
        );
      });
    }
  }
}
