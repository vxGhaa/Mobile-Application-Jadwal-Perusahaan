import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jadwaljadwal/modal/jadwalModel.dart';
import 'package:jadwaljadwal/modal/api.dart';
import 'package:jadwaljadwal/views/editJadwal.dart';
import 'package:jadwaljadwal/views/tambahJadwal.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

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

class Project extends StatefulWidget {
  @override
  _ProjectState createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  var loading = false;
  final list = <JadwalModel>[];
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  String searchQuery = '';
  List<JadwalModel> filteredJadwal = [];

  void searchJadwal(String query) {
    setState(() {
      filteredJadwal = list
          .where((jadwal) =>
              jadwal.namaJadwal.toLowerCase().contains(query.toLowerCase()) ||
              jadwal.deskripsi.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
            api['nama']);
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  dialogDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  255, 226, 109, 246), // Set the background color to purple
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Hapus Jadwal",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set the text color to white
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "Kamu yakin mau hapus jadwal ini?",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white, // Set the text color to white
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.brown), // Set the background color to gray
                      ),
                      child: Text(
                        "Ga jadi",
                        style: TextStyle(
                            color: Colors.white), // Set the text color to white
                      ),
                    ),
                    SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        _delete(id);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 255, 135,
                                149)), // Set the background color to green
                      ),
                      child: Text(
                        "Oke deh",
                        style: TextStyle(
                            color: Colors.white), // Set the text color to white
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _delete(String id) async {
    final response = await http
        .post(Uri.parse(BaseUrl.deleteJadwal), body: {"idJadwal": id});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    var logger = Logger();
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
        _lihatData();
      });
    } else {
      logger.d(pesan);
      //print(pesan);
    }
  }

  @override
  void initState() {
    super.initState();
    _lihatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          elevation: 5,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          shadowColor: Colors.grey.withOpacity(0.7),
          title: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                searchJadwal(value);
              },
              onSubmitted: (value) {
                _performSearch();
              },
              decoration: InputDecoration(
                hintText: 'Cari jadwal...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.calendar_month_rounded),
                color: Colors.white,
                iconSize: 32,
                onPressed: () {
                  _performSearch();
                },
              ),
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
          onRefresh: _lihatData,
          key: _refresh,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : filteredJadwal.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredJadwal.length,
                      itemBuilder: (context, i) {
                        final x = filteredJadwal[i];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8, // Lebar garis warna pink
                                  decoration: BoxDecoration(
                                    color: Colors.cyan, // Warna pink
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                    ),
                                    border: Border.all(
                                      color: Colors.pink, // Warna pink
                                      width: 40, // Lebar garis
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        8), // Jarak antara garis dan konten jadwal
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: getRandomColor(),
                                          ),
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            x.namaJadwal,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          x.deskripsi,
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          x.status,
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Dibuat Oleh: ${x.nama}',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Due Date: ' +
                                              DateFormat('dd MMMM yyyy').format(
                                                  DateTime.parse(x.DueDate)),
                                          style: TextStyle(fontSize: 15.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.brown,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            EditJadwal(x, _lihatData),
                                      ));
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                      child: Icon(
                                        Icons.edit_document,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.purple,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: InkWell(
                                    onTap: () {
                                      dialogDelete(x.id);
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                      child: Icon(
                                        Icons.done_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}
