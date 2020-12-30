import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageFileUrl;
  final double numOfTables;
  final Map<Object, Object> position;

  Restaurant({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.category,
    @required this.numOfTables,
    @required this.imageFileUrl,
    @required this.position,
  });
}
