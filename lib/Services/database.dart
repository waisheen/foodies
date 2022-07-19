import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference userInformation =
      FirebaseFirestore.instance.collection('UserInfo');

  Future addUser(String name, int contact, String email, String role) async {
    return await userInformation.doc(uid).set({
      'name': name,
      'contact': contact,
      'email': email,
      'role': role,
    });
  }

  //Add request for sellers
  Future addRequest(String name, String contact, String email, String sellerID,
      List<String> shops) async {
    return await FirebaseFirestore.instance.collection('Request').doc(uid).set({
      'sellerID': sellerID,
      'shops': shops,
      'name': name,
      'contact': contact,
      'email': email
    });
  }

  //Update user details
  Future updateUser(String name, int contact) async {
    return await userInformation.doc(uid).update({
      'name': name,
      'contact': contact,
    });
  }
}

class Database {
  final String collection;
  Database({required this.collection});
  late final CollectionReference databaseInformation =
      FirebaseFirestore.instance.collection(collection);
}
