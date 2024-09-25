// ignore_for_file: avoid_print

import 'package:address_app/page_kabupaten.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

//? Step 1: Create a model class for Province
class Province {
  final String id;
  final String name;

  Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
    );
  }
}

//? Step 2: Fetch provinces from API
Future<List<Province>> fetchProvinces() async {
  try {
    final response = await http
        .get(Uri.parse(
            'https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json'))
        .timeout(const Duration(seconds: 10)); // Timeout in 10 seconds

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Province.fromJson(json)).toList();
    } else {
      print('Failed to load provinces. Status code: ${response.statusCode}');
      throw Exception('Failed to load province');
    }
  } catch (error) {
    print("Error: $error");
    throw Exception('Failed to load provinces');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Tutorial',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProvinceListPage(),
    );
  }
}

class ProvinceListPage extends StatefulWidget {
  const ProvinceListPage({super.key});

  @override
  ProvinceListPageState createState() => ProvinceListPageState();
}

class ProvinceListPageState extends State<ProvinceListPage> {
  //? Step 6: Late demo using FutureBuilder
  late Future<List<Province>> _provincesFuture;

  @override
  void initState() {
    super.initState();
    _provincesFuture = fetchProvinces();
  }

  @override
  Widget build(BuildContext context) {
    //? Step 5: Early demo using .then()
    // fetchProvinces().then((provinces) {
    //   print('Fetched ${provinces.length} provinces');
    //   for (var province in provinces.take(5)) {
    //     print('${province.id}: ${province.name}');
    //   }
    // }).catchError((error) {
    //   print('Error fetching provinces: $error');
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Indonesian Provinces'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Province>>(
              future: _provincesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KabupatenListPage(
                                provinceId: snapshot.data![index].id,
                                provinceName: snapshot.data![index].name,
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(snapshot.data![index].name),
                          subtitle: Text('ID: ${snapshot.data![index].id}'),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
