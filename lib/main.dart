
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class User {
  String name;
  String mobile;
  String dropdown;
  String imagePath;

  User({
    required this.name,
    required this.mobile,
    required this.dropdown,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile': mobile,
      'dropdown': dropdown,
      'imagePath': imagePath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      mobile: map['mobile'],
      dropdown: map['dropdown'],
      imagePath: map['imagePath'],
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
  String? _imagePath;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<User> userList = [];

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _saveData() async {
    User user = User(
      name: _nameController.text,
      mobile: _mobileController.text,
      dropdown: _selectedItem!,
      imagePath: _imagePath ?? '',
    );

    setState(() {
      userList.add(user);
    });

    _nameController.clear();
    _mobileController.clear();
    _selectedItem;
    _imagePath;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value==null) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                  validator: (value) {
                    if (value==null) {
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
                    _getImage(); // Add image picker
                  },
                  child: Text('Select Image'),
                ),
                _imagePath != null
                    ? Image.file(File(_imagePath!))
                    : Container(), // Display selected image
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

  void _updateData(int index, User newUser, String oldImagePath) async {
    if (newUser.imagePath.isNotEmpty && oldImagePath.isNotEmpty) {
      // If a new image is selected and an old image exists, delete the old image
      File(oldImagePath).deleteSync();
    }

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
                if (user.imagePath.isNotEmpty)
                  Image.file(
                    File(user.imagePath),
                    width: 100,
                    height: 100,
                  ),
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
                        TextEditingController nameController = TextEditingController(text: user.name);
                        TextEditingController mobileController = TextEditingController(text: user.mobile);
                        String selectedItem = user.dropdown;
                        String imagePath = user.imagePath;
                        String oldImagePath = user.imagePath; // Store the old image path

                        return AlertDialog(
                          title: Text('Update Data'),
                          content: Column(
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(labelText: 'Name'),
                              ),
                              TextField(
                                controller: mobileController,
                                decoration: InputDecoration(labelText: 'Mobile Number'),
                              ),
                              DropdownButtonFormField<String>(
                                value: selectedItem,
                                onChanged: (value) {
                                  selectedItem = value!;
                                },
                                items: ['Option 1', 'Option 2', 'Option 3']
                                    .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                                    .toList(),
                                decoration: InputDecoration(labelText: 'Dropdown'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    imagePath = pickedFile.path;
                                    setState(() {}); // Update the image preview
                                  }
                                },
                                child: Text('Change Image'),
                              ),
                              if (imagePath.isNotEmpty)
                                Image.file(
                                  File(imagePath),
                                  width: 100,
                                  height: 100,
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
                                  imagePath: imagePath,
                                );
                                _updateData(index, newUser, oldImagePath); // Pass old image path
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
    );
  }
}
