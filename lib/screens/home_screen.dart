import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map getDataFromSplashScreen = {};
  String imageAsset = "";
  double opacity = 0;
  int bluropacity = 0;
  double blurintencity = 0;
  bool isOpened = false;

  String location = "--";
  dynamic tempc = "";
  String condition = "";
  String dayDate = "";
  String inputValue = "";
  dynamic feelslike = "";

  final List<String> timeList = [];
  final List<String> tempcList = [];
  final List<String> conditionList = [];

  dynamic lat;
  dynamic lon;
  bool loading = false;
  String loadingText = "Loading..";

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    getMyLocationWeather();
  }

  getMyLocationWeather() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      Position pos = await Geolocator.getCurrentPosition();
      lat = pos.latitude.toString();
      lon = pos.longitude.toString();
      setState(() {
        inputValue = "$lat,$lon";
      });
      getWeather();
    } else {
      noInternetAlert();
    }
  }

  getWeather() async {
    try {
      setState(() {
        timeList.clear();
        tempcList.clear();
        conditionList.clear();
        location = "--";
        condition = "";
        tempc = "";
        feelslike = "";
      });
      Response response = await get(
          Uri.parse(
              "https://weatherapi-com.p.rapidapi.com/forecast.json?q=$inputValue&days=3"),
          headers: {
            'X-RapidAPI-Key':
                'YOUR_API_KEY',
            'X-RapidAPI-Host': 'weatherapi-com.p.rapidapi.com',
          });

      Map data = jsonDecode(response.body);
      setState(() {
        location = data["location"]["name"];
        tempc = data["current"]["temp_c"].toString();
        condition = data["current"]["condition"]["text"];
        feelslike = data["current"]["feelslike_c"].toString();

        final hourDetails = data["forecast"]["forecastday"][0]["hour"];
        dayDate = data["forecast"]["forecastday"][0]["date"];
        if (hourDetails is List) {
          for (var i = 0; i < hourDetails.length; i++) {
            final timeDetail = hourDetails[i]['time'].toString();
            final tempDetail = hourDetails[i]['temp_c'].toString();
            final conditionDetail = hourDetails[i]['condition']["text"];
            timeList.add(timeDetail.substring(11, 16));
            tempcList.add(tempDetail);
            conditionList.add(conditionDetail);
          }
        }
      });

      if (condition == "Moderate or heavy rain with thunder" ||
          condition == "Heavy snow" ||
          condition == "Moderate or heavy rain" ||
          condition == "Moderate or heavy rain shower") {
        setState(() {
          imageAsset = "thunder.gif";
          opacity = 0.25;
          bluropacity = 22;
          blurintencity = 30;
        });
      } else if (condition == "Clear" || condition == "Sunny") {
        setState(() {
          imageAsset = "sunny.jpg";
          opacity = 0.25;
          bluropacity = 60;
          blurintencity = 40;
        });
      } else if (condition == "Mist" ||
          condition == "Light rain" ||
          condition == "Light snow" ||
          condition == "Light rain shower") {
        setState(() {
          imageAsset = "rain.gif";
          opacity = 0.35;
          bluropacity = 22;
          blurintencity = 20;
        });
      } else if (condition == "Partly cloudy" || condition == "Cloudy") {
        setState(() {
          imageAsset = "cloudy.jpg";
          opacity = 0.1;
          bluropacity = 2;
          blurintencity = 30;
        });
      } else {
        setState(() {
          imageAsset = "sunny.jpg";
          opacity = 0.3;
          bluropacity = 50;
          blurintencity = 30;
        });
      }

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          loading = false;
        });
      });
    } catch (e) {
      notFoundAlert();
    }
  }

  noInternetAlert() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Not Found'),
        content: const Text(
            'Make sure you are connected to internet and that your location services are on.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, "Ok"),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  notFoundAlert() {
    getMyLocationWeather();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Not Available'),
        content: const Text('Requested location was not found.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, "Ok"),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
          body: !loading
              ? Container(
                  height: height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/$imageAsset"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          const Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(opacity),
                          BlendMode.darken,
                        )),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 15,
                          ),
                          child: InkWell(
                            onTap: () => {
                              setState(() {
                                if (isOpened) {
                                  isOpened = false;
                                } else {
                                  isOpened = true;
                                }
                              })
                            },
                            child: Container(
                              width: width,
                              color: Colors.transparent,
                              child: BlurryContainer(
                                color:
                                    Color.fromARGB(bluropacity, 255, 255, 255),
                                blur: blurintencity,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    isOpened
                                        ? Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                15,
                                                0,
                                                0,
                                                0,
                                              ),
                                              child: TextField(
                                                maxLines: null,
                                                onChanged: (value) => {
                                                  setState(() {
                                                    inputValue = value;
                                                  })
                                                },
                                                onSubmitted: (value) {
                                                  getWeather();
                                                  setState(() {
                                                    isOpened = false;
                                                  });
                                                },
                                                autofocus: true,
                                                textInputAction:
                                                    TextInputAction.search,
                                                decoration:
                                                    const InputDecoration(
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.transparent,
                                                    ),
                                                  ),
                                                  hintText: "Search location",
                                                  hintStyle: TextStyle(
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 216, 216, 216),
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                15, 0, 0, 0),
                                            child: Text(
                                              "What's the weather?",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                    // ignore: avoid_unnecessary_containers
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isOpened) {
                                                  isOpened = false;
                                                } else {
                                                  isOpened = true;
                                                }
                                              });
                                            },
                                            icon: isOpened
                                                ? const Icon(Icons.search_off)
                                                : const Icon(Icons.search),
                                            color: Colors.white,
                                            iconSize: 20,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              getMyLocationWeather();
                                            },
                                            icon: const Icon(Icons.pin_drop),
                                            color: Colors.white,
                                            iconSize: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: BlurryContainer(
                            color: Color.fromARGB(bluropacity, 255, 255, 255),
                            blur: blurintencity,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            location,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 40,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              0,
                                              0,
                                            ),
                                            child: Text(
                                              tempc == ""
                                                  ? ""
                                                  : '${tempc.toString()}°',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 40,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 0,
                                              horizontal: 15,
                                            ),
                                            child: Text(
                                              condition,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            feelslike == ""
                                                ? ""
                                                : "Feels like $feelslike°",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "24 Hour Forecast for today ($dayDate)",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            alignment: Alignment.center,
                            height: height * 0.25,
                            child: BlurryContainer(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              blur: blurintencity,
                              color: Color.fromARGB(bluropacity, 255, 255, 255),
                              child: ListView.builder(
                                itemCount: tempcList.length,
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 5,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${timeList[index].toString()} ",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        Text(
                                          "${tempcList[index].toString()}° ",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 23,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        Text(
                                          "${conditionList[index].toString()} ",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: Colors.black,
                  width: width,
                  height: height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SpinKitFadingCube(
                        color: Colors.white,
                        size: 70.0,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        loadingText,
                        style: const TextStyle(
                            decoration: TextDecoration.none,
                            color: Color.fromARGB(255, 197, 197, 197),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )),
    );
  }
}
