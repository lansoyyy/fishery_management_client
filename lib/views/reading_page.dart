import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fishery_management_client/utils/colors.dart';
import 'package:fishery_management_client/widgets/drawer_widget.dart';
import 'package:fishery_management_client/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ReadingPage extends StatelessWidget {
  ReadingPage({Key? key}) : super(key: key);

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: TextRegular(
            text: 'Temperature Readings', fontSize: 18, color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Temp')
              .where('username', isEqualTo: box.read('username'))
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print('error');
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('waiting');
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                )),
              );
            }

            final data = snapshot.requireData;
            return ListView.builder(
                itemCount: snapshot.data?.size ?? 0,
                itemBuilder: (context, index) {
                  DateTime created = data.docs[index]['dateTime'].toDate();

                  String formattedTime =
                      DateFormat.yMMMd().add_jm().format(created);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Card(
                        child: ListTile(
                      title: TextBold(
                          text: data.docs[index]['temp'] + '°C',
                          fontSize: 14,
                          color: Colors.black),
                      subtitle: TextRegular(
                          text: formattedTime,
                          fontSize: 12,
                          color: Colors.grey),
                      trailing: IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('Temp')
                              .doc(data.docs[index].id)
                              .delete();
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    )),
                  );
                });
          }),
    );
  }
}
