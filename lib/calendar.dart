import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

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
  dynamic _caldata;
  dynamic valz;
  int stateid;
  int distid;
  int itemcount = 10;
  ValueNotifier<dynamic> _dayData;
  List<dynamic> _sOptions = <dynamic>[];
  List<dynamic> _dOptions = <dynamic>[];
  @override
  void initState() {
    super.initState();
    pinctrl = TextEditingController();
    fetchstst();
  }

  @override
  void dispose() {
    pinctrl.dispose();
    super.dispose();
  }

  fetchstst() async {
    final response = await http.get(
      Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/states'),
    );
    final responseJson = jsonDecode(response.body);

    setState(() {
      _sOptions = responseJson['states'] ?? [];
    });

    return responseJson ?? [];
  }

  fetchdizt(id) async {
    final response = await http.get(
      Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/districts/' +
          id.toString()),
    );
    final responseJson = jsonDecode(response.body);

    setState(() {
      _dOptions = responseJson['districts'] ?? [];
    });

    return responseJson ?? [];
  }

  fetchCalDist(id) async {
    final response = await http.get(
      Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=' +
            id.toString() +
            '&date=' +
            _focusedDay.day.toString() +
            '-' +
            _focusedDay.month.toString() +
            '-' +
            _focusedDay.year.toString(),
      ),
    );
    final responseJson = jsonDecode(response.body);

    setState(() {
      _caldata = responseJson['centers'] ?? [];
      _dayData = ValueNotifier(_getEventsForDay());
    });

    return responseJson ?? [];
  }

  dynamic getTemp(caldatz) {
    dynamic returndta = caldatz != null ? caldatz : [];
    return returndta as dynamic;
  }

  dynamic _getEventsForDay() {
// Implementation example

    dynamic returndata = _caldata != null ? _caldata : [];
    setState(() {
      itemcount = returndata.length > 10 ? 10 : returndata.length;
    });

    return returndata;
  }

  fetchCal() async {
    final response = await http.get(
      Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=' +
            pinctrl.text +
            '&date=' +
            _focusedDay.day.toString() +
            '-' +
            _focusedDay.month.toString() +
            '-' +
            _focusedDay.year.toString(),
      ),
    );
    final responseJson = jsonDecode(response.body);

    setState(() {
      _caldata = responseJson['centers'] ?? [];
      _dayData = ValueNotifier(_getEventsForDay());
    });

    return responseJson ?? [];
  }

  @override
  Widget build(BuildContext context) {
    loadMore(value) {
      // print(value);

      setState(() {
        if (value.length - (itemcount + 10) > 0) {
          value = value.sublist(
                  itemcount == 10 ? 0 : itemcount - 1, itemcount + 9) ??
              [];
          _dayData = ValueNotifier(getTemp(value));
        } else {
          itemcount = value.length;
        }
      });
    }

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
        child: LazyLoadScrollView(
            scrollOffset: 100,
            onEndOfPage: () => loadMore(valz),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                      padding: EdgeInsets.only(top: 13, bottom: 13),
                      child: ToggleButtons(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(7),
                              child: Text('PinCode')),
                          Padding(
                              padding: EdgeInsets.all(7),
                              child: Text('District')),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                                _caldata = [];
                                _dayData = ValueNotifier(getTemp(null));
                                distid = null;
                                stateid = null;
                                pinctrl.clear();
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
                            onSubmitted: (e) {
                              setState(() {
                                if (pinctrl.text.trim() != '' &&
                                    pinctrl.text.trim().length == 6) {
                                  fetchCal();
                                }
                              });
                            },
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
                                child: Autocomplete<dynamic>(
                              optionsBuilder: (TextEditingValue txt1) {
                                if (txt1.text.trim() == '') {
                                  return [];
                                }
                                var search =
                                    _sOptions.firstWhere((dynamic option) {
                                  return option['state_name']
                                      .contains(txt1.text);
                                });

                                search != null
                                    ? setState(() {
                                        stateid = search['state_id'];
                                      })
                                    : '';

                                return search != null
                                    ? [search['state_name']]
                                    : false;
                              },
                              onSelected: (dynamic selection) {
                                fetchdizt(stateid);
                              },
                            )),
                            Text('DISTRICT '),
                            Expanded(
                                child: Autocomplete<dynamic>(
                              optionsBuilder: (TextEditingValue txt2) {
                                if (txt2.text.trim() == '') {
                                  return [];
                                }
                                // _dOptions = fetchdizt(1);
                                var distz =
                                    _dOptions.firstWhere((dynamic option) {
                                  // print(option);
                                  return option['district_name']
                                      .contains(txt2.text);
                                });

                                distz != null
                                    ? setState(() {
                                        distid = distz['district_id'];
                                      })
                                    : '';

                                return distz != null
                                    ? [distz['district_name']]
                                    : false;
                              },
                              onSelected: (dynamic selection) {
                                fetchCalDist(distid);
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
                      setState(() {
                        _focusedDay = focusedDay;
                        if (pinctrl.text.trim() != '' &&
                            pinctrl.text.trim().length == 6) {
                          fetchCal();
                        } else if (isSelected[1] && distid != null) {
                          fetchCalDist(distid);
                        }
                      });
                    },
                  ),
                  _dayData != null
                      ? ValueListenableBuilder<dynamic>(
                          valueListenable: _dayData,
                          builder: (context, dynamic value, _) {
                            return ListView.builder(
                                primary: false,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: itemcount,
                                itemBuilder: (context, index) {
                                  valz = value;
                                  return value != null && value.length > 0
                                      ? Column(
                                          children: [
                                                ListTile(
                                                  title: Text(
                                                      value[index]['name']),
                                                  subtitle: Text(value[index]
                                                          ['address'] +
                                                      '\n' +
                                                      value[index]
                                                          ['state_name'] +
                                                      ',' +
                                                      value[index]
                                                          ['district_name'] +
                                                      ',' +
                                                      value[index]
                                                          ['block_name']),
                                                  isThreeLine: true,
                                                  trailing: Text(value[index]
                                                          ['fee_type'] +
                                                      '\n' +
                                                      value[index]['from']
                                                          .toString()
                                                          .substring(0, 5) +
                                                      ' - ' +
                                                      value[index]['to']
                                                          .toString()
                                                          .substring(0, 5)),
                                                ),
                                                Divider(),
                                                Text('SESSIONS')
                                              ] +
                                              //     value[index]['vaccine_fees'] ??
                                              // value[index]['vaccine_fees']
                                              //         .map<Text>((z) => Text(
                                              //             z['vaccine'] +
                                              //                 ' - INR ' +
                                              //                 z['fee'].toString()))
                                              //         .toList() +
                                              value[index]['sessions']
                                                  .map<ListTile>((d) =>
                                                      ListTile(
                                                        title:
                                                            Text(d['vaccine']),
                                                        trailing: Text(
                                                            d['min_age_limit']
                                                                    .toString() +
                                                                ' +'),
                                                        subtitle: Text(d[
                                                                'date'] +
                                                            '\n Doses - ' +
                                                            d['available_capacity']
                                                                .toString()),
                                                      ))
                                                  .toList() +
                                              [
                                                Divider(
                                                  color: Colors.black,
                                                )
                                              ],
                                        )
                                      : SizedBox.shrink();
                                });
                          })
                      : SizedBox.shrink()
                ],
              ),
            )),
      ),
    );
  }
}
