import 'package:flutter/material.dart';
import './screens/home.dart';
import './screens/restaurant%20registration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  String id = preferences.getString('id');
  var isRegistered = false;
  if(id != null){
    isRegistered = true;
  }

  runApp(isRegistered? Home(): MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.indigo,
        canvasColor: Color.fromRGBO(255, 254, 229, 1),
        fontFamily: 'Raleway',
      ),
      home: RestaurantRegistration(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title});

  final Text title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RestaurantRegistration(),
    );
  }
}
