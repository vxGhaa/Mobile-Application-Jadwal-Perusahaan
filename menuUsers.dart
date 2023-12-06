import 'dart:convert';
import "package:flutter/material.dart";
import 'package:jadwaljadwal/modal/jadwalModel.dart';
import 'package:jadwaljadwal/modal/api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:jadwaljadwal/views/semuajadwal.dart';

class MenuUsers extends StatefulWidget {
  final VoidCallback signOut;
  MenuUsers(this.signOut);
  @override
  State<MenuUsers> createState() => _MenuUsersState();
}

class _MenuUsersState extends State<MenuUsers> {
  var loading = false;
  final list = <JadwalModel>[];
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();
// Tambahkan variabel dan metode terkait kalender
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now(); // Tambahkan variabel _focusedDate
  Map<DateTime, List<dynamic>> _events = {}; // Tambahkan variabel _events

// Metode yang dipanggil ketika tanggal pada kalender dipilih
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _focusedDate = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  }

// Metode untuk memuat daftar jadwal berdasarkan tanggal
  List<DateTime> _DueDates = [];
  List<dynamic> _selectedEvents = [];
  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Future<void> _lihatData() async {
    _events = {};
    list.forEach((jadwal) {
      final dueDate = DateTime.parse(jadwal.DueDate);
      if (_events.containsKey(dueDate)) {
        _events[dueDate]!.add(jadwal);
      } else {
        _events[dueDate] = [jadwal];
      }
    });
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
        // Tambahkan tanggal DueDate ke _dueDates
        final dueDate = DateTime.parse(ab.DueDate);
        _DueDates.add(DateTime(dueDate.year, dueDate.month, dueDate.day));
      });
      setState(() {
        loading = false;
      });
    }
  }

  String? username = "", nama = "";

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("username");
      nama = preferences.getString("nama");
    });
  }

  @override
  void initState() {
    super.initState();
    _lihatData();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    // Widget kalender
    Widget _buildCalendar() {
      return Column(
        children: [
          TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: _onDaySelected,
            eventLoader:
                _getEventsForDay, // Menggunakan _getEventsForDay untuk memuat jadwal pada tanggal yang dipilih
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final hasEvents = events.isNotEmpty;
                final isToday = isSameDay(date, DateTime.now());
                final hasActivities = _DueDates.contains(date);

                if (hasEvents || isToday || hasActivities) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasActivities
                            ? Colors.pink
                            : hasEvents
                                ? Colors.pink
                                : Colors.blue,
                      ),
                      width: 6,
                      height: 6,
                    ),
                  );
                }

                return null; // Return null if there are no events on the date and it's not today
              },
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SemuaJadwal(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.pink[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Lihat Semua Jadwal'),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.brown[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          title: Text(
            "Halo ! $nama",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  widget.signOut();
                });
              },
              icon: Icon(Icons.lock_open_rounded, color: Colors.black),
            )
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
          child: Column(
            children: [
              _buildCalendar(),
              SizedBox(height: 16),
              Expanded(
                child: loading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final x = list[i];
                          final DateTime dueDate = DateTime.parse(
                              x.DueDate); // Parse dueDate string to DateTime
                          if (dueDate.year != _selectedDate.year ||
                              dueDate.month != _selectedDate.month ||
                              dueDate.day != _selectedDate.day) {
                            return Container(); // Skip jadwal if it doesn't match selected date
                          }
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.pink,
                                  width: 5.0,
                                ),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.cyan.withOpacity(0.2)
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
                                          DateFormat('dd MMMM yyyy').format(
                                              DateTime.parse(x.DueDate)),
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
