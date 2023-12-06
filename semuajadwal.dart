import 'dart:convert';
import 'dart:math';

import "package:flutter/material.dart";
import 'package:jadwaljadwal/modal/jadwalModel.dart';
import 'package:jadwaljadwal/modal/api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:jadwaljadwal/views/semuajadwal.dart';
import 'package:jadwaljadwal/views/tambahjadwal.dart';

List<Color> borderColors = [
  Colors.pink,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.yellow,
];

Random random = Random();

Color getRandomColor() {
  return borderColors[random.nextInt(borderColors.length)];
}

class SemuaJadwal extends StatefulWidget {
  @override
  _SemuaJadwalState createState() => _SemuaJadwalState();
}

class _SemuaJadwalState extends State<SemuaJadwal> {
  var loading = false;
  final list = <JadwalModel>[];
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
  String searchQuery = '';
  List<JadwalModel> filteredJadwal = [];

  void searchJadwal(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredJadwal = List.from(list);
      } else {
        filteredJadwal = list
            .where((jadwal) =>
                jadwal.namaJadwal.toLowerCase().contains(query.toLowerCase()) ||
                jadwal.deskripsi.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _performSearch() {
    setState(() {
      filteredJadwal = list
          .where((jadwal) =>
              jadwal.namaJadwal
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              jadwal.deskripsi
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(BaseUrl.lihatJadwal));
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new JadwalModel(
          api['id'],
          api['namaJadwal'],
          api['deskripsi'],
          api['status'],
          api['DueDate'],
          api['createDate'],
          api['idUsers'],
          api['nama'],
        );
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _lihatData();
    searchJadwal('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 167, 167),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          title: TextField(
            onChanged: (value) {
              searchJadwal(value);
            },
            onSubmitted: (value) {
              _performSearch();
            },
            decoration: InputDecoration(
              hintText: 'Cari jadwal...',
              hintStyle: TextStyle(color: Colors.black),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_month_rounded),
              onPressed: () {
                _performSearch();
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: RefreshIndicator(
          key: _refresh,
          onRefresh: _lihatData,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : filteredJadwal.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredJadwal.length,
                      itemBuilder: (context, i) {
                        final x = filteredJadwal[i];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: getRandomColor(),
                                width: 5.0,
                              ),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                getRandomColor().withOpacity(0.2)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              title: Text(
                                x.namaJadwal,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text('Deskripsi: ${x.deskripsi}'),
                                  SizedBox(height: 5),
                                  Text(
                                    'Due Date: ' +
                                        DateFormat('dd MMMM yyyy')
                                            .format(DateTime.parse(x.DueDate)),
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text('Tidak ada Jadwal'),
                    ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Semua Jadwal'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
// Add more menu items here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TambahJadwal(_lihatData)));
        },
        child: Icon(
          Icons.edit_rounded,
          size: 35,
        ),
      ),
    );
  }
}
