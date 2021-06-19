import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'support.dart';
import 'calendar.dart';
import 'map.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'api.dart';
import 'notification.dart';
import 'package:intl/intl.dart';

dynamic curstate;
Future<List> fetchStates(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/states'));

// Use the compute function to run parsePhotos in a separate isolate.

  return compute(parseStates, response.body);
}

Future<List> fetchDist(http.Client client, num id) async {
// print(id);
  final response = await client.get(Uri.parse(
      'https://cdn-api.co-vin.in/api/v2/admin/location/districts/' +
          id.toString()));

// Use the compute function to run parsePhotos in a separate isolate.
// print(response.body);

  return compute(parseDistricts, response.body);
}

getSnack(msg, context) {
  final snackBar = SnackBar(content: Text(msg));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> _alertReg(__context) async {
  await getLocalPin();
  if (pincode == null)
    switch (await showDialog<dynamic>(
        context: __context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(
              'Register pincode based vaccine alert',
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(13),
                child: TextField(
                  onSubmitted: (pinz) async {
                    if (pinz.trim() != '' && pinz.trim().length == 6) {
                      await setLocalPin(num.parse(pinz).toInt());
                      Navigator.pop(context);
                      getSnack('Vaccine alert registered @ ' + pinz, context);
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    labelText: 'PinCode',
                  ),
                ),
              )
            ],
          );
        })) {
      case null:
// dialog dismissed
        break;
    }
}

class _RegisterPageWidgetState extends State<RegisterPageWidget> {
  bool isInit = false;
  Timer tmr;
  @override
  void initState() {
    super.initState();

    tmr = Timer.periodic(new Duration(seconds: 5), (timer) {
      setState(() {
        isInit = !isInit;
      });
    });

    _alertReg(context);
  }

  @override
  void dispose() {
    super.dispose();
    tmr.cancel();
  }

