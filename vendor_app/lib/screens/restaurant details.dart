import 'package:flutter/material.dart';
import '../central data.dart';
import '../models/table model.dart';
import '../widgets/loading.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

String gID;
String gRName;
double gTablesNumber;
int gTimeSlot;
List<String> gTimeSlotsList;
DateTime gDateTime_now;

class RestaurantDetails extends StatefulWidget {
  @override
  _RestaurantDetailsState createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  String rName;
  List<TableModel> tables = [];
  List<TableModel> finalTables = [];
  bool _isLoading = true;
  bool _isFetching = true;
  var gridViewController = ScrollController();
  int timeSlot = gTimeSlot;
  int tablesToBeDeleted = 0;
  int comparisonCounter = 0;
  getRestaurantTablesInOrder() {
    print("It is just a fucking Global timeSlot: $gTimeSlot");
    setState(() {
      tables.clear();
      finalTables.clear();
      CentralData.getRestaurantTableOfficial(tables, gID).then((_) {
        var size = gTablesNumber;
        for (int i = 0; i < size; i++) {
          finalTables.add(
            TableModel(
              tID: "0",
              rID: gID,
              numOfSeats: 6,
              index: i,
              availability: true,
              time: "",
              date: "",
              tableImage: Image.asset("assets/images/tables/available.jpg"),
            ),
          );
        }
        for (int i = 0; i < finalTables.length; i++) {
          for (int j = 0; j < tables.length; j++) {
            if (i == tables[j].index) {
              finalTables[i] = tables[j];
            }
          }
        }

        /*for (int i = 0; i < tables.length; i++) {
          TimeOfDay time13 = TimeOfDay(
              hour: int.parse(tables[i].time.split(":")[0]),
              minute: int.parse(tables[i].time.split(":")[1].substring(0, 2)));

          if (tables[i].time.substring(5).trimLeft() == "PM") {
            time13 = TimeOfDay(hour: time13.hour + 12, minute: time13.minute);
          } else if ((tables[i].time.substring(0, 2) == "12" &&
              tables[i].time.substring(5).trimLeft() == "AM")) {
            time13 = TimeOfDay(hour: time13.hour - 12, minute: time13.minute);
          }

          if (DateTime.parse(tables[i].date).difference(DateTime.now()).inDays < 0) {
            tablesToBeDeleted++;
          } else if (timeDifference(time13, TimeOfDay.now()) > gTimeSlot &&
              DateTime.parse(tables[i].date)
                  .difference(DateTime.now())
                  .inDays == 0) {
            tablesToBeDeleted++;
          }
        }*/

        print("D7Q part |");
        print(tables.length);
        for (int i = 0; i < tables.length; i++) {
          print("D7Q part ||");
          print("Tables to be deleted $tablesToBeDeleted");
          print(
              DateTime.parse(tables[i].date).difference(DateTime.now()).inDays);

          TimeOfDay time12 = TimeOfDay(
              hour: int.parse(tables[i].time.split(":")[0]),
              minute: int.parse(tables[i].time.split(":")[1].substring(0, 2)));

          if (tables[i].time.substring(5).trimLeft() == "PM") {
            time12 = TimeOfDay(hour: time12.hour + 12, minute: time12.minute);
          } else if ((tables[i].time.substring(0, 2) == "12" &&
              tables[i].time.substring(5).trimLeft() == "AM")) {
            time12 = TimeOfDay(hour: time12.hour - 12, minute: time12.minute);
          }

          if (DateTime.parse(tables[i].date).difference(DateTime.now()).inDays < 0) {
            deleteTable(i).then((_){
              setState(() {
                comparisonCounter++;
              });
            });
          } else if (timeDifference(time12, TimeOfDay.now()) > gTimeSlot &&
              DateTime.parse(tables[i].date)
                      .difference(DateTime.now())
                      .inDays == 0) {
            deleteTable(i).then((_){
              setState(() {
                comparisonCounter++;
              });
            });
          }
          /*print("ComparisonCounter $comparisonCounter");
          if(comparisonCounter == tablesToBeDeleted ){
            setState(() {
              _isLoading = false;
              _isFetching = false;
              print("kkdssjdnlsjdnvus7535476325465234153242     isLoading is: $_isLoading");
              print("kkdssjdnlsjdnvus7535476325465234153242     isFetching is: $_isFetching");
            });
          }*/
        }
        setState(() {
          _isLoading = false;
          _isFetching = false;
        });
      });
    });
  }

  deleteTable(int i) async {
    final String tableUrl =
        "https://e-commerce-project-f189b-default-rtdb.firebaseio.com/Table/${tables[i].tID}.json";

    await http.delete(tableUrl);
  }

