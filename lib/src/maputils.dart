import 'dart:math';

import 'package:mapbox_gl/mapbox_gl.dart';

const ApiKey =
    'pk.eyJ1IjoibmlqZWZvNTU1MSIsImEiOiJja3EzbHgzZXExMDI5MndrMTdxdmR1Nm5kIn0.G4JDtJ1612Ofw7VTRkP8jA';

List<SymbolOptions> symbolz = [];

Future setCords(cords, mapController) async {
  await animateLoc(cords, mapController, 1);
}

Future animateLoc(cords, ctrl, type) async {
  type == 1
      ? await ctrl.animateCamera(CameraUpdate.newLatLng(
          LatLng(cords[1], cords[0]),
        ))
      : await ctrl.animateCamera(CameraUpdate.newLatLng(
          LatLng(cords.latitude, cords.longitude),
        ));
}

void onMapChanged() async {}

void addMarker(symbols, ctrl) async {
  ctrl.addSymbols(symbols);
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

void updateSelectedSymbol(SymbolOptions changes, ctrl, _selectedSymbol) async {
  await ctrl.updateSymbol(_selectedSymbol, changes);
}

void onUserLocationUpdated(UserLocation loc) async {}
void onStyleLoadedCallback() {}

Future markerLoop(centers) async {
  await for (var center in centers) {
    symbolz.add(SymbolOptions(
      iconSize: 0.07,
      iconOpacity: 0.5,
      iconImage: 'hospital-svgrepo-com',
      geometry: LatLng(
        num.parse(center['lat']).toDouble(),
        num.parse(center['long']).toDouble(),
      ),
    ));
  }
  return [];
}
