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

  selectRestaurant(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return TablesScreen(
        id: id,
        tablesNumber: tablesNumber,
        rName: name,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        selectRestaurant(context);
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
                          selectRestaurant(context);
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
