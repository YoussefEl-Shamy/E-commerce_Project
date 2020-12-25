import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Restaurant {
  final String name;
  final String description;
  final String category;
  final int numOfTables;
  final Future<File> imageFile;
  final Future<Position> position;

  Restaurant({
    @required this.name,
    @required this.description,
    @required this.category,
    @required this.numOfTables,
    @required this.imageFile,
    @required this.position,
  });
}
