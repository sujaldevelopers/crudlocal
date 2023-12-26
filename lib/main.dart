import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class User {
  String name;
  String mobile;
  String dropdown;

  User({
    required this.name,
    required this.mobile,
    required this.dropdown,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile': mobile,
      'dropdown': dropdown,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      mobile: map['mobile'],
      dropdown: map['dropdown'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => InputDataPage(),
        '/list': (context) => ListDataPage(),
      },
    );
  }
}

class InputDataPage extends StatefulWidget {
  @override
  _InputDataPageState createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  String? _selectedItem;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<User> userList = [];

  void _saveData() async {
    User user = User(
      name: _nameController.text,
      mobile: _mobileController.text,
      dropdown: _selectedItem!,
    );

    setState(() {
      userList.add(user);
    });

    _nameController.clear();
    _mobileController.clear();
    // _selectedItem = null;

    // Save user list to file
    await _saveDataToFile();
  }

  Future<void> _saveDataToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.json');

    String jsonData = jsonEncode(userList.map((user) => user.toMap()).toList());
    await file.writeAsString(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (name) {
                  if (name == null) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                validator: (mobile) {
                  if (mobile == null) {
                    return 'Please enter a mobile number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedItem,
                onChanged: (value) {
                  setState(() {
                    _selectedItem = value!;
                  });
                },
                items: ['Option 1', 'Option 2', 'Option 3']
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Dropdown'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveData();
                  }
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/list');
                },
                child: Text('Go to List Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListDataPage extends StatefulWidget {
  @override
  _ListDataPageState createState() => _ListDataPageState();
}

class _ListDataPageState extends State<ListDataPage> {
  List<User> userList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_data.json');

      if (file.existsSync()) {
        String jsonData = await file.readAsString();
        List<dynamic> userMaps = jsonDecode(jsonData);

        setState(() {
          userList = userMaps.map((userMap) => User.fromMap(userMap)).toList();
        });
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  void _deleteData(int index) {
    setState(() {
      userList.removeAt(index);
      _saveDataToFile();
    });
  }

  void _updateData(int index, User newUser) {
    setState(() {
      userList[index] = newUser;
      _saveDataToFile();
    });
  }

  Future<void> _saveDataToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.json');

    String jsonData = jsonEncode(userList.map((user) => user.toMap()).toList());
    await file.writeAsString(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: userList.isEmpty
          ? Center(
              child: Text('No data available.'),
            )
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                User user = userList[index];
                return ListTile(
                  title: Text('Name: ${user.name}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mobile Number: ${user.mobile}'),
                      Text('Dropdown: ${user.dropdown}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController nameController =
                                  TextEditingController(text: user.name);
                              TextEditingController mobileController =
                                  TextEditingController(text: user.mobile);
                              String selectedItem = user.dropdown;

                              return AlertDialog(
                                title: Text('Update Data'),
                                content: Column(
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration:
                                          InputDecoration(labelText: 'Name'),
                                    ),
                                    TextField(
                                      controller: mobileController,
                                      decoration: InputDecoration(
                                          labelText: 'Mobile Number'),
                                    ),
                                    DropdownButtonFormField<String>(
                                      value: selectedItem,
                                      onChanged: (value) {
                                        selectedItem = value!;
                                      },
                                      items:
                                          ['Option 1', 'Option 2', 'Option 3']
                                              .map((item) => DropdownMenuItem(
                                                    value: item,
                                                    child: Text(item),
                                                  ))
                                              .toList(),
                                      decoration: InputDecoration(
                                          labelText: 'Dropdown'),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      User newUser = User(
                                        name: nameController.text,
                                        mobile: mobileController.text,
                                        dropdown: selectedItem,
                                      );
                                      _updateData(index, newUser);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteData(index);
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InputDataPage(),
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
