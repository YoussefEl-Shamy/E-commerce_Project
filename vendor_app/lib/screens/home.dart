import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/central%20data.dart';
import 'package:vendor_app/models/restaurant%20model.dart';
import 'package:vendor_app/widgets/loading.dart';
import 'package:vendor_app/widgets/main%20drawer.dart';
import '../widgets/restaurant item.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Home extends StatelessWidget {
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
  List<Restaurant> restaurants = [];
  bool _isFetching = true;
  var listController = ScrollController();
  int _currentItem = 0;
  int _lastItem = 0;

  getID() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString('id');
    });
  }

  /*Stream<List<Restaurant>> _timedCounter() async* {
    /*int _i = 10;
    while (true) {
      if (_i < 0) break;
      await Future.delayed(Duration(seconds: 1));
      yield List<int>.generate(_i--, (i) => i + 1);*/
      int i = restaurants.length;
      while(i < 0) {

      }
    throw Exception('Mission aborted');
  }*/

  @override
  void initState() {
    print("############%%%%%%%%%@@@@@@@@@@@@@@@@@   initState");
    try {
      CentralData.getRestaurants(restaurants).then((_) {
        _isFetching = false;
      });
    } catch (error) {
      print(error);
    }
    print("############%%%%%%%%%@@@@@@@@@@@@@@@@@   ${restaurants.length}");
    super.initState();
  }

  setPositionSharedPreferences(int currentPosition) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble('lastPosition', currentPosition.toDouble());
  }

  double listPosition = 0.0;

  getPositionSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    listPosition = preferences.getDouble('lastPosition');
    return preferences.getDouble('lastPosition');
  }

  printPositionSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    listPosition = preferences.getDouble('lastPosition');
    print("5555555555555555555555     $listPosition");
  }

  @override
  Widget build(BuildContext context) {
    getID();
    return _isFetching
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("My Restaurants"),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    _lastItem = _currentItem;
                    listController.position
                        .jumpTo(listController.position.minScrollExtent);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward_outlined),
                  onPressed: () {
                    getPositionSharedPreferences();
                    if (getPositionSharedPreferences() != null) {
                      print("YES");
                      printPositionSharedPreferences().then((_) {
                        listController.position.animateTo(
                          (36 * 8.55 * listPosition).toDouble(),
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 1000),
                        );
                        print("6666666666666666 $listPosition");
                      });
                    }
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () {
                _isFetching = true;
                return CentralData.getRestaurants(restaurants).then((_) {
                  _isFetching = false;
                });
              },
              child: ListView.builder(
                controller: listController,
                itemBuilder: (ctx, index) {
                  return VisibilityDetector(
                    key: Key(index.toString()),
                    onVisibilityChanged: (VisibilityInfo info) {
                      if (info.visibleFraction == 1)
                        setState(() {
                          _currentItem = index;
                          _currentItem > 1
                              ? setPositionSharedPreferences(_currentItem)
                              : print("Safe place");
                          print(_currentItem);
                        });
                    },
                    child: RestaurantItem(
                      name: restaurants[index].name,
                      imageFileUrl: restaurants[index].imageFileUrl,
                      category: restaurants[index].category,
                      id: restaurants[index].id,
                      tablesNumber: restaurants[index].numOfTables,
                      rList: restaurants,
                    ),
                  );
                },
                itemCount: restaurants.length,
              ),
            ),
            drawer: MainDrawer(),
          );
  }
}
