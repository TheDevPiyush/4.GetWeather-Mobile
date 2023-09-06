import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String location = "Loading...";
  double tempc = 0.0;
  String condition = "";
  double feelslike = 0.0;
  String title = "What's the weather?";
  final List<String> timeList = [];
  final List<String> tempcList = [];
  final List<String> coditionList = [];
  getPermission() async {
    await Geolocator.requestPermission();

    if (await Permission.location.isGranted) {
      Future.delayed(
        const Duration(seconds: 3),
        () {
          moveToHome();
        },
      );
    } else if (await Permission.location.isDenied ||
        await Permission.location.isRestricted) {
      showDialogue();
    }
  }

  showDialogue() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Denied'),
        content:
            const Text('Location permission is required.\nGrant in settings.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => {exit(0)},
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => {
              openAppSettings(),
              exit(0),
            },
            child: const Text('Open App Settings'),
          ),
        ],
      ),
    );
  }

  moveToHome() {
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Text(
            title,
            style: const TextStyle(
              decoration: TextDecoration.none,
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "By TheDevPiyush",
          style: TextStyle(
            decoration: TextDecoration.none,
            color: Color.fromARGB(255, 133, 133, 133),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
