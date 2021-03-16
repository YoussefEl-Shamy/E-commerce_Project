import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vendor_app/models/restaurant%20model.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vendor_app/screens/restaurant%20details.dart';

String imageFileUrl;
String name;
String category;
String id;
List<Restaurant> rList;

class RestaurantItem extends StatelessWidget {
  final String imageFileUrl;
  final String name;
  final String category;
  final String id;
  final double tablesNumber;
  final List<Restaurant> rList;

  RestaurantItem({
    this.imageFileUrl,
    this.name,
    this.category,
    this.id,
    this.tablesNumber,
    this.rList,
  });

  int timeSlot = 0;

  List<String> timeSlotsList = [];

  getTimeSlots(String id) async{
    final String restaurantUrl =
        "https://e-commerce-project-f189b-default-rtdb.firebaseio.com/restaurant.json";
    try {
      final http.Response ref = await http.get(restaurantUrl);
      final extractedData = json.decode(ref.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        if(prodId == id){
          for(int i = 0; i < 10; i++){
            timeSlotsList.add(prodData['timeSlotsList'][i].toString());
          }
        }
      });
    } catch(error){
      print("H%A");
      throw (error);
    }
  }

  bool minutesIsMinus = false;
  timeDifference(TimeOfDay ft, TimeOfDay st){
    int minutes = 0;
    if(st.minute - ft.minute < 0){
      minutesIsMinus = true;
      minutes = ft.minute - st.minute;
    } else {
      minutes = st.minute - ft.minute;
    }
    TimeOfDay newTime = st.replacing(
        hour: st.hour - ft.hour,
        minute: minutes,
    );
    timeSlot = minutesIsMinus? newTime.hour * 60 - newTime.minute : newTime.hour * 60 + newTime.minute;
    print("TIME SLOT AHE: $timeSlot");
    minutesIsMinus = false;
    print(timeSlot);
  }

  selectRestaurant(BuildContext ctx, String id) {
    getTimeSlots(id).then((_){
      print("h5a 1");
      TimeOfDay firstTime = TimeOfDay(hour:int.parse(timeSlotsList[0].split(":")[0]),minute: int.parse(timeSlotsList[0].split(":")[1].substring(0, 2)));
      print(firstTime.format(ctx));
      TimeOfDay secondTime = TimeOfDay(hour:int.parse(timeSlotsList[1].split(":")[0]),minute: int.parse(timeSlotsList[1].split(":")[1].substring(0, 2)));
      print(secondTime.format(ctx));
      timeDifference(firstTime, secondTime);
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        print("Time Slot Before send it to tables screen: $timeSlot");
        return TablesScreen(
          id: id,
          tablesNumber: tablesNumber,
          rName: name,
          timeSlot: timeSlot,
          timeSlotsList: timeSlotsList,
          dateTime_now: DateTime.now(),
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        selectRestaurant(context, id);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Image.network(
                    imageFileUrl,
                    height: 215,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Container(
                    width: 300,
                    color: Colors.black54,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(.0),
              child: Column(
                children: [
                  Container(
                    color: Theme.of(context).accentColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 18,
                            color: Colors.white,
                          ),
                          Text(
                            "$category",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.format_quote,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Icon(Icons.deck),
                              Text(
                                " Details",
                                style: TextStyle(),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          selectRestaurant(context, id);
                        },
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              Text(
                                " Delete",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          showDeletingAlert(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  showDeletingAlert(BuildContext ctx) {
    AlertDialog dialog = AlertDialog(
      content: Text(
        'Do you really want to delete $name restaurant ?',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            deleteRestaurant(ctx);
            Navigator.pop(ctx);
          },
          child: Text(
            "Delete",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: Text(
            "Deny",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
    showDialog(
      context: ctx,
      child: dialog,
    );
  }

  deleteRestaurant(BuildContext context) async {
    final String restaurantUrl =
        "https://e-commerce-project-f189b-default-rtdb.firebaseio.com/restaurant/$id.json";
    final rIndex = rList.indexWhere((element) => element.id == id);
    var restaurantItem = rList[rIndex];
    rList.removeAt(rIndex);

    deleteImage(restaurantItem);

    var res = await http.delete(restaurantUrl);
    if (res.statusCode >= 400) {
      rList.insert(rIndex, restaurantItem);
      Toast.show(
        "Could not delete the restaurant!",
        context,
        duration: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      restaurantItem = null;
      Toast.show(
        "The restaurant has been removed successfully.",
        context,
        duration: 5,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
      );
    }
  }

  deleteImage(Restaurant restaurant) async {
    if (restaurant.imageFileUrl != null) {
      var firebaseStorageRef = await FirebaseStorage.instance
          .getReferenceFromUrl(restaurant.imageFileUrl);

      await firebaseStorageRef.delete();
    }
  }
}

class RestaurantItemFul extends StatefulWidget {
  final String imageFileUrl;
  final String name;
  final String category;
  final String id;
  final List<Restaurant> rList;

  RestaurantItemFul(
    this.imageFileUrl,
    this.name,
    this.category,
    this.id,
    this.rList,
  );

  @override
  _RestaurantItemFulState createState() => _RestaurantItemFulState(
        imageFileUrl,
        name,
        category,
        id,
        rList,
      );
}

class _RestaurantItemFulState extends State<RestaurantItemFul> {
  final String imageFileUrl;
  final String name;
  final String category;
  final String id;
  final List<Restaurant> rList;

  _RestaurantItemFulState(
    this.imageFileUrl,
    this.name,
    this.category,
    this.id,
    this.rList,
  );

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
