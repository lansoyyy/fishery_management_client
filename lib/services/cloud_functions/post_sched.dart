import 'package:cloud_firestore/cloud_firestore.dart';

Future postSched(
  String username,
  String pondName,
  String sched,
) async {
  final docUser = FirebaseFirestore.instance.collection('Sched').doc();

  final json = {
    'username': username,
    'sched': sched,
    'id': docUser.id,
    'pondName': pondName,
    'dateTime': DateTime.now()
  };

  await docUser.set(json);
}
