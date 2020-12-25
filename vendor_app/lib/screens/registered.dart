import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/widgets/main%20drawer.dart';


class Registered extends StatelessWidget {
  final id;

  Registered(this.id);

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
      home: RegisteredFul(),
    );
  }
}

class RegisteredFul extends StatefulWidget {
  @override
  _RegisteredFulState createState() => _RegisteredFulState();
}

class _RegisteredFulState extends State<RegisteredFul> {
  SharedPreferences preferences;
  String id;
  getID()async{
    preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString('id');
    });
  }

  @override
  Widget build(BuildContext context) {
    getID();
    return Scaffold(
      appBar: AppBar(
        title: Text("Data"),
      ),
      body: Container(
        child: Center(
          child: Text(id),
        ),
      ),
      drawer: MainDrawer(),
    );
  }
}

