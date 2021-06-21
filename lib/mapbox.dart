import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'src/page.dart';
import 'package:location/location.dart';
import 'mapbox_search_flutter.dart' hide Location;
import 'package:http/http.dart' as http;
import 'src/maputils.dart';

class FullMapPage extends ExamplePage {
  FullMapPage() : super(const Icon(Icons.map), 'Vaccine Map');

  @override
  Widget build(BuildContext context) {
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
  dynamic centers;

  Future userlocation() async {
    if (userlocate == null) {
      final location = Location();
      final hasPermissions = await location.hasPermission();
      if (hasPermissions != PermissionStatus.granted) {
        await location.requestPermission();
      }

      userlocate = await location.getLocation();
      await Future.delayed(Duration(seconds: 1));
      if (mapController != null) {
        await animateLoc(userlocate, mapController, 0);
      }
      setState(() {
        userlocate = userlocate;
      });
      await fetchCentersByLatLng(userlocate);
    }
  }

  void _onSymbolTapped(Symbol symbol) async {
    if (_selectedSymbol != null) {
      updateSelectedSymbol(
          SymbolOptions(iconSize: 0.07, iconRotate: 00.00, iconOpacity: 0.7),
          mapController,
          _selectedSymbol);
    }
    setState(() {
      _selectedSymbol = symbol;
    });

    updateSelectedSymbol(
        SymbolOptions(iconSize: 0.1, iconRotate: 00.00, iconOpacity: 1),
        mapController,
        _selectedSymbol);

    await animateLoc(symbol.options.geometry, mapController, 0);
  }

  void _onMapCreated(MapboxMapController controller) async {
    mapController = controller;
    mapController.onSymbolTapped.add(_onSymbolTapped);
    await userlocation();
  }

  void onCameraIdle() async {
    var campos = mapController.cameraPosition.target;
    if (camloc != campos) {
      double distance = camloc != null
          ? calculateDistance(camloc.latitude, camloc.longitude,
              campos.latitude, campos.longitude)
          : 0.0;

      print(distance);
      setState(() {
        camloc = mapController.cameraPosition.target;
      });

      if (distance > 5) {
        await fetchCentersByLatLng(camloc);
      }
    }
  }

  Future fetchCentersByLatLng(latlng) async {
    final response = await http.get(Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/appointment/centers/public/findByLatLong?lat=' +
            latlng.latitude.toString() +
            '&' +
            'long=' +
            latlng.longitude.toString()));

    final responseJson = await jsonDecode(response.body);

    setState(() {
      centers = responseJson['centers'] as List ?? [];
    });

    await markerLoop(centers);

    addMarker(symbolz, mapController);

    return responseJson ?? [];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (mapController != null) {
      mapController.symbols.removeAll(mapController.symbols); //mistake fixed
      mapController.removeListener(onMapChanged);
      mapController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: Text('Search'),
          icon: Icon(Icons.search),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                  setCords: setCords,
                  cntrl: mapController,
                ),
              ),
            );
          },
        ),
        appBar: AppBar(
          title: Text('Vaccine Map'),
          centerTitle: true,
          actions: mapController == null
              ? []
              : [
                  IconButton(
                      onPressed: userlocate == null
                          ? null
                          : () => {
                                mapController
                                    .animateCamera(CameraUpdate.newLatLng(
                                  LatLng(userlocate.latitude,
                                      userlocate.longitude),
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
                    mapController.removeListener(onMapChanged);
                    Navigator.pop(context);
                  },
          ),
        ),
        body: MapboxMap(
          styleString:
              'mapbox://styles/nijefo5551/ckq5c8x2t0m3317oi6jofjlpc', //map can be styled @ https://studio.mapbox.com/
          trackCameraPosition: true,
          onCameraIdle: onCameraIdle,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: false,
          minMaxZoomPreference: const MinMaxZoomPreference(13.0, 17.0),
          accessToken: ApiKey,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
              target: LatLng(
                  userlocate != null ? userlocate.latitude : 76.1608472,
                  userlocate != null ? userlocate.longitude : 9.9823428)),
          onStyleLoadedCallback: onStyleLoadedCallback,
        ));
  }
}

class SearchPage extends StatelessWidget {
  final setCords;
  final cntrl;
  const SearchPage({Key key, this.setCords, this.cntrl}) : super(key: key);

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
            setCords(place.geometry.coordinates, cntrl);
          },
          context: context,
        ),
      ),
    );
  }
}
