import 'package:flutter/material.dart';
import '../central data.dart';

class TablesScreen extends StatelessWidget {
  final String id;
  final double tablesNumber;
  final String rName;

  const TablesScreen({
    @required this.id,
    @required this.tablesNumber,
    @required this.rName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rName),
      ),
      body: GridView(
        children: CentralData.getRestaurantTablesDummy(tablesNumber)
            .map((table) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)),
              child: table.tableImage
            ),
            Positioned(
              bottom: 20,
              right: 10,
              child: Container(
                width: 145,
                color: Colors.black54,
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                child: Text(
                  "${table.index}",
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
        ),).toList(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
        ),
      ),
    );
  }
}
