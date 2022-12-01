import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Google Map Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  final LatLng suratCoord = const LatLng(21.1, 72.831062); // city latlng

  _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    // mapController.setMapStyle(value);
  }

  _focusOnCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(position.latitude, position.longitude),
        zoom: 17.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        markers: <Marker>{
          Marker(
            markerId: MarkerId("surat"),
            position: suratCoord,
            infoWindow: InfoWindow(title: 'Surat City'),
          ),
          Marker(
              markerId: MarkerId("surat-90"),
              position: suratCoord,
              infoWindow: InfoWindow(title: 'Surat City 90 degree'),
              rotation: 90),
        },
        circles: <Circle>{
          Circle(
            circleId: CircleId('2'),
            consumeTapEvents: true,
            strokeColor: Colors.teal,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeWidth: 2,
            center: suratCoord,
            radius: 6000,
          ),
        },
        onMapCreated: _onMapCreated,
        trafficEnabled: true,
        // mapType: MapType.satellite,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: suratCoord,
          zoom: 11.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _focusOnCurrentLocation,
        child: Icon(Icons.location_city),
      ),
    );
  }
}
