import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instgram/pages/CreateAccountPage.dart';
import 'package:instgram/pages/EditProfilePage.dart';
import 'package:instgram/pages/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instgram',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        dialogBackgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.white70,
        accentColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/HomePage' : (context) => HomePage(),
        '/CreateAccountPage' : (context) => CreateAccountPage(),
        '/EditProfilePage' : (context) => EditProfilePage(),
      },
    );
  }
}
