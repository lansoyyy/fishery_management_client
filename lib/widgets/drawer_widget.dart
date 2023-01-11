import 'package:fishery_management_client/views/reading_page.dart';
import 'package:fishery_management_client/widgets/text_widget.dart';
import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';

import '../auth/login_page.dart';
import '../utils/colors.dart';
import '../views/home/home_page.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<DrawerWidget> {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Drawer(
        child: ListView(
          padding: const EdgeInsets.only(top: 0),
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: secondaryColor,
              ),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextRegular(
                    text: box.read('contactNumber') ?? '09090104355',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  TextRegular(
                    text: box.read('address') ?? 'Impasugong Bukidnon',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ],
              ),
              accountName: TextBold(
                text: box.read('name') ?? 'Lance Olana',
                fontSize: 14,
                color: Colors.white,
              ),
              currentAccountPicture: Padding(
                padding: const EdgeInsets.all(5.0),
                child: CircleAvatar(
                  minRadius: 50,
                  maxRadius: 50,
                  backgroundImage: NetworkImage(box.read('profilePicture')),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: TextRegular(
                text: 'Home',
                fontSize: 12,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: TextRegular(
                text: 'Temperature Records',
                fontSize: 12,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ReadingPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: TextRegular(
                text: 'Logout',
                fontSize: 12,
                color: Colors.grey,
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text(
                            'Logout Confirmation',
                            style: TextStyle(
                                fontFamily: 'QBold',
                                fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            'Are you sure you want to Logout?',
                            style: TextStyle(fontFamily: 'QRegular'),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                    fontFamily: 'QRegular',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LogInPage()));
                              },
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontFamily: 'QRegular',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
