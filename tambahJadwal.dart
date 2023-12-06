import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jadwaljadwal/custom/datePicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jadwaljadwal/modal/api.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class TambahJadwal extends StatefulWidget {
  final VoidCallback reload;
  TambahJadwal(this.reload);
  @override
  _TambahJadwalState createState() => _TambahJadwalState();
}

class _TambahJadwalState extends State<TambahJadwal> {
  String? namaJadwal, deskripsi, status, idUsers;
  final _key = new GlobalKey<FormState>();

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getString("id");
    });
  }

  check() {
    final form = _key.currentState;
    if (form?.validate() ?? false) {
      form!.save();
      submit();
    }
  }

  submit() async {
    final response = await http.post(Uri.parse(BaseUrl.tambahJadwal), body: {
      "namaJadwal": namaJadwal,
      "deskripsi": deskripsi,
      "status": status,
      "idUsers": idUsers,
      "DueDate": "$tgl"
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    var logger = Logger();
    if (value == 1) {
      logger.d(pesan);
      //print(pesan);
      setState(() {
        widget.reload();
        Navigator.pop(context);
      });
    } else {
      logger.d(pesan);
      //print(print);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  late String pilihTanggal, labelText = 'Due Date';
  DateTime tgl = DateTime.now();
  final TextStyle valueStyle = TextStyle(fontSize: 16.0);
  Future<Null> _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tgl,
      firstDate: DateTime(1992),
      lastDate: DateTime(2099),
    );

    if (picked != null && picked != tgl) {
      setState(() {
        tgl = picked;
        pilihTanggal = new DateFormat.yMd().format(tgl);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors
            .brown[200], // Change the app bar background color to pastel brown
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(30), // Change the app bar shape to rounded
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white, // Change the back arrow icon color
          ),
          iconSize: 20,
        ),
        title: Text(
          'Tambah Jadwal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Change the title text color
          ),
        ),
      ),
      body: Form(
        key: _key,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 16.0),
              TextFormField(
                onSaved: (e) => namaJadwal = e,
                decoration: InputDecoration(
                  labelText: 'Nama Jadwal',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Rounded border for the input field
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .brown), // Brown-colored border when the field is focused
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                onSaved: (e) => deskripsi = e,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                onSaved: (e) => status = e,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  _selectedDate(context);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.brown),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMd().format(tgl),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  check();
                },
                child: Text("Simpan"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown[
                      200], // Change the button background color to pastel brown
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Rounded button shape
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
