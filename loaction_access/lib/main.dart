import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getContactPermission();
    _getCurrentLoaction();
    
  }

  //location permission

  String locationMessage = "Current loaction of user ";
  late String lat;
  late String long;

  Future<Position> _getCurrentLoaction() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are Disabled......');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Loaction permission are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Loaction Permissions are permanently denied, we cannot request");
    }

    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
      setState(() {
        locationMessage = 'latitude ${lat}, ${long}';
        print("${lat},${long}");
      });
    });
  }

//contact permission

  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContact();

    } else {
      await Permission.contacts.request();
    }
  }

  void fetchContact() async{
      ContactsService.getContactsForPhone();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: Scaffold(
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                locationMessage,
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                  onPressed: () {
                    _getCurrentLoaction().then((value) {
                      lat = '${value.latitude}';
                      long = '${value.longitude}';

                      setState(() {
                        locationMessage = 'Latitude : $lat , Longitude :$long';
                      });
                      _liveLocation();
                    });
                  },
                  child: const Text('Get Currrent Loaction')),
                   ElevatedButton(
                  onPressed: () {
                    getContactPermission();
                  },
                  child: const Text('Get Contact Access')),
            ]),
          ),
        ));
  }
}
