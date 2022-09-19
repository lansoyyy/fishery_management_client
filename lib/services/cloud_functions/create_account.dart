import 'package:cloud_firestore/cloud_firestore.dart';

Future createAccount(String username, String password, String name,
    String contactNumber, String address, String profilePicture) async {
  final docUser = FirebaseFirestore.instance.collection('Farmers').doc();

  final json = {
    'username': username,
    'password': password,
    'name': name,
    'contactNumber': contactNumber,
    'address': address,
    'profilePicture': profilePicture,
    'id': docUser.id,
  };

  await docUser.set(json);
}
