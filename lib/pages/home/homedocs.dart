import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'docs/upload.dart';

class HomeDocs extends StatefulWidget {
  String did;
  String type;
  String url;

  HomeDocs({
    required this.did,
    required this.type,
    required this.url,
  });

  @override
  State<HomeDocs> createState() => _HomeDocsState(
        did: did,
        type: type,
        url: url,
      );
}

class _HomeDocsState extends State<HomeDocs> {
  String did;
  String type;
  String url;

  _HomeDocsState({
    required this.did,
    required this.type,
    required this.url,
  });

  bool _isSelected = false;
  List<String> _selectedFiles = [];

  final _auth = FirebaseAuth.instance;
  TextEditingController title = TextEditingController();
  CollectionReference ref = FirebaseFirestore.instance.collection('users');

  var options = [
    'Documents',
    'Images',
    'Videos',
  ];
  bool value = false;
  var _currentItemSelected = "Documents";

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('folders')
        .orderBy('createdAt', descending: true)
        .snapshots();
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                    child: Text("Something Went Wrong!",
                        style: TextStyle(
                          color: Colors.white70,
                        )));
              }

              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "You have no Uploaded Documents!",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  );
                }
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Text("Loading...",
                        style: TextStyle(
                          color: Colors.white70,
                        )));
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  DateTime createdAt = data['createdAt'].toDate();
                  String formattedDate =
                      DateFormat.yMd().add_jm().format(createdAt);
                  return GestureDetector(
                      onTap: () {
                        print(
                          data['type'],
                        );
                        print(document.id);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => (upload(
                              url: url,
                              did: document.id,
                              type: data['type'],
                            )),
                          ),
                        );
                      },
                      onLongPress: () {
                        setState(() {
                          _selectedFiles.add(value as String);
                          _isSelected = true;
                        });
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.folder,
                          color: Colors.amber[300],
                          size: 50,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data['name']),
                            Text(formattedDate),
                          ],
                        ),
                        subtitle: Text(data['type']),
                      ));
                }).toList(),
              );
            },
          ),
          Positioned(
              bottom: 20,
              // left: 0,
              right: 20,
              child: Transform.scale(
                  scale: 1.2,
                  child: SizedBox(
                    height: 59.5,
                    width: 59.5,
                    child: Center(
                      child: FloatingActionButton(
                        heroTag: 'add_button',
                        onPressed: () async {
                          await showInformationDialog(context);
                        },
                        backgroundColor: Colors.grey.shade700,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white70,
                          size: 42,
                        ),
                      ),
                    ),
                  ))),
          Positioned(
              bottom: 50,
              left: 162.5,
              child: Visibility(
                  visible: _isSelected,
                  child: Transform.scale(
                      scale: 1.2,
                      child: SizedBox(
                          height: 70,
                          width: 70,
                          child: FloatingActionButton(
                              onPressed: () {
                                deletefolder();
                              },
                              backgroundColor: Colors.grey.shade700,
                              child: const Icon(
                                Icons.delete_forever,
                                color: Colors.white70,
                                size: 42,
                              ))))))
        ],
      ),
    );
  }

  deletefolder() async {
    User? user = _auth.currentUser;
    var catalogues = ref
        .doc(user?.uid)
        .collection('folders')
        .doc(did)
        .collection(type)
        .get();
    catalogues.then((value) => value.docs.remove(value));

    ref.doc(user?.uid).collection('folders').doc(did).delete().whenComplete(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => (HomeDocs(
            url: url,
            did: '',
            type: '',
          )),
        ),
      );
    });
  }

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Form(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: title,
                  validator: (value) {
                    return null;

                    // return value.isNotEmpty ? null : "Enter any text";
                  },
                  decoration:
                      InputDecoration(hintText: "Please Enter Your Filename"),
                ),
                SizedBox(
                  height: 40,
                ),
                DropdownButton<String>(
                  dropdownColor: Color.fromARGB(255, 46, 115, 199),
                  isDense: true,
                  isExpanded: false,
                  iconEnabledColor: Color.fromARGB(255, 255, 255, 255),
                  items: options.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(
                        dropDownStringItem,
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValueSelected) {
                    setState(() {
                      _currentItemSelected = newValueSelected!;
                      print(_currentItemSelected);
                    });
                  },
                  value: _currentItemSelected,
                ),
                SizedBox(
                  height: 60,
                ),
              ],
            )),
            title: Text('Create a Folder'),
            actions: <Widget>[
              InkWell(
                child: Text('Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    )),
                onTap: () {
                  Navigator.of(context).pop();
                  // }
                },
              ),
              SizedBox(
                width: 40,
              ),
              InkWell(
                child: Text('Create',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    )),
                onTap: () {
                  if (title.text != '') {
                    User? user = _auth.currentUser;
                    ref.doc(user!.uid).collection('folders').add({
                      'name': title.text,
                      'type': _currentItemSelected,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    title.clear();
                    Navigator.of(context).pop();
                  }
                },
              ),
              SizedBox(
                width: 40,
              ),
            ],
          );
        });
      },
    );
  }
}