  final _formKey = GlobalKey<FormBuilderState>();
  DateTime datenow = DateTime.now();
  dynamic curstate;
  dynamic curdist;
  dynamic curdate;
  String today = DateFormat('MMM-dd-yyyy – hh:mm a')
      .format(DateTime.now().toLocal())
      .toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          elevation: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: ClipPath(
                  child: Container(
                    child: Center(
                        child: AnimatedDefaultTextStyle(
                            style: isInit
                                ? TextStyle(
                                    fontSize: 37.0,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w300)
                                : TextStyle(
                                    fontSize: 27.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w100),
                            duration: const Duration(seconds: 4),
                            child:
                                isInit ? Text("Corona Go") : Text("Go Corona"),
                            curve: Curves.elasticInOut)),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      stops: [
                        0.1,
                        0.9,
                      ],
                      colors: [
                        Colors.indigo,
                        Colors.teal,
                      ],
                    )),
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                  ),
                  clipper: MyCustomClipper(),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 0, 0),
                    child: Text(
                      today,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFF8B97A2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarWidget(),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment(-0.1, -0.5),
                                  child: AutoSizeText(
                                    'Calendar Search',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF15212B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment(2.64, 0.55),
                                  child: AutoSizeText(
                                    today,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF8B97A2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment(1, 0),
                              child: Container(
                                width: 40,
                                height: 40,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.network(
                                  'https://picsum.photos/seed/913/400',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment(0.05, 0),
                              child: Icon(
                                Icons.chevron_right,
                                color: Color(0xFF95A1AC),
                                size: 28,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapBox(),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment(-0.1, -0.5),
                                  child: AutoSizeText(
                                    'Map Search',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF15212B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment(2.64, 0.55),
                                  child: AutoSizeText(
                                    today,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF8B97A2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment(1, 0),
                              child: Container(
                                width: 40,
                                height: 40,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.network(
                                  'https://picsum.photos/seed/913/400',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment(0.05, 0),
                              child: Icon(
                                Icons.chevron_right,
                                color: Color(0xFF95A1AC),
                                size: 28,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupportWidget(),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment(-0.1, -0.5),
                                  child: AutoSizeText(
                                    'Support',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF15212B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment(2.64, 0.55),
                                  child: AutoSizeText(
                                    today,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: Color(0xFF8B97A2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment(1, 0),
                              child: Container(
                                width: 40,
                                height: 40,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.network(
                                  'https://picsum.photos/seed/913/400',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment(0.05, 0),
                              child: Icon(
                                Icons.chevron_right,
                                color: Color(0xFF95A1AC),
                                size: 28,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
          actions: [],
          centerTitle: true,
          elevation: 4,
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(17),
            child: Column(
              children: <Widget>[
                FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: <Widget>[
                      FormBuilderFilterChip(
                        name: 'age',
                        decoration: InputDecoration(
                          labelText: 'Age',
                        ),
                        options: [
                          FormBuilderFieldOption(value: 18, child: Text('18+')),
                          FormBuilderFieldOption(value: 45, child: Text('45+')),
                        ],
                      ),
                      FormBuilderFilterChip(
                        name: 'vaccine',
                        decoration: InputDecoration(
                          labelText: 'Vaccine',
                        ),
                        options: [
                          FormBuilderFieldOption(
                              value: 'covishield', child: Text('Covishield')),
                          FormBuilderFieldOption(
                              value: 'covaxin', child: Text('Covaxin')),
                          FormBuilderFieldOption(
                              value: 'sputnik V', child: Text('Sputnik V')),
                        ],
                      ),
                      FormBuilderChoiceChip(
                        name: 'type',
                        initialValue: 'district',
                        decoration: InputDecoration(
                          labelText: 'Search by Pincode / District',
                        ),
                        onChanged: (val) {
                          setState(() {
                            _formKey.currentState?.fields['type']?.validate();
                          });
                        },
                        options: [
                          FormBuilderFieldOption(
                              value: 'pincode', child: Text('Pincode')),
                          FormBuilderFieldOption(
                              value: 'district', child: Text('District')),
                        ],
                      ),
                      (_formKey.currentState != null &&
                              _formKey.currentState?.fields['type'].value ==
                                  'pincode'
                          ? FormBuilderTextField(
                              name: 'pincode',
                              decoration: InputDecoration(
                                labelText: 'Enter Pincode',
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _formKey.currentState?.fields['pincode']
                                      ?.validate();
                                });
                              },
                              validator: FormBuilderValidators.compose(_formKey
                                              .currentState !=
                                          null &&
                                      _formKey.currentState?.fields['type']
                                              .value ==
                                          'pincode'
                                  ? [
                                      FormBuilderValidators.required(context),
                                      FormBuilderValidators.numeric(context),
                                      FormBuilderValidators.maxLength(
                                          context, 6),
                                      FormBuilderValidators.match(context,
                                          "^[1-9]{1}[0-9]{2}\\s{0,1}[0-9]{3}")
                                    ]
                                  : []),
                              keyboardType: TextInputType.number,
                            )
                          : Column(children: [
                              TypeAheadField(
                                hideKeyboard: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        labelText: curstate != null
                                            ? curstate.statename
                                            : 'State',
                                        border: OutlineInputBorder())),
                                suggestionsCallback: (pattern) async {
                                  return fetchStates(http.Client());
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    leading: Icon(Icons.flag),
                                    title: Text(suggestion.statename),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    curstate = suggestion;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 17,
                              ),
                              TypeAheadField(
                                hideKeyboard: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        labelText: curdist != null
                                            ? curdist.districtname
                                            : 'District',
                                        border: OutlineInputBorder())),
                                suggestionsCallback: (pattern) async {
                                  return curstate?.stateid != null
                                      ? fetchDist(
                                          http.Client(), curstate.stateid)
                                      : [];
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    leading: Icon(Icons.flag_rounded),
                                    title: Text(suggestion.districtname),
                                  );
                                },
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    curdist = suggestion;
                                  });
                                },
                              )
                            ])),
                      FormBuilderDateTimePicker(
                        name: 'date',
                        initialValue: datenow,
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: 'Date',
                        ),
                        onChanged: (val) {
                          setState(() {
                            val != null
                                ? curdate = val.day.toString() +
                                    '-' +
                                    val.month.toString() +
                                    '-' +
                                    val.year.toString()
                                : '';

                            _formKey.currentState?.fields['date']?.validate();
                          });
                        },
                        initialTime: TimeOfDay(hour: 8, minute: 0),
                      ),
                      FormBuilderCheckbox(
                        name: 'store',
                        initialValue: false,
                        onChanged: (val) {
                          setState(() {
                            _formKey.currentState?.fields['store']?.validate();
                          });
                        },
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Remember my preferences',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: MaterialButton(
                            color: Theme.of(context).accentColor,
                            child: Text(
                              "Search",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              _formKey.currentState.save();
                              if (_formKey.currentState.validate()) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings: RouteSettings(
                                        arguments: {
                                          "type": _formKey.currentState
                                              ?.fields['type'].value,
                                          "date": curdate,
                                          if (_formKey.currentState
                                                  ?.fields['type'].value ==
                                              'pincode')
                                            "pincode": _formKey.currentState
                                                ?.fields['pincode'].value,
                                          "district_id": curdist != null
                                              ? curdist.districtid
                                              : 0,
                                        },
                                      ),
                                      builder: (context) => HomePageWidget()),
                                );
                              } else {
                                print("validation failed");
                              }
                            },
                          )),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: MaterialButton(
                            color: Theme.of(context).accentColor,
                            child: Text(
                              "Reset",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              _formKey.currentState.reset();
                              clearLocalPin();
                              setState(() {
                                curdate = datenow.day.toString() +
                                    '-' +
                                    datenow.month.toString() +
                                    '-' +
                                    datenow.year.toString();
                                curdist = null;
                                curstate = null;
                              });
                            },
                          )),
                    ),
                  ],
                ),
              ],
            )));
  }
}

class RegisterPageWidget extends StatefulWidget {
  RegisterPageWidget({Key key}) : super(key: key);

  @override
  _RegisterPageWidgetState createState() => _RegisterPageWidgetState();
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 40, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
