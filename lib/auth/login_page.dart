import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cloud_functions/create_account.dart';
import '../views/home/home_page.dart';
import '../widgets/button_widget.dart';
import '../widgets/text_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class LogInPage extends StatefulWidget {
  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  late String myUsername = '';

  late String myPassword = '';

  late String name = '';

  late String contactNumber = '';

  late String address = '';

  late String username = '';

  late String password = '';

  final box = GetStorage();

  var hasLoaded = false;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  late String fileName = '';

  late File imageFile;

  late String imageURL = '';

  Future<void> uploadPicture(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName = path.basename(pickedImage.path);
      imageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: const [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Users/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Users/$fileName')
            .getDownloadURL();

        setState(() {
          hasLoaded = true;
        });

        Navigator.of(context).pop();
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Image.asset(
                'assets/images/logo.png',
                height: 220,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextBold(
                      text: 'Fishery Management',
                      fontSize: 28,
                      color: Colors.black),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: TextFormField(
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Quicksand'),
                  onChanged: (_input) {
                    myUsername = _input;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    labelText: 'Username',
                    labelStyle: const TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.black,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                child: TextFormField(
                  obscureText: true,
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Quicksand'),
                  onChanged: (_input) {
                    myPassword = _input;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_sharp),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.black,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ButtonWidget(
                  onPressed: () {
                    if (box.read('username') == myUsername &&
                        box.read('password') == myPassword) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomePage()));
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(
                                  'Cannot Procceed',
                                  style: TextStyle(
                                      fontFamily: 'QBOLD',
                                      fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Invalid username/password',
                                  style: TextStyle(fontFamily: 'QRegular'),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                          fontFamily: 'Quicksand',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ));
                    }
                  },
                  text: 'Login'),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextRegular(
                    text: 'No Account?',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return Container(
                              color: Colors.grey[100],
                              height: 750,
                              child: SingleChildScrollView(
                                child: SafeArea(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      TextRegular(
                                          text: 'Creating Account',
                                          fontSize: 18,
                                          color: Colors.black),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      hasLoaded == true
                                          ? CircleAvatar(
                                              maxRadius: 50,
                                              minRadius: 50,
                                              backgroundImage:
                                                  NetworkImage(imageURL),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                uploadPicture('gallery');
                                              },
                                              child: const CircleAvatar(
                                                child: Icon(
                                                  Icons.camera,
                                                  color: Colors.black,
                                                ),
                                                maxRadius: 50,
                                                minRadius: 50,
                                                backgroundImage: AssetImage(
                                                    'assets/images/profile.png'),
                                              ),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 10, 50, 10),
                                        child: TextFormField(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Quicksand'),
                                          onChanged: (_input) {
                                            name = _input;
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            labelText: 'Name',
                                            labelStyle: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              color: Colors.black,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 10, 50, 10),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          maxLength: 11,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Quicksand'),
                                          onChanged: (_input) {
                                            contactNumber = _input;
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            labelText: 'Contact Number',
                                            labelStyle: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              color: Colors.black,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 10, 50, 10),
                                        child: TextFormField(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Quicksand'),
                                          onChanged: (_input) {
                                            address = _input;
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            labelText: 'Address',
                                            labelStyle: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              color: Colors.black,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextRegular(
                                        text: 'Login Credentials',
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 10, 50, 10),
                                        child: TextFormField(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Quicksand'),
                                          onChanged: (_input) {
                                            username = _input;
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            labelText: 'Username',
                                            labelStyle: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              color: Colors.black,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 10, 50, 10),
                                        child: TextFormField(
                                          obscureText: true,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Quicksand'),
                                          onChanged: (_input) {
                                            password = _input;
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            labelText: 'Password',
                                            labelStyle: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              color: Colors.black,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      ButtonWidget(
                                          onPressed: () {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Confirmation',
                                                        style: TextStyle(
                                                            fontFamily: 'QBold',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      content: const Text(
                                                        'Account Created Succesfully!',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'QRegular'),
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          onPressed: () {
                                                            box.write(
                                                                'name', name);
                                                            box.write(
                                                                'contactNumber',
                                                                contactNumber);
                                                            box.write('address',
                                                                address);
                                                            box.write(
                                                                'username',
                                                                username);
                                                            box.write(
                                                                'password',
                                                                password);
                                                            box.write(
                                                                'profilePicture',
                                                                imageURL == ''
                                                                    ? 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
                                                                    : imageURL);
                                                            // Add to Firestore
                                                            createAccount(
                                                                username,
                                                                password,
                                                                name,
                                                                contactNumber,
                                                                address,
                                                                imageURL == ''
                                                                    ? 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
                                                                    : imageURL);
                                                            Navigator.of(
                                                                    context)
                                                                .pushReplacement(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                LogInPage()));
                                                          },
                                                          child: const Text(
                                                            'Continue',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Quicksand',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ));
                                          },
                                          text: 'Signup'),
                                      const SizedBox(
                                        height: 200,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                    child: TextRegular(
                      text: 'Signup now',
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
