import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class States {
  final num stateid;
  final String statename;

  States({
    this.statename,
    this.stateid,
  });

  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      statename: json['state_name'] as String,
      stateid: json['state_id'] as num,
    );
  }
}

class Districts {
  final num stateid;
  final num districtid;
  final String districtname;

  Districts({
    this.stateid,
    this.districtid,
    this.districtname,
  });

  factory Districts.fromJson(Map<String, dynamic> json) {
    return Districts(
      districtname: json['district_name'] as String,
      stateid: json['state_id'] as num,
      districtid: json['district_id'] as num,
    );
  }
}

Future<List> fetchStates() async {
  http.Client client;
  final response = await client
      .get(Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/states'));

// Use the compute function to run parsePhotos in a separate isolate.

  return compute(parseStates, response.body);
}

List parseStates(String parz) {
  final parsed = jsonDecode(parz);
  return parsed["states"].map((json) => States.fromJson(json)).toList();
}

Future<List> fetchDist(num id) async {
  http.Client client;
// print(id);
  final response = await client.get(Uri.parse(
      'https://cdn-api.co-vin.in/api/v2/admin/location/districts/' +
          id.toString()));

// Use the compute function to run parsePhotos in a separate isolate.
// print(response.body);

  return compute(parseDistricts, response.body);
}

List parseDistricts(String parz) {
  final parsed = jsonDecode(parz);
  return parsed["districts"].map((json) => Districts.fromJson(json)).toList();
}

class Vaccine {
  final String date;
  final String feetype;
  final int availablecapacity;
  final int availablecapacitydose1;
  final int availablecapacitydose2;
  final String address;
  final String name;
  final String vaccine;
  final String from;
  final String misc;
  final int minagelimit;

  Vaccine({
    this.date,
    this.misc,
    this.feetype,
    this.name,
    this.availablecapacity,
    this.availablecapacitydose1,
    this.availablecapacitydose2,
    this.address,
    this.vaccine,
    this.minagelimit,
    this.from,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      feetype: json['fee_type'] as String,
      availablecapacitydose1: json['available_capacity_dose1'] as int,
      availablecapacitydose2: json['available_capacity_dose2'] as int,
      availablecapacity: json['available_capacity'] as int,
      address: json['address'] as String,
      name: json['name'] as String,
      vaccine: json['vaccine'] as String,
      minagelimit: json['min_age_limit'] as int,
      date: json['date'] as String,
      from: json['from'].substring(0, 5) + ' - ' + json['to'].substring(0, 5)
          as String,
      misc: json['state_name'] +
          ' ' +
          json['district_name'] +
          ' ' +
          json['block_name'] +
          ' ' +
          json['pincode'].toString() as String,
    );
  }
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

// A function that converts a response body into a List<Photo>.
List parseVaccines(String responseBody) {
  final parsed = jsonDecode(responseBody);
  if (parsed["sessions"].length != 0) {
    // print(parsed);
    return parsed["sessions"].map((json) => Vaccine.fromJson(json)).toList();
  }
  return null;
}
