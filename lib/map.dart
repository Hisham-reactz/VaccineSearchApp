import 'package:mapbox_search/mapbox_search.dart';
import 'package:flutter/material.dart' hide Color;
import 'mapbox_search_flutter.dart';
import 'src/clr.dart';

// static map image plugin to be replaced with mapbox_gl

const kApiKey =
    'pk.eyJ1IjoibmlqZWZvNTU1MSIsImEiOiJja3EzbHgzZXExMDI5MndrMTdxdmR1Nm5kIn0.G4JDtJ1612Ofw7VTRkP8jA';

class MapBox extends StatefulWidget {
  MapBox({Key key}) : super(key: key);

  _MapBoxState createState() => _MapBoxState();
}

class _MapBoxState extends State<MapBox> {
  StaticImage staticImage = StaticImage(apiKey: kApiKey);
  List<double> coordinatez = [76.236767, 9.986331];

  setCords(cords) {
    setState(() {
      coordinatez = cords;
    });
    // print(cords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MapBox Api Example'),
      ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Image.network(
              getStaticImageWithMarker(),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  final MapBoxMarker _defaultMarker = MapBoxMarker(
      markerColor: RgabColor(0, 0, 0).toRgbColor(),
      markerLetter: 'q',
      markerSize: MarkerSize.SMALL);
  String getStaticImageWithMarker() => staticImage.getStaticUrlWithPolyline(
        center: Location(lat: coordinatez[1], lng: coordinatez[0]),
        point1: Location(lat: coordinatez[1], lng: coordinatez[0]),
        point2: Location(lat: coordinatez[1], lng: coordinatez[0]),
        marker1: _defaultMarker,
        marker2: _defaultMarker,
        height: 300,
        width: MediaQuery.of(context).size.width.toInt(),
        zoomLevel: 9,
        style: MapBoxStyle.Satellite_Street_V11,
        render2x: true,
      );
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
          apiKey: kApiKey,
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
