import 'package:cloud_firestore/cloud_firestore.dart';

Future postPond(
    String username,
    String password,
    String name,
    String contactNumber,
    String address,
    String profilePicture,
    String pondName,
    String pondLocation,
    String description) async {
  final docUser = FirebaseFirestore.instance.collection('Pond').doc();

  final json = {
    'username': username,
    'password': password,
    'name': name,
    'contactNumber': contactNumber,
    'address': address,
    'profilePicture': profilePicture,
    'id': docUser.id,
    'pondName': pondName,
    'pondLocation': pondLocation,
    'description': description
  };

  await docUser.set(json);
}
