import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:address_app/page_kelurahan.dart';

class Kecamatan {
  final String id;
  final String regency_id;
  final String name;

  Kecamatan({required this.regency_id, required this.id, required this.name});

  factory Kecamatan.fromJson(Map<String, dynamic> json) {
    return Kecamatan(
      regency_id: json['regency_id'],
      id: json['id'],
      name: json['name'],
    );
  }
}

Future<List<Kecamatan>> fetchkelurahan(String regenciesId) async {
  try {
    final response = await http
        .get(Uri.parse(
            'https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regenciesId.json'))
        .timeout(const Duration(seconds: 10)); // Timeout in 10 seconds

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Kecamatan.fromJson(json)).toList();
    } else {
      print('Failed to load districts. Status code: ${response.statusCode}');
      throw Exception('Failed to load district');
    }
  } catch (error) {
    print("Error: $error");
    throw Exception('Failed to load districts');
  }
}

class KecamatanListPage extends StatefulWidget {
  final String regenciesId;
  final String regencyName;
  const KecamatanListPage(
      {super.key, required this.regencyName, required this.regenciesId});

  @override
  KecamatanListPageState createState() => KecamatanListPageState();
}

class KecamatanListPageState extends State<KecamatanListPage> {
  late Future<List<Kecamatan>> _kelurahanFuture;

  @override
  void initState() {
    super.initState();
    _kelurahanFuture = fetchkelurahan(widget.regenciesId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Districts in ${widget.regencyName}")),
      body: FutureBuilder<List<Kecamatan>>(
        future: _kelurahanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<Kecamatan> kelurahanList = snapshot.data!;
            return ListView.builder(
              itemCount: kelurahanList.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KelurahanListPage(
                            districtId: snapshot.data![index].id,
                            districtName: snapshot.data![index].name,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(snapshot.data![index].name),
                      subtitle: Text('ID: ${snapshot.data![index].id}'),
                    ));
              },
            );
          }
        },
      ),
    );
  }
}
