import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'src/page.dart';
import 'package:location/location.dart';
import 'mapbox_search_flutter.dart' hide Location;

const ApiKey =
    'pk.eyJ1IjoibmlqZWZvNTU1MSIsImEiOiJja3EzbHgzZXExMDI5MndrMTdxdmR1Nm5kIn0.G4JDtJ1612Ofw7VTRkP8jA';

class FullMapPage extends ExamplePage {
  FullMapPage() : super(const Icon(Icons.map), 'Full screen map');

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return const FullMap();
  }
}

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMapController mapController;
  dynamic userlocate;
  dynamic camloc;
  Symbol _selectedSymbol;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getlocz();
  }

  getlocz() async {
    await userlocation();
    await Future.delayed(Duration(seconds: 3));
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(
        LatLng(userlocate.latitude, userlocate.longitude),
      ));
    }
  }

  setCords(cords) {
    print(cords);
    mapController.animateCamera(CameraUpdate.newLatLng(
      LatLng(cords[1], cords[0]),
    ));
  }

  userlocation() async {
    if (userlocate == null) {
      final location = Location();
      final hasPermissions = await location.hasPermission();
      if (hasPermissions != PermissionStatus.granted) {
        await location.requestPermission();
      }

      userlocate = await location.getLocation();
      setState(() {
        userlocate = userlocate;
      });
      // print([userlocate.latitude, userlocate.longitude]);
    }
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(
            iconSize: 0.07, iconRotate: 00.00, iconOpacity: 0.7),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    _updateSelectedSymbol(
      SymbolOptions(iconSize: 0.1, iconRotate: 25.00, iconOpacity: 1),
    );
  }

  void _updateSelectedSymbol(SymbolOptions changes) {
    mapController.updateSymbol(_selectedSymbol, changes);
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.onSymbolTapped.add(_onSymbolTapped);
  }

  void onUserLocationUpdated(UserLocation loc) {}
  void onCameraIdle() {
    if (camloc != mapController.cameraPosition.target) {
      setState(() {
        camloc = mapController.cameraPosition.target;
      });
      // print(camloc);
    }
  }

  @override
  void dispose() {
    if (mapController != null) {
      mapController.onSymbolTapped.remove(_onSymbolTapped);
      mapController.removeListener(_onMapChanged);
      mapController.dispose();
    }
    super.dispose();
  }

  void _onMapChanged() {}

  void _addMarker(Point<double> point, LatLng coordinates) {
    mapController.addSymbol(SymbolOptions(
      iconSize: 0.07,
      iconImage: 'hospital-svgrepo-com',
      geometry: LatLng(
        coordinates.latitude,
        coordinates.longitude,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: Text('Search'),
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                  setCords: setCords,
                ),
              ),
            );
          },
        ),
        appBar: AppBar(
          actions: mapController == null
              ? []
              : [
                  IconButton(
                      onPressed: () => {
                            mapController.animateCamera(CameraUpdate.newLatLng(
                              LatLng(userlocate.latitude, userlocate.longitude),
                            ))
                          },
                      icon: Icon(Icons.location_on))
                ],
          leading: BackButton(
            color: Colors.white,
            onPressed: mapController == null
                ? () {
                    Navigator.pop(context);
                  }
                : () {
                    mapController.clearSymbols();
                    mapController.removeListener(_onMapChanged);
                    Navigator.pop(context);
                  },
          ),
        ),
        body: MapboxMap(
          styleString: 'mapbox://styles/nijefo5551/ckq5c8x2t0m3317oi6jofjlpc',
          //map can be styled @ https://studio.mapbox.com/
          trackCameraPosition: true,
          onCameraIdle: onCameraIdle,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          onMapClick: _addMarker,
          // myLocationEnabled: true,
          // myLocationRenderMode: MyLocationRenderMode.GPS,
          // myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
          // compassEnabled: true,
          // annotationConsumeTapEvents: [AnnotationType.symbol],
          // onUserLocationUpdated: onUserLocationUpdated,
          minMaxZoomPreference: const MinMaxZoomPreference(13.0, 13.0),
          accessToken: ApiKey,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
              target: LatLng(
                  userlocate != null ? userlocate.latitude : 76.1608472,
                  userlocate != null ? userlocate.longitude : 9.9823428)),
          onStyleLoadedCallback: onStyleLoadedCallback,
        ));
  }

  void onStyleLoadedCallback() {}
}

class SearchPage extends StatelessWidget {
  final setCords;
  const SearchPage({Key key, this.setCords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: MapBoxPlaceSearchWidget(
          popOnSelect: true,
          apiKey: ApiKey,
          searchHint: 'Search around',
          onSelected: (place) {
            // print(place.geometry.coordinates);
            setCords(place.geometry.coordinates);
          },
          context: context,
        ),
      ),
    );
  }
}
