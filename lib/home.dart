import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class HomePageWidget extends StatefulWidget {
  final data;

  HomePageWidget({Key key, this.data}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

Future<List> fetchVaccine(http.Client client, args) async {
  dynamic urlz = args["type"] == 'pincode'
      ? 'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?date=' +
          args["date"] +
          '&pincode=' +
          args["pincode"].toString()
      : 'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?date=' +
          args["date"] +
          '&district_id=' +
          args["district_id"].toString();

  final response = await client.get(Uri.parse(urlz));

// Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseVaccines, response.body);
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic vaccinez;
  @override
  void initState() {
    super.initState();
    vaccinez = fetchVaccine;

    // DateTime datenow = DateTime.now();
    //   while (datenow.hour > 18 && datenow.hour < 23) {
    //     await Future.delayed(Duration(milliseconds: 500));
    //     fetchVaccine(http.Client());
    //   }
  }

// A function that converts a response body into a List<Photo>.

  @override
  Widget build(BuildContext context) {
    dynamic args = ModalRoute.of(context).settings.arguments;
    // print(args);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: vaccinez(http.Client(), args),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? VaccineList(vaccine: snapshot.data)
                : Center(child: Text('No Vaccines'));
          },
        ),
      ),
    );
  }
}

class VaccineList extends StatelessWidget {
  final List vaccine;

  VaccineList({Key key, this.vaccine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: <Widget>[
      ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          // setState(() {
          //   _data[index].isExpanded = !isExpanded;
          // });
        },
        children: vaccine.map<ExpansionPanel>((item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.address),
                trailing: Text(item.vaccine),
              );
            },
            body: ListTile(
                leading: Text(
                    item.feetype + ' ' + item.minagelimit.toString() + '+'),
                trailing: Text(item.availablecapacity.toString() +
                    ' (' +
                    item.availablecapacitydose1.toString() +
                    '/' +
                    item.availablecapacitydose2.toString() +
                    ')'),
                title: Text(item.date + ' | ' + item.from),
                subtitle: Text(item.misc),
                onTap: () {}),
            isExpanded: true,
          );
        }).toList(),
      )
    ]);
  }
}
