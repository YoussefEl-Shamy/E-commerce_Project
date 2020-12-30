import 'dart:convert';

import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:vendor_app/screens/home.dart';
import 'package:connectivity/connectivity.dart';
import 'package:toast/toast.dart';
import '../widgets/loading.dart';
import '../central data.dart';
import 'package:intl/intl.dart';

class _RestaurantRegistrationState extends State<RestaurantRegistration>
    with SingleTickerProviderStateMixin {
  var _key = GlobalKey<ScaffoldState>();

  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var numTablesController = TextEditingController();
  var initTimeController = TextEditingController();
  var timeSlotController = TextEditingController();
  String rName = "";
  String rDescription = "";
  double numTables = 0.0;
  String rID = "";
  bool locationIsExist = false;
  bool _isLoading = false;
  bool _isFetching = true;

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;
  TimeOfDay newTime;

  TimeOfDay hoursToTimeOfDay(int hours,int minutes){
    Duration duration = Duration(hours:hours ,minutes: minutes);
    List<String> parts = duration.toString().split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  List<TimeOfDay> timesToServe = [];
  List<String> timesToString = [];

  _selectTime(BuildContext ctx) async {
    picked = await showTimePicker(
      context: ctx,
      initialTime: _time,
    );

    if(picked != null){
      print('${_time.toString()}');
      setState(() {
        timesToServe.clear();
        for(int i=0; i<10; i++){
          _time = picked;
          newTime = TimeOfDay(hour: _time.hour, minute: _time.minute + i * (minutesToBeAdded));
          print("${newTime.format(ctx)}");
          TimeOfDay addedTime = hoursToTimeOfDay(newTime.hour,newTime.minute);
          while(true) {
            if (addedTime.hour >= 24) {
              addedTime = TimeOfDay(
                  hour: addedTime.hour - 24, minute: addedTime.minute);
            } else {
              break;
            }
          }
          timesToServe.add(addedTime);
          timesToString.add("${addedTime.format(ctx)}");
          print("${addedTime.format(ctx)}");
        }
        print(timesToServe);
      });
    }
  }

  updateTimeSlotsList(BuildContext ctx){
    if(picked != null){
      print('${_time.toString()}');
      setState(() {
        timesToServe.clear();
        for(int i=0; i<10; i++){
          _time = picked;
          newTime = TimeOfDay(hour: _time.hour, minute: _time.minute + i * (minutesToBeAdded));
          print("${newTime.format(ctx)}");
          TimeOfDay addedTime = hoursToTimeOfDay(newTime.hour,newTime.minute);
          if(addedTime.hour >= 24){
            addedTime = TimeOfDay(hour: addedTime.hour - 24, minute: addedTime.minute);
          }
          timesToServe.add(addedTime);
          print("${addedTime.format(ctx)}");
        }
        print(timesToServe);
      });
    }
  }


  SharedPreferences preferences;

  List<String> foodCategories = [];

  String currentValue = 'Select';
  String dropdownValue = 'Barbecue';
  String rCategory = 'Barbecue';

  File imageFile;
  String imageFileUrl = "";

  AnimationController animationController;
  Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  Animation rotationAnimation;

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  PermissionStatus imageState;

  Future getImage(BuildContext ctx, ImageSource source) async {
    source == ImageSource.camera
        ? imageState = await Permission.camera.status
        : imageState = await Permission.storage.status;
    if (imageState.isGranted) {
      var tempImage = await ImagePicker.pickImage(
        source: source,
        maxWidth: 450,
        maxHeight: 450,
      );
      setState(() {
        imageFile = tempImage;
      });
    } else {
      AlertDialog dialog = AlertDialog(
        content: Text(
          source == ImageSource.camera
              ? 'This App needs to camera access to get restaurant photo'
              : 'This App needs to gallery access to get restaurant photo',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              setState(() {
                Navigator.pop(ctx);
                AppSettings.openAppSettings();
              });
            },
            child: Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                Navigator.pop(ctx);
              });
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
  }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  void registration(BuildContext ctx) async {
    setState(() {
      _isLoading = true;
    });

    String fileName = basename(imageFile.path);
    print(imageFile.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('Images/').child(fileName);
    await firebaseStorageRef.putFile(imageFile);
    imageFileUrl = await firebaseStorageRef.getDownloadURL();

    final String restaurantUrl =
        "https://e-commerce-project-f189b-default-rtdb.firebaseio.com/restaurant.json";
    http
        .post(restaurantUrl,
            body: json.encode({
              'name': rName,
              'description': rDescription,
              'position': position,
              'tablesNumber': numTables,
              'category': rCategory,
              'imageUrl': imageFileUrl,
              'timeSlotsList': timesToString,
            }))
        .then((id) {
      setState(() {
        rID = json.decode(id.body)['name'];
        setID();
        getID();
        setState(() {
          _isLoading = false;
          registeredCompleted(ctx);
        });
        Navigator.of(ctx).pushReplacement(
          MaterialPageRoute(
            builder: (_) {
              return Home();
            },
          ),
        );
      });
    });
  }

  String lol = "";

  void setID() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString('id', rID);
      preferences.commit();
    });
  }

  void getID() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      lol = preferences.getString('id');
    });
  }

  registeredCompleted(BuildContext context) {
    Toast.show(
      "Your restaurant has been registered successfully.",
      context,
      duration: 5,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
    );
  }

  @override
  void initState() {
    print("############%%%%%%%%%@@@@@@@@@@@@@@@@@   initState");
    CentralData.getCategories(foodCategories).then((_) {
      setState(() {
        _isFetching = false;
      });
    });
    print("############%%%%%%%%%@@@@@@@@@@@@@@@@@   ${foodCategories.length}");
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.3), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.3, end: 1.0), weight: 25.0)
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.5), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.5, end: 1.0), weight: 45.0)
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });

    /*final String categoryUrl =
        "https://e-commerce-project-f189b-default-rtdb.firebaseio.com/category.json";
    http.post(
      categoryUrl,
      body: json.encode({
        'Sea food': "Sea food",
        'Barbecue': "Barbecue",
        'Vegan': "Vegan",
        'Fast food': "Fast food",
        'Pastries': "Pastries",
        'Desserts': "Desserts",
        'Fried Chicken': "Fried Chicken",
      }),
    );*/
  }

  int initVal = 10;
  int minutesToBeAdded = 10;

  List<int> setGetTimeSlots(){
    List<int> timeSlots = [];
    for(int i=0; i<=720; i = i+10){
      timeSlots.add(i);
    }
    return timeSlots;
  }

  void checkInternetConnectivity() async {}

  bool checkAllReqFields() {
    if (rName == "" ||
        rDescription == "" ||
        numTables == 0.0 ||
        imageFile == null ||
        position == null) {
      final sBar = SnackBar(
        content: Text(
          "Please fill all required fields, and select an image",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 5000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      );
      _key.currentState.showSnackBar(sBar);
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _isLoading
        ? Loading()
        : _isFetching
            ? Loading()
            : Scaffold(
                key: _key,
                appBar: AppBar(
                  title: Text(
                    'Registration Form',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: Container(
                  width: size.width,
                  height: size.height,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(8.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                    labelText: "Restaurant Name",
                                    hintText: "Enter your restaurant name",
                                    prefixIcon: Icon(Icons.restaurant),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(60),
                                        borderSide: BorderSide(
                                            color: Colors.redAccent))),
                                keyboardType: TextInputType.text,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  labelText: "Description",
                                  hintText: "Enter restaurant description",
                                  prefixIcon: Icon(Icons.description_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                maxLines: 4,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                controller: numTablesController,
                                decoration: InputDecoration(
                                    labelText: "Number of Tables",
                                    hintText: "Enter number of table",
                                    prefixIcon: Icon(Icons.deck_sharp),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(60),
                                        borderSide: BorderSide(
                                            color: Colors.redAccent))),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: FlatButton(
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: Text(
                                            picked != null? "${(_time).format(context)}": "Pick Time",

                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25)),
                                      color: Theme.of(context).primaryColor,
                                      splashColor: Theme.of(context).accentColor,
                                      onPressed: (){
                                        _selectTime(context);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  DropdownButton<int>(
                                    dropdownColor: Colors.white,
                                    value: initVal,
                                    icon: Icon(
                                      Icons.timer,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                    underline: Container(
                                      height: 2,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    onChanged: (int newValue) {
                                      setState(() {
                                        initVal = newValue;
                                        minutesToBeAdded = newValue;
                                        updateTimeSlotsList(context);
                                        print(minutesToBeAdded);
                                      });
                                    },
                                    items: setGetTimeSlots()
                                        .map<DropdownMenuItem<int>>(
                                            (int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text("$value"),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      color: Colors.deepOrange, width: 1.75),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  value: dropdownValue,
                                  icon: Icon(
                                    Icons.arrow_downward,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  underline: Container(
                                    height: 2,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownValue = newValue;
                                      rCategory = newValue;
                                    });
                                  },
                                  items: foodCategories
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                rCategory == ""
                                    ? rCategory
                                    : "Restaurant Category:  " + rCategory,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 23,
                              ),
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    if (!locationIsExist) {
                                      getCurrentLocation(context);
                                    }
                                  });
                                },
                                child: Text(
                                  locationIsExist && locationStatus.isGranted
                                      ? "Restaurant Location is Saved ✔"
                                      : "Get Restaurant Location +",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                color:
                                    locationIsExist && locationStatus.isGranted
                                        ? Colors.green
                                        : Colors.deepOrange,
                                padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10,
                                ),
                              ),
                              locationIsExist && locationStatus.isGranted
                                  ? RaisedButton.icon(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      onPressed: () {
                                        showAlert(context);
                                      },
                                      color: Colors.red,
                                      label: Text(
                                        'Get the location again',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      icon: Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(""),
                              SizedBox(
                                height: 25,
                              ),
                              showImage(),
                              SizedBox(
                                height: 35,
                              ),
                              FlatButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Container(
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Confirm",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                color: Theme.of(context).accentColor,
                                splashColor: Colors.red,
                                onPressed: () async {
                                  var result =
                                      await Connectivity().checkConnectivity();
                                  if (result == ConnectivityResult.none) {
                                    final sBar = SnackBar(
                                      content: Text(
                                        "You are not connected to the internet",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(milliseconds: 5000),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    );
                                    _key.currentState.showSnackBar(sBar);
                                  } else {
                                    setState(
                                      () {
                                        rName = nameController.text;
                                        rDescription =
                                            descriptionController.text;
                                        if (_isNumeric(
                                            numTablesController.text)) {
                                          numTables = double.parse(
                                              numTablesController.text);
                                        }
                                        if (checkAllReqFields() == true) {
                                          registration(context);
                                        }
                                      },
                                    );
                                  }
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Positioned(
                            right: 30,
                            bottom: 30,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                IgnorePointer(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.0),
                                    height: 150.0,
                                    width: 150.0,
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset.fromDirection(
                                      getRadiansFromDegree(260),
                                      degOneTranslationAnimation.value * 85),
                                  child: Transform(
                                    transform: Matrix4.rotationZ(
                                        getRadiansFromDegree(
                                            rotationAnimation.value))
                                      ..scale(degOneTranslationAnimation.value),
                                    alignment: Alignment.center,
                                    child: CircularBtn(
                                      color: Colors.black,
                                      width: 55,
                                      height: 55,
                                      icon: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                      onClick: () => getImage(
                                          context, ImageSource.gallery),
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset.fromDirection(
                                      getRadiansFromDegree(180),
                                      degTwoTranslationAnimation.value * 85),
                                  child: Transform(
                                    transform: Matrix4.rotationZ(
                                        getRadiansFromDegree(
                                            rotationAnimation.value))
                                      ..scale(degTwoTranslationAnimation.value),
                                    alignment: Alignment.center,
                                    child: CircularBtn(
                                      color: Theme.of(context).accentColor,
                                      width: 55,
                                      height: 55,
                                      icon: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      onClick: () =>
                                          getImage(context, ImageSource.camera),
                                    ),
                                  ),
                                ),
                                CircularBtn(
                                  color: Theme.of(context).primaryColor,
                                  width: 65,
                                  height: 65,
                                  icon: Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white,
                                  ),
                                  onClick: () {
                                    animationController.isCompleted
                                        ? animationController.reverse()
                                        : animationController.forward();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
  }

  Widget showImage() {
    if (imageFile != null) {
      return Image.file(
        imageFile,
        width: 300,
        height: 300,
      );
    } else {
      return FlatButton(
        child: Text(
          "No Image Selected",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration: TextDecoration.underline,
          ),
        ),
        onPressed: () {
          animationController.isCompleted
              ? animationController.reverse()
              : animationController.forward();
        },
      );
    }
  }

  Position position;
  PermissionStatus locationStatus;

  void getCurrentLocation(BuildContext ctx) async {
    locationStatus = await Permission.location.status;
    if (locationStatus.isGranted) {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("$position");
      setState(() {
        locationIsExist = true;
      });
    } else {
      AlertDialog dialog = AlertDialog(
        content: Text(
          'This App needs to location access to get restaurant location',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              setState(() {
                position = null;
                locationIsExist = false;
                Navigator.pop(ctx);
                AppSettings.openAppSettings();
              });
            },
            child: Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                Navigator.pop(ctx);
              });
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
  }

  void showAlert(BuildContext ctx) {
    AlertDialog dialog = AlertDialog(
      content: Text(
        'Do you want to get the restaurant location again (your current location) ?',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            setState(() {
              position = null;
              locationIsExist = false;
              Navigator.pop(ctx);
            });
          },
          child: Text(
            "Yes",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              Navigator.pop(ctx);
            });
          },
          child: Text(
            "No",
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
//Future uploadImage(BuildContext ctx) async {}
}

class RestaurantRegistration extends StatefulWidget {
  _RestaurantRegistrationState createState() => _RestaurantRegistrationState();
}

class CircularBtn extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  const CircularBtn({
    this.width,
    this.height,
    this.color,
    this.icon,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      width: width,
      height: height,
      child: IconButton(
        icon: icon,
        enableFeedback: true,
        onPressed: onClick,
      ),
    );
  }
}
