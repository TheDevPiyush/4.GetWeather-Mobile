import 'package:flutter/material.dart';
import 'package:what_is_the_weather/screens/home_screen.dart';
import 'package:what_is_the_weather/screens/splash_screen.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      // fontFamily: "Inconsolata_Condensed",
    ),
    routes: {
      "/": (context) => const SplashScreen(),
      "/home": (context) => const HomeScreen(),
    },
  ));
}