  bool minutesIsMinus = false;
  int resultOfDifference = 0;

  int timeDifference(TimeOfDay ft, TimeOfDay st) {
    try {
      int minutes = 0;
      if (st.minute - ft.minute < 0) {
        minutesIsMinus = true;
        minutes = ft.minute - st.minute;
      } else {
        minutes = st.minute - ft.minute;
      }
      TimeOfDay newTime = st.replacing(
        hour: st.hour - ft.hour,
        minute: minutes,
      );
      resultOfDifference = minutesIsMinus
          ? newTime.hour * 60 - newTime.minute
          : newTime.hour * 60 + newTime.minute;
      minutesIsMinus = false;
      print("resultOfDifference is: $resultOfDifference");
      return resultOfDifference < 0 ? 0 : resultOfDifference;
    } catch (error) {
      return 0;
    }
  }

  Timer _timer;

  int counter = 0;
  int numOfFinishedSlots = 0;
  int timeSlotTemp;
  bool increaseFirstTime = true;
  int firstAM = -1;

  toggleAvailability() {
    numOfFinishedSlots = 0;
    if (gTimeSlotsList[0].substring(5).trimLeft() == "PM") {
      for (int i = 0; i < gTimeSlotsList.length; i++) {
        if (gTimeSlotsList[i].substring(5).trimLeft() == "AM") {
          firstAM = i;
          print("First time from AM is: ${gTimeSlotsList[i]}");
          break;
        }
      }
    }

    for (int i = 0; i < gTimeSlotsList.length; i++) {
      TimeOfDay timeFromList;

      print(
          "tIMEfROMlIST BTA3 EL TRABIZA: ${TimeOfDay(hour: int.parse(gTimeSlotsList[i].split(":")[0]), minute: int.parse(gTimeSlotsList[i].split(":")[1].substring(0, 2)))}");
      timeFromList = TimeOfDay(
          hour: int.parse(gTimeSlotsList[i].split(":")[0]),
          minute: int.parse(gTimeSlotsList[i].split(":")[1].substring(0, 2)));
      print("tIMEfROMlIST BEFORE ADDING 12 HOURS: $timeFromList");
      if (gTimeSlotsList[i].substring(5).trimLeft() == "PM") {
        print("From if");
        print("tIMEfROMlIST.HOUR NAFSHA: ${timeFromList.hour}");
        print("tIMEfROMlIST.HOUR NAFSHA: ${timeFromList.hour + 12}");
        timeFromList = TimeOfDay(
            hour: timeFromList.hour + 12, minute: timeFromList.minute);
        print(
            "tIMEfROMlIST AFTER ADDING 12 HOURS WITHOUT FORMAT: $timeFromList");
        print("tIMEfROMlIST AFTER ADDING 12 HOURS: $timeFromList");
      } else if ((gTimeSlotsList[i].substring(0, 2) == "12" &&
          gTimeSlotsList[i].substring(5).trimLeft() == "AM")) {
        print("From else if");
        print("tIMEfROMlIST.HOUR NAFSHA: ${timeFromList.hour}");
        print("tIMEfROMlIST.HOUR NAFSHA: ${timeFromList.hour - 12}");
        timeFromList = TimeOfDay(
            hour: timeFromList.hour - 12, minute: timeFromList.minute);
        print(
            "tIMEfROMlIST AFTER ADDING 12 HOURS WITHOUT FORMAT: $timeFromList");
        print("tIMEfROMlIST AFTER ADDING 12 HOURS: $timeFromList");
      } else {
        print("From else");
        timeFromList = TimeOfDay(
            hour: int.parse(gTimeSlotsList[i].split(":")[0]),
            minute: int.parse(gTimeSlotsList[i].split(":")[1].substring(0, 2)));
        print("tIME FROM LIST: $timeFromList");
      }

      print("It is just a fucking timeSlot FROM TOGGLE FUNCTION: $timeSlot");

      TimeOfDay lastAppointmentInRestaurantToServe = TimeOfDay(
          hour: int.parse(gTimeSlotsList[9].split(":")[0]),
          minute: int.parse(gTimeSlotsList[9].split(":")[1].substring(0, 2)));

      if (gTimeSlotsList[9].substring(5).trimLeft() == "PM") {
        print("From if");
        print(
            "lastAppointmentInRestaurantToServe.HOUR NAFSHA: ${lastAppointmentInRestaurantToServe.hour}");
        print(
            "lastAppointmentInRestaurantToServe.HOUR NAFSHA: ${lastAppointmentInRestaurantToServe.hour + 12}");
        lastAppointmentInRestaurantToServe = TimeOfDay(
            hour: lastAppointmentInRestaurantToServe.hour + 12,
            minute: lastAppointmentInRestaurantToServe.minute);
        print(
            "lastAppointmentInRestaurantToServe AFTER ADDING 12 HOURS WITHOUT FORMAT: $lastAppointmentInRestaurantToServe");
        print(
            "lastAppointmentInRestaurantToServe AFTER ADDING 12 HOURS: $lastAppointmentInRestaurantToServe");
      } else if ((gTimeSlotsList[9].substring(0, 2) == "12" &&
          gTimeSlotsList[9].substring(5).trimLeft() == "AM")) {
        print("From else if");
        print(
            "lastAppointmentInRestaurantToServe.HOUR NAFSHA: ${lastAppointmentInRestaurantToServe.hour}");
        print(
            "lastAppointmentInRestaurantToServe.HOUR NAFSHA: ${lastAppointmentInRestaurantToServe.hour - 12}");
        lastAppointmentInRestaurantToServe = TimeOfDay(
            hour: lastAppointmentInRestaurantToServe.hour - 12,
            minute: lastAppointmentInRestaurantToServe.minute);
        print(
            "lastAppointmentInRestaurantToServe AFTER ADDING 12 HOURS WITHOUT FORMAT: $lastAppointmentInRestaurantToServe");
        print(
            "lastAppointmentInRestaurantToServe AFTER ADDING 12 HOURS: $lastAppointmentInRestaurantToServe");
      } else {
        print("From else");
        lastAppointmentInRestaurantToServe = TimeOfDay(
            hour: int.parse(gTimeSlotsList[9].split(":")[0]),
            minute: int.parse(gTimeSlotsList[9].split(":")[1].substring(0, 2)));
        print(
            "lastAppointmentInRestaurantToServe: $lastAppointmentInRestaurantToServe");
      }

      TimeOfDay firstAppointmentInRestaurantToServe = TimeOfDay(
          hour: int.parse(gTimeSlotsList[0].split(":")[0]),
          minute: int.parse(gTimeSlotsList[0].split(":")[1].substring(0, 2)));

      if (gTimeSlotsList[0].substring(5).trimLeft() == "PM") {
        print("From if");
        print(
            "firstAppointmentInRestaurantToServe.HOUR NAFSHA: ${firstAppointmentInRestaurantToServe.hour}");
        print(
            "firstAppointmentInRestaurantToServe.HOUR NAFSHA: ${firstAppointmentInRestaurantToServe.hour + 12}");
        firstAppointmentInRestaurantToServe = TimeOfDay(
            hour: firstAppointmentInRestaurantToServe.hour + 12,
            minute: firstAppointmentInRestaurantToServe.minute);
        print(
            "firstAppointmentInRestaurantToServe AFTER ADDING 12 HOURS WITHOUT FORMAT: $firstAppointmentInRestaurantToServe");
        print(
            "firstAppointmentInRestaurantToServe AFTER ADDING 12 HOURS: $firstAppointmentInRestaurantToServe");
      } else if ((gTimeSlotsList[0].substring(0, 2) == "12" &&
          gTimeSlotsList[0].substring(5).trimLeft() == "AM")) {
        print("From else if");
        print(
            "firstAppointmentInRestaurantToServe.HOUR NAFSHA: ${firstAppointmentInRestaurantToServe.hour}");
        print(
            "firstAppointmentInRestaurantToServe.HOUR NAFSHA: ${firstAppointmentInRestaurantToServe.hour - 12}");
        firstAppointmentInRestaurantToServe = TimeOfDay(
            hour: firstAppointmentInRestaurantToServe.hour - 12,
            minute: firstAppointmentInRestaurantToServe.minute);
        print(
            "firstAppointmentInRestaurantToServe AFTER ADDING 12 HOURS WITHOUT FORMAT: $firstAppointmentInRestaurantToServe");
        print(
            "firstAppointmentInRestaurantToServe AFTER ADDING 12 HOURS: $firstAppointmentInRestaurantToServe");
      } else {
        print("From else");
        firstAppointmentInRestaurantToServe = TimeOfDay(
            hour: int.parse(gTimeSlotsList[0].split(":")[0]),
            minute: int.parse(gTimeSlotsList[0].split(":")[1].substring(0, 2)));
        print(
            "firstAppointmentInRestaurantToServe: $firstAppointmentInRestaurantToServe");
      }

      print("lasTAppointment: $lastAppointmentInRestaurantToServe");
      print("Diff between lasTAppointment and NOW: "
          "${timeDifference(lastAppointmentInRestaurantToServe, TimeOfDay.now())}");

      if (timeDifference(lastAppointmentInRestaurantToServe,
              firstAppointmentInRestaurantToServe) >
          0) {
        print("We crossed first condition");
        TimeOfDay timeOfDay_now_24 = TimeOfDay.now();
        print(
            "if(i >= firstAM && firstAM != -1) that condition is: ${i >= firstAM && firstAM != -1}");
        if (i >= firstAM && firstAM != -1) {
          timeOfDay_now_24 = TimeOfDay(
              hour: TimeOfDay.now().hour + 24, minute: TimeOfDay.now().minute);
          print("timeOfDay_now_24 is: $timeOfDay_now_24");
          print("increaseFirstTime is: $increaseFirstTime");

          lastAppointmentInRestaurantToServe = TimeOfDay(
              hour: lastAppointmentInRestaurantToServe.hour + 24,
              minute: lastAppointmentInRestaurantToServe.minute);
          print(
              "last Appointment after increase it by 24 is: $lastAppointmentInRestaurantToServe");

          print(
              "1.$i-timeDifference(TimeOfDay.now(), timeFromList) > 0 is: ${timeDifference(TimeOfDay.now(), timeFromList) > 0}");
          print(
              "2.$i-timeDifference(lastAppointmentInRestaurantToServe, timeOfDay_now_24) == 0 is: ${timeDifference(lastAppointmentInRestaurantToServe, timeOfDay_now_24) == 0}");
          print(
              "${timeDifference(lastAppointmentInRestaurantToServe, timeOfDay_now_24)}");
          print(
              "3.$i-timeDifference(timeOfDay_now_24, firstAppointmentInRestaurantToServe) == 0 is: ${timeDifference(timeOfDay_now_24, firstAppointmentInRestaurantToServe) == 0}");
          print("timeFormList is: $timeFromList");
          if (timeDifference(TimeOfDay.now(), timeFromList) > 0 &&
              (timeDifference(lastAppointmentInRestaurantToServe, timeOfDay_now_24) == 0
                  && timeDifference(timeOfDay_now_24, firstAppointmentInRestaurantToServe) == 0)) {
            print("We should get here at least one time when 3 conditions are 'true'");
            int result = timeDifference(TimeOfDay.now(), timeFromList);
            timeSlotTemp = timeSlot;
            print("tIME SLOT TEMP INSIDE TOGGLE FUNCTION: $timeSlotTemp");
            print("tIME SLOT Before assign result value to it: $timeSlot");
            timeSlot = result;
            print("@#%^&**(((*&^@#_)*&^%#@@!@#%^&^%#@#%^&*(*&^%%^&*( tIME SLOT After assign result value to it: $timeSlot");
            break;
          }
        }
      } else if (timeDifference(TimeOfDay.now(), timeFromList) > 0 &&
          (timeDifference(lastAppointmentInRestaurantToServe, TimeOfDay.now()) == 0 &&
              timeDifference(TimeOfDay.now(), firstAppointmentInRestaurantToServe) == 0)) {
        print("Before calculate result the timeFromList is: $timeFromList");
        print("Before calculate result the TimeOfDay.now() is: ${TimeOfDay.now()}");
        int result = timeDifference(TimeOfDay.now(), timeFromList);
        print("After calculate the result the result is: $result");
        timeSlotTemp = timeSlot;
        print("tIME SLOT TEMP INSIDE TOGGLE FUNCTION: $timeSlotTemp");
        print("tIME SLOT Before assign result value to it: $timeSlot");
        timeSlot = result;
        print("@#%^&**(((*&^@#_)*&^%#@@!@#%^&^%#@#%^&*(*&^%%^&*( tIME SLOT After assign result value to it: $timeSlot");
        break;
      }

      numOfFinishedSlots++;
      print("nUM OF FINISHED SLOTS: $numOfFinishedSlots");
    }
    print("this print may be it is useless but we want to check if we can get here (Before initialize th timer and call cancelReservation function) or not");
    _timer = Timer(Duration(minutes: timeSlot), () => cancelReservation());
    print("Same as the last print but after the initialization");
  }

