import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corganizer/pages/home/homedocs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'imageview.dart';
import 'pdfview.dart';
import 'videoplay.dart';

class upload extends StatefulWidget {
  String did;
  String type;
  String url;

  upload({
    required this.did,
    required this.type,
    required this.url,
  });

  @override
  State<upload> createState() => _uploadState(
        did: did,
        type: type,
        url: url,
      );
}

class _uploadState extends State<upload> {
  String did;
  String type;
  String url;

  List<String> _selectedFiles = [];

  _uploadState({
    required this.did,
    required this.type,
    required this.url,
  });

  final _auth = FirebaseAuth.instance;
  TextEditingController title = TextEditingController();
  CollectionReference ref = FirebaseFirestore.instance.collection('users');

  File? file;
  String url1 = "";
  var name;
  var ft;
  var ic;
  var vis = false;

  @override
  void initState() {
    if (type == 'Documents') {
      ft = [
        'pdf',
      ];
      ic = Icon(
        Icons.picture_as_pdf,
        color: Color.fromARGB(255, 181, 0, 45),
        size: 40,
      );
    }
    if (type == 'Images') {
      ft = ['jpg', 'png'];
      ic = Icon(
        Icons.image,
        color: Color.fromARGB(255, 0, 91, 181),
        size: 40,
      );
    }
    if (type == 'Videos') {
      ft = ['mp4'];
      ic = Icon(
        Icons.play_circle,
        color: Color.fromARGB(255, 181, 0, 45),
        size: 50,
      );
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('folders')
        .doc(did)
        .collection(type)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              deletefolder();
            },
            icon: Icon(
              Icons.delete_forever,
              color: Color.fromARGB(255, 181, 0, 45),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        title: Row(),
      ),
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
                  return GestureDetector(
                    onTap: () {
                      if (type == 'Images') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => (imageview(
                              url: data['url'],
                            )),
                          ),
                        );
                      }
                      if (type == 'Documents') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => (pdfview(
                              url: data['url'],
                            )),
                          ),
                        );
                      }
                      if (type == 'Videos') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => (videoplay(
                              url: data['url'],
                            )),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        _selectedFiles.add(type);
                      });
                    },
                    child: ListTile(
                      leading: ic,
                      title: Text(data['name']),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 255, 0, 64),
                        ),
                        onPressed: () {
                          ref
                              .doc(user.uid)
                              .collection('folders')
                              .doc(did)
                              .collection(type)
                              .doc(document.id)
                              .delete();
                        },
                      ),

                      // subtitle: Text(data['type']),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Center(
            child: Visibility(
              visible: vis,
              child: CircularProgressIndicator(
                color: Colors.indigo[800],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 67.5,
        height: 67.5,
        child: FloatingActionButton(
          onPressed: () {
            getfile();
          },
          backgroundColor: Colors.grey.shade700,
          child: const Icon(
            Icons.add,
            color: Colors.white70,
            size: 50,
          ),
        ),
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

  getfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ft,
    );

    if (result != null) {
      File c = File(result.files.single.path.toString());
      setState(() {
        file = c;
        name = result.names[0];
        vis = true;
      });

      uploadFile();
    }
  }

  uploadFile() async {
    try {
      var imagefile = FirebaseStorage.instance.ref().child(type).child(name);
      UploadTask task = imagefile.putFile(file!);
      TaskSnapshot snapshot = await task;
      url1 = await snapshot.ref.getDownloadURL();

      // print(url);
      if (file != null) {
        User? user = _auth.currentUser;
        ref.doc(user!.uid).collection('folders').doc(did).collection(type).add({
          'url': url1,
          'name': name,
        });
        setState(() {
          vis = false;
        });
        Fluttertoast.showToast(
          msg: "Done Uploaded",
          textColor: Colors.red,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong",
          textColor: Colors.red,
        );
        setState(() {
          vis = false;
        });
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: Colors.red,
      );
      setState(() {
        vis = false;
      });
    }
  }
}
