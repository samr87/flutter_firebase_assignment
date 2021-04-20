import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

final firestoreInstance = FirebaseFirestore.instance;

void _addDoc() {
  // You can specify a document name, but since we used random ones while
  // generating our databases, I used an add method that also randomly generates
  // a document name.

  firestoreInstance.collection("users").add({

    'company': "CNS Storage",
    'full_name': "Will"

  }).then((value){

    print(value.id);

  });
}

void _updateDoc() {

  var firebaseUser = FirebaseAuth.instance.currentUser;

  firestoreInstance.collection("user").doc(firebaseUser.uid).update({'company':"None"}).then((_) {
    print("Successfully updated info.");
  });

}

Future _deleteDoc() async{

  var firebaseUser = FirebaseAuth.instance.currentUser;

  debugPrint("uid is " + firebaseUser.toString());
  //CollectionReference users = FirebaseFirestore.instance.collection("users");


  return firestoreInstance.collection("user").doc(firebaseUser.uid).delete().then((value)
      => print("User successfully deleted.")).catchError((error) => print("Failed to delete user: $error"));

}



class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text("Error");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Text("Waiting");
      },
    );
  }
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.green,
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.purple)),
      ),
      home: MyHomePage(title: 'Exam 1'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class GetUserName extends StatelessWidget {
  final String documentId;

  GetUserName(this.documentId);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          return Text("Full Name: ${data['full_name']} ${data['last_name']}");
        }

        return Text("loading");
      },
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {

    return showDialog(

        context: context,

        builder: (context) {

          return AlertDialog(

            title: Text('TextField in Dialog'),

            content: TextField(

              onChanged: (value) {

                setState(() {

                  valueText = value;

                });
              },

              controller: _textFieldController,

              decoration: InputDecoration(hintText: "Text Field in Dialog"),

            ),

            actions: <Widget>[

              ElevatedButton(

                child: Text('Delete'),

                onPressed: () {

                  _deleteDoc();

                  setState(() {

                    Navigator.pop(context);

                  });
                },
              ),

              ElevatedButton(

                child: Text('Update'),

                onPressed: () {

                  _updateDoc();

                  setState(() {

                    codeDialog = valueText;
                    Navigator.pop(context);

                  });
                },
              ),
            ],
          );
        });
  }

  String codeDialog;
  String valueText;

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body:
      StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return GestureDetector(

            onTap: () async{
              //debugPrint();
              _displayTextInputDialog(context);
            },

            child: ListView(

              children: snapshot.data.docs.map((DocumentSnapshot document) {

                return new ListTile(

                  title: new Text(document.data()['full_name']),

                  subtitle: new Text(document.data()['company']),
                );
              }).toList(),
            ),
          );
        },
      ),



      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: FloatingActionButton(

        onPressed: _addDoc,

        tooltip: 'Add',

        child: Icon(Icons.add),

      ),

    );
  }
}