  cancelReservation() {
    print("Start Canceling @@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%&&&&&&&&&&&&&&&&&&&&&&&");
    print("timer is canceled");
    if (counter == 0) {
      print("if counter == 0 beginning");
      timeSlot = timeSlotTemp;
      print("time slot after getting back its real value from timeSlotTemp: $timeSlot");
      print("if counter == 0 finishing");
    }
    for (int i = 0; i < tables.length; i++) {
      TimeOfDay time = TimeOfDay(
          hour: int.parse(tables[i].time.split(":")[0]),
          minute: int.parse(tables[i].time.split(":")[1].substring(0, 2)));
      print("time is before if and else if: $time");

      if (tables[i].time.substring(5).trimLeft() == "PM") {
        time = TimeOfDay(hour: time.hour + 12, minute: time.minute);
      } else if ((tables[i].time.substring(0, 2) == "12" &&
          tables[i].time.substring(5).trimLeft() == "AM")) {
        time = TimeOfDay(hour: time.hour - 12, minute: time.minute);
      }

      print("time is after if and else if: $time");

      if (timeDifference(time, TimeOfDay.now()) >= timeSlot) {
        deleteTable(i).then((_){
          /*setState(() {
            _isLoading = true;
            _isFetching = true;
            print("kkdssjdnlsjdnvus7535476325465234153242     isLoading is: $_isLoading");
            print("kkdssjdnlsjdnvus7535476325465234153242     isFetching is: $_isFetching");
          });*/
        });
      }
    }
    if (counter < 10 - numOfFinishedSlots) {
      print("Toggle should be called now");
      toggleAvailability();
      print("Toggle is called again");
      setState(() {
        counter++;
      });
      print("+1");
    }
    print("Reservation Canceled");
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  // ignore: must_call_super
  void initState() {
    getRestaurantTablesInOrder();
    print("nUMBER OF TIME SLOTS : ${gTimeSlotsList.length}");
    toggleAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : _isFetching
            ? Loading()
            : Scaffold(
                appBar: AppBar(title: Text(gRName), actions: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      gridViewController.position
                          .jumpTo(gridViewController.position.minScrollExtent);
                    },
                  ),
                ]),
                body: RefreshIndicator(
                  onRefresh: () {
                    setState(() {
                      _isFetching = true;
                    });
                    return getRestaurantTablesInOrder();
                  },
                  child: GridView(
                    controller: gridViewController,
                    children: finalTables
                        .map(
                          (table) => InkWell(
                            child: Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15)),
                                    child: Column(
                                      children: [
                                        table.tableImage,
                                      ],
                                    )),
                                Positioned(
                                  bottom: 20,
                                  right: 10,
                                  child: Container(
                                    width: 145,
                                    color: Colors.black54,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 20),
                                    child: Text(
                                      "Details",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              showDetails(context, table.index, table);
                            },
                          ),
                        )
                        .toList(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                  ),
                ),
              );
  }

  showDetails(BuildContext ctx, int index, TableModel chosenTable) {
    var availability =
        chosenTable.availability ? " Available " : "\n" + " Not Available ";
    var chosenDate = chosenTable.date != ""
        ? chosenTable.date.substring(0, 11) + "\n" + " " + chosenTable.time
        : "No Chosen Date";
    AlertDialog dialog = AlertDialog(
      title: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                "Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ],
          ),
          Divider(
            thickness: 2,
            height: 2,
          ),
        ],
      ),
      content: Container(
        height: 250,
        child: Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Table Number: ",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: " ${index + 1} ",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Theme.of(context).accentColor,
                        fontSize: 22,
                      ),
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Availability: ",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: "$availability",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Theme.of(context).accentColor,
                        fontSize: 22,
                      ),
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Number of Seats: ",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: " ${chosenTable.numOfSeats} ",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Theme.of(context).accentColor,
                        fontSize: 22,
                      ),
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Date: ",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                    TextSpan(
                      text: " $chosenDate ",
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Theme.of(context).accentColor,
                        fontSize: 22,
                      ),
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xffDF000E),
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
}

class TablesScreen extends StatelessWidget {
  String id;
  String rName;
  double tablesNumber;
  int timeSlot;
  List<String> timeSlotsList;
  DateTime dateTime_now;

  TablesScreen(
      {@required id,
      @required rName,
      @required tablesNumber,
      @required timeSlot,
      @required timeSlotsList,
      @required dateTime_now}) {
    this.id = id;
    this.rName = rName;
    this.tablesNumber = tablesNumber;
    this.timeSlot = timeSlot;
    this.timeSlotsList = timeSlotsList;
    this.dateTime_now = dateTime_now;

    gID = this.id;
    gRName = this.rName;
    gTablesNumber = this.tablesNumber;
    gTimeSlot = this.timeSlot;
    gDateTime_now = this.dateTime_now;
    print("TIME SLOT TANY AHOO: ${this.timeSlot}");
    print("gTIME SLOT TANY AHOO: ${gTimeSlot}");
    gTimeSlotsList = this.timeSlotsList;
    print(this.id);
    print(gID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RestaurantDetails(),
    );
  }
}
