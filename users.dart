import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jadwaljadwal/modal/api.dart';
import 'package:jadwaljadwal/views/home.dart';
import 'package:jadwaljadwal/views/menuUsers.dart';
import 'package:jadwaljadwal/views/profil.dart';
import 'package:jadwaljadwal/views/project.dart';
import 'package:jadwaljadwal/views/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:flutter/cupertino.dart';

class User {
  final int id;
  final String username;
  final String password;
  final String nama;
  final int? level;

  User(
      {required this.id,
      required this.username,
      required this.password,
      required this.nama,
      this.level});
}

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  void _createNewUser() {}
  TextEditingController _searchController = TextEditingController();
  List<User> _users = [];
  List<String> userList = [];
  void _filterUsers(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _users = _users
            .where((user) =>
                user.nama.toLowerCase().contains(query.toLowerCase()) ||
                user.username.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _fetchUsers(); // Reset the user list to its original state
      }
    });
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse(BaseUrl
        .lihatUsers)); // Ganti 'API_URL' dengan URL API Anda untuk mengambil data pengguna
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<dynamic> usersData = data['users'];

      setState(() {
        _users = usersData
            .map((userData) => User(
                  id: int.parse(userData['id']),
                  username: userData['username'],
                  password: userData['password'],
                  nama: userData['nama'],
                  level: userData['level'] != null
                      ? int.parse(userData['level'])
                      : null,
                ))
            .toList();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch users.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _refreshUsers() async {
    await _fetchUsers();
  }

  Future<void> _deleteUser(int userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ngapain?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Kamu mau hapus user ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the confirmation dialog
            },
            child: Text('Gak jadi', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close the confirmation dialog
              final response = await http.post(
                Uri.parse(BaseUrl.deleteUsers),
                body: {'userId': userId.toString()},
              );

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                if (data['value'] == 1) {
                  await _fetchUsers();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text(data['message']),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('Failed to delete user.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text('Iya'),
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              textStyle: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser(User user) async {
    final response = await http.post(
      Uri.parse(BaseUrl.editUsers),
      body: {
        'userId': user.id.toString(),
        'username': user.username,
        'password': user.password,
        'nama': user.nama,
        'level': user.level.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['value'] == 1) {
        await _fetchUsers();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(data['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update user.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    _filterUsers(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(
            255, 182, 255, 254), // Mengubah latar belakang menjadi Cyan
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
            top: Radius.circular(30),
          ),
        ),
        title: Center(
          child: Text(
            'List Users / Admin',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        // Menambahkan efek bayangan
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 9,
                  offset: Offset(1, 3), // Mengatur posisi bayangan
                ),
              ],
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
                top: Radius.circular(30),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _filterUsers(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari Users',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.level == 1
                                      ? Color.fromARGB(255, 251, 128, 128)
                                      : Color.fromARGB(255, 254, 148, 249),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.level == 1 ? 'Admin' : 'User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                user.nama,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text("Email/Username: ${user.username}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                color: Color.fromARGB(255, 140, 0, 255),
                                onPressed: () {
                                  _editUser(user);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  _deleteUser(user.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _tambahUser,
                    backgroundColor: Color.fromARGB(255, 255, 172, 208),
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tambahUser() {
    showDialog(
      context: context,
      builder: (context) {
        String? username, password, nama;
        final _key = GlobalKey<FormState>();

        save() async {
          final response = await http.post(
            Uri.parse(BaseUrl.register),
            body: {"nama": nama, "username": username, "password": password},
          );
          final data = jsonDecode(response.body);
          int value = data['value'];
          String pesan = data['message'];
          if (value == 1) {
            setState(() {
              Navigator.pop(context);
            });
          } else {
            print(pesan);
          }
        }

        check() {
          final form = _key.currentState;
          if (form?.validate() ?? false) {
            form!.save();
            save();
          }
        }

        return AlertDialog(
          title: Text('Daftar Akun Baru'),
          content: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  validator: (e) {
                    if (e?.isEmpty ?? true) {
                      return "Masukkan Nama Lengkap Kamu Dulu";
                    }
                    return null;
                  },
                  onSaved: (e) => nama = e,
                  decoration: InputDecoration(labelText: "Nama Lengkap"),
                ),
                TextFormField(
                  validator: (e) {
                    if (e?.isEmpty ?? true) {
                      return "Masukkan Username";
                    }
                    return null;
                  },
                  onSaved: (e) => username = e,
                  decoration: InputDecoration(labelText: "Email/Username"),
                ),
                TextFormField(
                  onSaved: (e) => password = e,
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                check();
              },
              child: Text('Daftar'),
            ),
          ],
        );
      },
    );
  }

  void _editUser(User user) {
    showDialog(
      context: context,
      builder: (context) {
        String editedUsername = user.username;
        String editedPassword = user.password;
        String editedNama = user.nama;
        int? editedLevel = user.level;
        String selectedLevelText =
            editedLevel != null ? editedLevel.toString() : 'Pilih tipe user';
        String editedLevelText =
            editedLevel != null ? editedLevel.toString() : '';

        return AlertDialog(
          title: Text(
            'Edit User',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: editedUsername,
                    onChanged: (value) {
                      setState(() {
                        editedUsername = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: editedPassword,
                    onChanged: (value) {
                      setState(() {
                        editedPassword = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: editedNama,
                    onChanged: (value) {
                      setState(() {
                        editedNama = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedLevelText,
                    onChanged: (value) {
                      setState(() {
                        selectedLevelText = value!;
                        editedLevel = value != 'Pilih tipe user'
                            ? int.parse(value)
                            : null;
                        editedLevelText =
                            value != 'Pilih tipe user' ? value : '';
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: '1',
                        child: Text(
                          'Admin',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '2',
                        child: Text(
                          'User',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 36,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final editedUser = User(
                  id: user.id,
                  username: editedUsername,
                  password: editedPassword,
                  nama: editedNama,
                  level: editedLevel,
                );
                await _updateUser(editedUser);
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
