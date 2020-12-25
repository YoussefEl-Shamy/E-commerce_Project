import 'package:flutter/material.dart';
import 'package:vendor_app/screens/restaurant%20registration.dart';
import '../widgets/loading.dart';

class MainDrawer extends StatelessWidget {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return /*_isLoading? Loading(): */Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Text(
                  "Cooking Up! ",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                Icon(
                  Icons.fireplace,
                  color: Colors.white,
                  size: 55,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.app_registration, size: 26),
            title: Text(
              "Register restaurant.",
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'RobotoCondensed',
              ),
            ),
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (_){
                return RestaurantRegistration();
              }));
            },
          ),
        ],
      ),
    );
  }
}
