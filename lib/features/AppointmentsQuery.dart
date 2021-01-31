import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class QueryFirebase{

  todaysEvents() {
    print(DateTime.now());
    return FirebaseFirestore.instance
        .collection('events')
        .where('event_date',
        isEqualTo: DateFormat('dd/MM/yyyy').format(DateTime.now()))
        .get();
  }

  getCurrentCustomerData(String uidOfSelectedCustomer) {
    return FirebaseFirestore.instance
        .collection('userData')
        .doc(uidOfSelectedCustomer)
        .snapshots();
  }

  getLocation(String uidOfSelectedCustomer){
    return FirebaseFirestore.instance.collection('Location').doc(uidOfSelectedCustomer).get();
  }

}