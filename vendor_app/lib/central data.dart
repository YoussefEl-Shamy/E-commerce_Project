import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import './models/restaurant model.dart';
import './models/table model.dart';

class CentralData {
  static getCategories(List<String> foodCategories) async {
    final String categoryUrl =
        "https://e-commerce-project-f189b-default-rtdb.firebaseio.com/category.json";
    try {
      final http.Response ref = await http.get(categoryUrl);
      final extractedData = json.decode(ref.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        foodCategories.add(prodData['Barbecue']);
        foodCategories.add(prodData['Desserts']);
        foodCategories.add(prodData['Fast food']);
        foodCategories.add(prodData['Fried Chicken']);
        foodCategories.add(prodData['Pastries']);
        foodCategories.add(prodData['Sea food']);
        foodCategories.add(prodData['Vegan']);
      });
      print(foodCategories);
    } catch (error) {
      throw (error);
    }
  }

  static getRestaurants(List<Restaurant> restaurants) async {
    final String restaurantUrl =
        "https://e-commerce-project-f189b-default-rtdb.firebaseio.com/restaurant.json";
    try {
      final http.Response ref = await http.get(restaurantUrl);
      final extractedData = json.decode(ref.body) as Map<String, dynamic>;
      extractedData.forEach((prodId, prodData) {
        var _isExist = restaurants.firstWhere((element) => element.id == prodId,
            orElse: () => null);

        if (_isExist == null) {
          restaurants.add(
            Restaurant(
              id: prodId,
              name: prodData['name'],
              description: prodData['description'],
              category: prodData['category'],
              numOfTables: prodData['tablesNumber'],
              imageFileUrl: prodData['imageUrl'],
              position: prodData['position'],
            ),
          );
        }
        print(prodId);
      });
    } catch (error) {
      throw (error);
    }
  }

  static getRestaurantTableOfficial(List<TableModel> tables) {
    for (int i = 0; i < tables.length; i++) {
      if (tables[i].availability == false) {
        switch (tables[i].numOfSeats) {
          case 1:
            TableModel(
              index: tables[i].index,
              numOfSeats: tables[i].numOfSeats,
              availability: false,
              tableImage:
              Image.asset("assets/images/tables/not_available_1.jpg"),
            );
            break;
          case 2:
            TableModel(
                index: tables[i].index,
                numOfSeats: tables[i].numOfSeats,
                availability: false,
                tableImage:
                Image.asset("assets/images/tables/not_available_2.jpg"));
            break;
          case 3:
            TableModel(
                index: tables[i].index,
                numOfSeats: tables[i].numOfSeats,
                availability: false,
                tableImage:
                Image.asset("assets/images/tables/not_available_3.jpg"));
            break;
          case 4:
            TableModel(
                index: tables[i].index,
                numOfSeats: tables[i].numOfSeats,
                availability: false,
                tableImage:
                Image.asset("assets/images/tables/not_available_4.jpg"));
            break;
          case 5:
            TableModel(
                index: tables[i].index,
                numOfSeats: tables[i].numOfSeats,
                availability: false,
                tableImage:
                Image.asset("assets/images/tables/not_available_5.jpg"));
            break;
          case 6:
            TableModel(
                index: tables[i].index,
                numOfSeats: tables[i].numOfSeats,
                availability: false,
                tableImage:
                Image.asset("assets/images/tables/not_available_6.jpg"));
            break;
        }
      } else {
        TableModel(
            index: tables[i].index,
            numOfSeats: tables[i].numOfSeats,
            availability: true,
            tableImage: Image.asset("assets/images/tables/available.jpg"));
      }
    }
  }

  static List<TableModel> getRestaurantTablesDummy(double tablesNumber) {
    List<TableModel> dummyTables = [];
    for (int i = 0; i < tablesNumber; i++) {
      dummyTables.add(TableModel(
        index: i+1,
        id: "MX $i",
        numOfSeats: 6,
        availability: true,
        tableImage: Image.asset("assets/images/tables/available.jpg",
        fit: BoxFit.cover,),
      ));
    }
    return dummyTables;
  }
}
