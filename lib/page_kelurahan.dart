import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Kelurahan {
  final String id;
  final String district_id;
  final String name;

  Kelurahan({required this.district_id, required this.id, required this.name});

  factory Kelurahan.fromJson(Map<String, dynamic> json) {
    return Kelurahan(
      district_id: json['district_id'],
      id: json['id'],
      name: json['name'],
    );
  }
}

Future<List<Kelurahan>> fetchkelurahan(String districtId) async {
  try {
    final response = await http
        .get(Uri.parse(
            'https://www.emsifa.com/api-wilayah-indonesia/api/villages/$districtId.json'))
        .timeout(const Duration(seconds: 10)); // Timeout in 10 seconds

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Kelurahan.fromJson(json)).toList();
    } else {
      print('Failed to load regencies. Status code: ${response.statusCode}');
      throw Exception('Failed to load village');
    }
  } catch (error) {
    print("Error: $error");
    throw Exception('Failed to load villages');
  }
}

class KelurahanListPage extends StatefulWidget {
  final String districtId;
  final String districtName;
  KelurahanListPage(
      {super.key, required this.districtName, required this.districtId});

  @override
  KecamatanListPageState createState() => KecamatanListPageState();
}

class KecamatanListPageState extends State<KelurahanListPage> {
  late Future<List<Kelurahan>> _kelurahanFuture;

  @override
  void initState() {
    super.initState();
    _kelurahanFuture = fetchkelurahan(widget.districtId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Villages in ${widget.districtName}")),
      body: FutureBuilder<List<Kelurahan>>(
        future: _kelurahanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<Kelurahan> kelurahanList = snapshot.data!;
            return ListView.builder(
              itemCount: kelurahanList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(kelurahanList[index].name),
                  subtitle: Text('ID: ${snapshot.data![index].id}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
