import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:corganizer/pages/home/notes/addnote.dart';
import 'package:corganizer/pages/home/notes/viewnote.dart';

class HomeNotes extends StatefulWidget {
  @override
  _HomeNotesState createState() => _HomeNotesState();
}

class _HomeNotesState extends State<HomeNotes> {
  CollectionReference ref = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('notes');

  List<Color> myColors = [
    Colors.yellow.shade300,
    Colors.yellow.shade400,
    Colors.red.shade300,
    Colors.red.shade400,
    Colors.green.shade300,
    Colors.green.shade400,
    Colors.purple.shade300,
    Colors.purple.shade400,
    Colors.cyan.shade300,
    Colors.cyan.shade400,
    Colors.teal.shade300,
    Colors.teal.shade400,
    Colors.pink.shade300,
    Colors.pink.shade400,
  ];
  Random random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        width: 67.5,
        height: 67.5,
        child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => AddNote(),
            ),
          )
              .then((value) {
            if (kDebugMode) {
              print("Calling Set  State!");
            }
            setState(() {});
          });
        },
        backgroundColor: Colors.grey.shade700,
        child: const Icon(
          Icons.add,
          color: Colors.white70,
          size: 50,
        ),
      ),
      ),
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: ref.orderBy('created', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "You have no Saved Notes!",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                Color bg = myColors[random.nextInt(14)];
                Map<dynamic, dynamic>? data =
                    snapshot.data?.docs[index].data() as Map<dynamic, dynamic>;
                ;
                DateTime mydateTime =
                    data['created']?.toDate() ?? DateTime.now();
                String formattedTime =
                    DateFormat.yMMMd().add_jm().format(mydateTime);

                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => ViewNote(
                          data,
                          formattedTime,
                          snapshot.data!.docs[index].reference,
                        ),
                      ),
                    )
                        .then((value) {
                      setState(() {});
                    });
                  },
                  child: Card(
                    color: bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${data['title'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 30.0,
                              fontFamily: "lato",
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          //
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontFamily: "lato",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("Loading..."),
            );
          }
        },
      ),
    );
  }
}
