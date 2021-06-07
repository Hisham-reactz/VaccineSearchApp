import 'dart:convert';
// import 'dart:developer';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';

class CalendarWidget extends StatefulWidget {
  CalendarWidget({Key key}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final pageViewController = PageController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  List<bool> isSelected = [true, false];
  TextEditingController pinctrl;
  dynamic _caldata = [];
  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];
  @override
  void initState() {
    super.initState();
    pinctrl = TextEditingController();
    // fetchCal();
  }

  @override
  void dispose() {
    pinctrl.dispose();
    super.dispose();
  }

  fetchCal() async {
    final response = await http.get(
      Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=' +
            '679322' +
            '&date=' +
            _focusedDay.day.toString() +
            '/' +
            _focusedDay.month.toString() +
            '/' +
            _focusedDay.year.toString(),
      ),
    );
    final responseJson = jsonDecode(response.body);
    setState(() {
      _caldata = responseJson;
      // ignore: unnecessary_statements
      _caldata == null ? _caldata = [] : '';
    });

    return responseJson;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [],
        centerTitle: true,
        elevation: 4,
      ),
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                  padding: EdgeInsets.only(top: 13, bottom: 13),
                  child: ToggleButtons(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(7), child: Text('PinCode')),
                      Padding(
                          padding: EdgeInsets.all(7), child: Text('District')),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < isSelected.length;
                            buttonIndex++) {
                          if (buttonIndex == index) {
                            isSelected[buttonIndex] = true;
                          } else {
                            isSelected[buttonIndex] = false;
                          }
                        }
                      });
                    },
                    isSelected: isSelected,
                  )),
              isSelected[0]
                  ? Container(
                      width: 300,
                      child: TextField(
                        controller: pinctrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          labelText: 'PinCode',
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(7),
                      child: Row(children: [
                        Text('STATE '),
                        Expanded(
                            child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _kOptions.where((String option) {
                              return option.contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            print('You just selected $selection');
                          },
                        )),
                        Text('DISTRICT '),
                        Expanded(
                            child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _kOptions.where((String option) {
                              return option.contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            print('You just selected $selection');
                          },
                        ))
                      ])),
              TableCalendar(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: null,
                availableCalendarFormats: {
                  CalendarFormat.week: 'Week',
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = focusedDay;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
