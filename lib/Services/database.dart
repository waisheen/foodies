import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference userInformation = FirebaseFirestore.instance.collection('UserInfo');

  Future addUser(String name, int contact, String email, String role) async {
    return await userInformation.doc(uid).set({
      'name': name,
      'contact': contact,
      'email': email,
      'role': role,
    });
  }

  //get users
}
