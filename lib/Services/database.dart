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
