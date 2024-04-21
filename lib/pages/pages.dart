import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/material.dart'; // Import Flutter's material library for GestureDetector
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:battleship_lahacks/utils/config.dart';
import 'package:fl_chart/fl_chart.dart';

double crosshairSize = 125;
//double AOE_Radius = 50;

bool targeting = false;
LatLng? targetPosition;



class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  late TextEditingController _textController;
  late CupertinoTabController _tabController;
  int _selectedIndex = 0; // Store the index of the selected tab

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _tabController = CupertinoTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        height: 60,
        activeColor: Colors.white,
        inactiveColor: Colors.white60,
        backgroundColor: Colors.black87, // Change the color here
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.text_bubble_fill),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_solid),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Update the selected index when tab is tapped
          });
        },
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return _buildPage(index); // Call a separate method to build the page
          },
        );
      },
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return MapPage(); // Return the MapPage widget when index is 0
      case 1:
        return ChatPage(); // Return the ChatPage widget when index is 1
      case 2:
        return ProfilePage(); // Return the ProfilePage widget when index is 2
      default:
        return Container(); // Return an empty container for unknown indexes
    }
  }
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMapController? mapController;
  Location location = Location();
  LocationData? currentPosition;

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  Future<void> getUserLocation() async {
    location.enableBackgroundMode(enable: true);
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // Show an alert if location service is not enabled
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // Show an alert if location permission is not granted
        return;
      }
    }
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        currentPosition = currentLocation;
      });
    });
  }

  void _onMapClick(point, latLng) {
    targetPosition=latLng;
    print(targetPosition!.latitude);
    mapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          latLng.latitude,
          latLng.longitude,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Map",
      //     style: TextStyle(
      //       fontSize: 30,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //       inherit: false,
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          MapboxMap(
            accessToken: 'YOUR_ACCESS_TOKEN',
            onMapClick: (point, latlng) => _onMapClick(point, latlng),
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(34.412278, -119.847787),
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            dragEnabled: true,
          ),
          Positioned(
            bottom: 675,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    mapController!.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(
                          currentPosition!.latitude!,
                          currentPosition!.longitude!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Icon(
                      Icons.center_focus_strong,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: 740), // Empty container to create offset
                GestureDetector(
                  onTap: () {
                    setState(() {
                      targeting = true;
                    });
                    // Open weapons menu
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Icon(
                      Icons.rocket,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: targeting ? // Check if targeting is true
            Image.asset(
              "images/Crosshair.png",
              width: crosshairSize, // Set the width to match the image size
              height: crosshairSize, // Set the height to match the image size
            ) : // If targeting is false, don't display the image
            SizedBox(), // Use SizedBox to occupy the space without displaying anything
          ),
          SizedBox(
            height: 720,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    targeting = false;
                  });
                },
                child: targeting
                    ? Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Image.asset(
                    "images/Launch.png",
                    width: 50,
                    height: 50,
                  ),
                )
                    : SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black, // Set background color to white
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        middle: Text('Chat',
          style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          inherit: false,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 63, right: 8.0, left: 8.0), // Adjusted padding
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('Chat Page'),
              ),
            ),
            CupertinoTextField(
              cursorOpacityAnimates: true,
              //padding: ,
              placeholder: 'Type your message here',
              style: TextStyle(color: Colors.white), // Change text color to white
              decoration: BoxDecoration(
                color: Colors.black, // Set background color to white
                border: Border.all(
                  color: Colors.white38, // Set border color to black
                  width: 1.0, // Set border width
                ),
                borderRadius: BorderRadius.circular(15.0), // Optional: Set border radius
              ),
              //padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjusted padding
              onSubmitted: (_) {
                // Handle message submission
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
          alignment: Alignment.center,
          child: Text(
            'Activity',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              inherit: false,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                  height: 200, // Adjust the height of the rectangles as needed
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.18),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: double.infinity, // Ensure the graph takes full width of the container
                      height: 150, // Adjust the height of the graph as needed
                      child: LineChart(
                        sampleData1(), // Use the example data method here
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

LineChartData sampleData1() {
  return LineChartData(
    gridData: FlGridData(show: false),
    titlesData: FlTitlesData(show: false),
    borderData: FlBorderData(show: false),
    minX: 0,
    maxX: 6,
    minY: 0,
    maxY: 10,
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 3),
          FlSpot(1, 4),
          FlSpot(2, 3.5),
          FlSpot(3, 5),
          FlSpot(4, 4.5),
          FlSpot(5, 6),
          FlSpot(6, 8),
        ],
        isCurved: true,
        //colors: [Colors.blue],
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
      ),
    ],
  );
}

//Calorie/hr
//locations visited