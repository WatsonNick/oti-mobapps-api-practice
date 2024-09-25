import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:address_app/page_kecamatan.dart';

class Kabupaten {
  final String id;
  final String province_id;
  final String name;

  Kabupaten({required this.province_id, required this.id, required this.name});

  factory Kabupaten.fromJson(Map<String, dynamic> json) {
    return Kabupaten(
      province_id: json['province_id'],
      id: json['id'],
      name: json['name'],
    );
  }
}

Future<List<Kabupaten>> fetchKabupaten(String provinceId) async {
  try {
    final response = await http
        .get(Uri.parse(
            'https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json'))
        .timeout(const Duration(seconds: 10)); // Timeout in 10 seconds

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Kabupaten.fromJson(json)).toList();
    } else {
      print('Failed to load regencies. Status code: ${response.statusCode}');
      throw Exception('Failed to load regency');
    }
  } catch (error) {
    print("Error: $error");
    throw Exception('Failed to load regencies');
  }
}

class KabupatenListPage extends StatefulWidget {
  final String provinceId;
  final String provinceName;
  const KabupatenListPage(
      {super.key, required this.provinceName, required this.provinceId});

  @override
  KabupatenListPageState createState() => KabupatenListPageState();
}

class KabupatenListPageState extends State<KabupatenListPage> {
  late Future<List<Kabupaten>> _kabupatenFuture;
  @override
  void initState() {
    super.initState();
    _kabupatenFuture = fetchKabupaten(widget.provinceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Regencies in ${widget.provinceName}")),
      body: FutureBuilder<List<Kabupaten>>(
        future: _kabupatenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<Kabupaten> kabupatenList = snapshot.data!;
            return ListView.builder(
              itemCount: kabupatenList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KecamatanListPage(
                            regenciesId: snapshot.data![index].id,
                            regencyName: snapshot.data![index].name),
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
          }
        },
      ),
    );
  }
}
