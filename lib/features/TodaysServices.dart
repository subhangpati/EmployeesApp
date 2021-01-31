import 'dart:io' as platform;
import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employe_services/components/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'AppointmentsQuery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';


String _destinationLati ;
String _destinationLong ;
String originLat ;
String originLong ;


class ServicesForToday extends StatefulWidget {
  @override
  _ServicesForTodayState createState() => _ServicesForTodayState();
}

class _ServicesForTodayState extends State<ServicesForToday> {
  QueryFirebase today ;
  Map<String, dynamic> userDetails = {};


 void getLocation({String uid}) async {
   return await FirebaseFirestore.instance.collection('Location').doc(uid).get().then((value) {
     userDetails.addAll(value.data());
   }).whenComplete(() {
     print('Data has been fetched!!');
     print("${userDetails['latitude']}");
     print("${userDetails['longitude']}");
     setState(() {
       _destinationLati = userDetails['latitude'];        // destination latitude
       _destinationLong = userDetails['longitude'];       // destination longitude
     });
   });
 }

  void currentLocation() async {
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          originLat = position.latitude as String;
          originLong = position.longitude as String ;
        });
  }


  @override
  void initState() {
    super.initState();
    currentLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Today\'s Appointments'),
      body: FutureBuilder(
          future: today.todaysEvents(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot order = snapshot.data.docs[index];
                  String uidOfSelectedCustomer = order['current_userID'];
                  Stream<DocumentSnapshot> dataOfUser =
                  today.getCurrentCustomerData(uidOfSelectedCustomer);
                  getLocation(uid:uidOfSelectedCustomer);
                  return AppointmentCard(
                    userStream: dataOfUser,
                    title: order['title'],
                    date: order['event_date'],
                    time: order['selected_time'],
                    price: order['totalAmount'].toString(),
                    paymentStatus: order['PaymentStatus'],
                    orderStatus : order['orderStatus']
                  );
                });
          }),
    );
  }
}

// ignore: must_be_immutable
class AppointmentCard extends StatefulWidget {
  final String title;
  String paymentStatus;
  final String date;
  final String time;
  final String price;
  final String address;
  final String phoneNumber;
  final String customerName;
  final Stream<DocumentSnapshot> userStream;

  AppointmentCard(
      {this.title,
        this.paymentStatus,
        this.date,
        this.time,
        this.price,
        this.address,
        this.customerName,
        this.userStream,
        this.phoneNumber, orderStatus});

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    List<String> titles = [];
    titles = widget.title.split('/').toList();
    return StreamBuilder(
        stream: widget.userStream,
        builder: (context, snapshot) {
          DocumentSnapshot customerData = snapshot.data;
          if (snapshot.data == null) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          var _chosenValue;
          return InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20.0)), //this right here
                      child: Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerData['fullName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                customerData['address'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                customerData['phoneNo'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Total ₹${widget.price}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: RaisedButton(
                                    onPressed: () {
                                      String number = customerData['phoneNo'];
                                      print(number);
                                      launch(('tel://$number'));
                                    },
                                    child: Text(
                                      'Call',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: const Color(0xFF1BC0C5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(8),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            customerData['fullName'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.all(5.0),
                            height: MediaQuery.of(context).size.height / 15,
                            width: MediaQuery.of(context).size.height / 3,
                            child: ListView.builder(
                              //shrinkWrap: true,
                                itemCount: titles.length,
                                itemBuilder: (context, index) {
                                  return Text(
                                    titles[index],
                                    style:
                                    TextStyle(fontWeight: FontWeight.w500),
                                  );
                                }),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: 5, bottom: 5, right: 20, left: 20),
                            decoration: BoxDecoration(
                                color: widget.paymentStatus == 'PAID'
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              widget.paymentStatus,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(widget.date),
                          Text('${widget.time}:00'),
                          Text('₹ ${widget.price}'),
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                             DropdownButton<String>(
                                value: _chosenValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 20.0, // can be changed, default: 24.0
                                iconEnabledColor: Colors.blue,
                                items: <String>[
                                  'Pending' , 'Finished'
                                ].map<DropdownMenuItem>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String value){
                                  setState((){
                                    _chosenValue = value;

                                  });
                                },
                              ),
                            RaisedButton(
                              padding: const EdgeInsets.all(8.0),
                              textColor: Colors.white,
                              color: Colors.blue,
                              onPressed: ()  {
                               setState(()  {
                                  widget.paymentStatus = _chosenValue ;
                               });
                              },
                              child: new Text("SAVE"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                        child: RaisedButton(
                          child: Text('Load Map'),
                            onPressed: () async {
                              String destination = "$_destinationLati , $_destinationLong";
                              String origin = "$originLat , $originLong";
                              if (platform.Platform.isAndroid) {
                                final AndroidIntent intent = new AndroidIntent(
                                    action: 'action_view',
                                    data: Uri.encodeFull(
                                        "https://www.google.com/maps/dir/?api=1&origin=" +
                                            "$origin" + "&destination=" +
                                            destination +
                                            "&travelmode=driving&dir_action=navigate"),
                                    package: 'com.google.android.apps.maps');
                                await intent.launch();
                              }
                            }),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
