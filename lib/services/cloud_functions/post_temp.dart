import 'package:cloud_firestore/cloud_firestore.dart';

Future postTemp(
    String username,
    String password,
    String name,
    String contactNumber,
    String address,
    String profilePicture,
    String time,
    String temp,
    String pondName,
    String pondLocation) async {
  final docUser = FirebaseFirestore.instance.collection('Temp').doc();

  final json = {
    'username': username,
    'password': password,
    'name': name,
    'contactNumber': contactNumber,
    'address': address,
    'profilePicture': profilePicture,
    'id': docUser.id,
    'time': time,
    'temp': temp,
    'pondName': pondName,
    'pondLocation': pondLocation,
  };

  await docUser.set(json);
}
