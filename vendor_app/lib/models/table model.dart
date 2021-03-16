import 'dart:io';
import 'package:flutter/material.dart';

class TableModel {
  final String tID;
  final Image tableImage;
  final int numOfSeats;
  final int index;
  final String rID;
  final bool availability;
  final String time;
  final String date;

  TableModel({
    @required this.tID,
    @required this.tableImage,
    @required this.numOfSeats,
    @required this.rID,
    @required this.index,
    @required this.availability,
    @required this.time,
    @required this.date,
  });
}
