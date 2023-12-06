import 'dart:convert';

import "package:flutter/material.dart";
import "package:jadwaljadwal/modal/jadwalModel.dart";
import 'package:jadwaljadwal/modal/api.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jadwaljadwal/custom/datePicker.dart';

class EditJadwal extends StatefulWidget {
  final JadwalModel model;
  final VoidCallback reload;
  EditJadwal(this.model, this.reload);
  @override
  State<EditJadwal> createState() => _EditJadwalState();
}

class _EditJadwalState extends State<EditJadwal> {
  final _key = new GlobalKey<FormState>();
  String? namaJadwal, deskripsi, status;

  late TextEditingController txtNama, txtDeskripsi, txtStatus;
  late String tgldate;

  setup() {
    tgldate = widget.model.DueDate;
    txtNama = TextEditingController(text: widget.model.namaJadwal);
    txtDeskripsi = TextEditingController(text: widget.model.deskripsi);
    txtStatus = TextEditingController(text: widget.model.status);
  }

  check() {
    final form = _key.currentState;
    if (form?.validate() ?? false) {
      form!.save();
      sumbit();
    } else {}
  }

  sumbit() async {
    final response = await http.post(Uri.parse(BaseUrl.editJadwal), body: {
      "namaJadwal": namaJadwal,
      "deskripsi": deskripsi,
      "status": status,
      "idJadwal": widget.model.id,
      "DueDate": "$tgldate"
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

  late String pilihTanggal, labelText = 'DueDate';
  DateTime tgl = DateTime.now();
  var formatTgl = DateFormat('yyyy-MM-dd');
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
        tgldate = formatTgl.format(tgl);
      });
    } else {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          iconSize: 20,
        ),
        title: Text(
          'Edit Jadwal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _key,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: txtNama,
                onSaved: (e) => namaJadwal = e,
                decoration: InputDecoration(
                  labelText: 'Nama Jadwal',
                  labelStyle: TextStyle(color: Colors.brown),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.cyan,
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: txtDeskripsi,
                onSaved: (e) => deskripsi = e,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: TextStyle(color: Colors.brown),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              TextFormField(
                controller: txtStatus,
                onSaved: (e) => status = e,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: Colors.brown),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.pink,
                    ),
                  ),
                ),
              ),
              DateDropDown(
                labelText: labelText,
                valueText: tgldate,
                valueStyle: valueStyle,
                child: Text('DropDown Child'),
                onPressed: () {
                  _selectedDate(context);
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_key.currentState!.validate()) {
                    _key.currentState!.save();
                    check();
                  }
                },
                child: Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
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
