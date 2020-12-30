import 'dart:io';
import 'package:flutter/material.dart';

class TableModel {
  final Image tableImage;
  final int numOfSeats;
  final int index;
  final String id;
  final bool availability;

  TableModel({
    @required this.tableImage,
    @required this.numOfSeats,
    @required this.id,
    @required this.index,
    @required this.availability,
  });
}
