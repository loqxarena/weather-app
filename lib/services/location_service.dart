import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if the physical GPS chip is turned on in the phone's settings
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS is turned off. Please enable location services.');
    }

    // 2. Check the app's current permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 3. Ask the user for permission via an OS pop-up
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions were denied. Cannot fetch local weather.');
      }
    }
    
    // 4. If they permanently blocked the app in settings
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
    } 

    // 5. If we survived all those checks, actually grab the coordinates
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // WeatherAPI accepts coordinates perfectly in a "lat,lon" format
    return '${position.latitude},${position.longitude}';
  }
}