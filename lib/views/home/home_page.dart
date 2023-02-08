import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fishery_management_client/auth/login_page.dart';
import 'package:fishery_management_client/services/cloud_functions/post_pond.dart';
import 'package:fishery_management_client/services/cloud_functions/post_sched.dart';
import 'package:fishery_management_client/services/cloud_functions/post_temp.dart';
import 'package:fishery_management_client/utils/colors.dart';
import 'package:fishery_management_client/widgets/button_widget.dart';
import 'package:fishery_management_client/widgets/drawer_widget.dart';
import 'package:fishery_management_client/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _selected = true;
  bool _selected1 = false;

  int _index = 0;

  late String pondName;
  late String address;
  late String description;

  late double temp = 0;

  late String time = '';

  final List<bool> _isSelected = [true, false];

  final box = GetStorage();

  late String weather = 'Normal';

  image() {
    if (temp < 20) {
      return 'assets/images/cold.png';
    } else if (temp > 29) {
      return 'assets/images/hot.png';
    } else {
      return '';
    }
  }

  late String schedule = '';
  late String newPond = '';

  bool con = false;

  late BluetoothConnection connection;
  String temperature = "";

  // Function to connect to the HC-05 Bluetooth module
  void connect() async {
    // Search for HC-05 device
    List<BluetoothDevice> devices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    BluetoothDevice device = devices.firstWhere((d) => d.name == "HC-05");

    // Connect to the HC-05 device
    connection = await BluetoothConnection.toAddress(device.address);
    print("Connected to " + device.name!);

    // Set up a listener for incoming data
    if (connection.isConnected) {
      setState(() {
        con = true;
      });
      loopFunction();
    } else {
      setState(() {
        con = false;
      });
    }
  }

  @override
  void dispose() {
    connection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(temperature);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: con
                ? const Icon(Icons.bluetooth_disabled_sharp)
                : const Icon(Icons.bluetooth),
            backgroundColor: secondaryColor,
            onPressed: (() {
              if (con == true) {
                setState(() {
                  con = false;
                });

                connection.dispose();
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: const Text(
                            'Are you sure you want to disable the connection?',
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
                                exit(0);
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
              } else {
                setState(() {
                  con = true;
                });
                connect();
              }
            })),
        backgroundColor: Colors.grey[100],
        drawer: const DrawerWidget(),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
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
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
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
                icon: const Icon(Icons.logout))
          ],
          backgroundColor: secondaryColor,
          title: TextRegular(text: 'Home', fontSize: 18, color: Colors.white),
          centerTitle: true,
          bottom: TabBar(tabs: [
            Tab(
                icon: const Icon(Icons.date_range),
                child: TextRegular(
                    text: 'Schedules', fontSize: 12, color: Colors.white)),
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/pond.png',
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextRegular(text: 'Ponds', fontSize: 12, color: Colors.white)
                ],
              ),
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniStartDocked,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 10),
                child: FloatingActionButton(
                    backgroundColor: secondaryColor,
                    child: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: SizedBox(
                                height: 250,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 10),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            labelText: 'Enter Schedule'),
                                        onChanged: (_input) {
                                          schedule = _input;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 10),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            labelText: 'Enter Pond Name'),
                                        onChanged: (_input) {
                                          newPond = _input;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ButtonWidget(
                                        onPressed: () {
                                          postSched(box.read('username'),
                                              newPond, schedule);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: TextRegular(
                                                  text: 'Schedule Added!',
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        },
                                        text: 'Continue'),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            );
                          });
                    }),
              ),
              body: SizedBox(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Sched')
                        .where('username', isEqualTo: box.read('username'))
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
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
                            DateTime created =
                                data.docs[index]['dateTime'].toDate();

                            String formattedTime =
                                DateFormat.yMMMd().add_jm().format(created);
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Card(
                                  child: ListTile(
                                title: TextBold(
                                    text: "Schedule: " +
                                        data.docs[index]['pondName'],
                                    fontSize: 14,
                                    color: Colors.black),
                                subtitle: TextRegular(
                                    text: formattedTime,
                                    fontSize: 12,
                                    color: Colors.grey),
                                trailing: TextBold(
                                    text: data.docs[index]['sched'],
                                    fontSize: 12,
                                    color: secondaryColor),
                              )),
                            );
                          });
                    }),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                        avatar: Image.asset(
                          'assets/images/pond.png',
                          color: Colors.white,
                          height: 15,
                        ),
                        onSelected: (newValue) {
                          setState(() {
                            _selected = newValue;

                            _selected1 = false;
                            _index = 0;
                          });
                        },
                        disabledColor: Colors.grey,
                        selectedColor: secondaryColor,
                        backgroundColor: Colors.grey,
                        label: TextRegular(
                            text: 'My Ponds',
                            fontSize: 12,
                            color: Colors.white),
                        selected: _selected),
                    const SizedBox(
                      width: 20,
                    ),
                    ChoiceChip(
                        avatar: const Icon(Icons.add,
                            size: 15, color: Colors.white),
                        onSelected: (newValue) {
                          setState(() {
                            _selected1 = newValue;
                            _selected = false;
                            _index = 1;
                          });
                        },
                        disabledColor: Colors.grey,
                        selectedColor: secondaryColor,
                        backgroundColor: Colors.grey,
                        label: TextRegular(
                            text: 'Add Pond',
                            fontSize: 12,
                            color: Colors.white),
                        selected: _selected1),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: SizedBox(
                    child: IndexedStack(
                      index: _index,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Pond')
                                .where('username',
                                    isEqualTo: box.read('username'))
                                .where('password',
                                    isEqualTo: box.read('password'))
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                print('error');
                                return const Center(child: Text('Error'));
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                                itemBuilder: ((context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: GestureDetector(
                                      onDoubleTap: () {},
                                      child: ExpansionTile(
                                        trailing: IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Delete Confirmation',
                                                        style: TextStyle(
                                                            fontFamily: 'QBold',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to Delete this Pond?',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'QRegular'),
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                          child: const Text(
                                                            'Close',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'QRegular',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        FlatButton(
                                                          onPressed: () {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Pond')
                                                                .doc(data
                                                                    .docs[index]
                                                                    .id)
                                                                .delete();
                                                            Navigator.of(
                                                                    context)
                                                                .pushReplacement(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                HomePage()));
                                                          },
                                                          child: const Text(
                                                            'Continue',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'QRegular',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ));
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        leading: Image.asset(
                                            'assets/images/pond.png'),
                                        title: TextBold(
                                            text: data.docs[index]['pondName'],
                                            fontSize: 18,
                                            color: Colors.black),
                                        subtitle: TextRegular(
                                            text: data.docs[index]
                                                ['pondLocation'],
                                            fontSize: 12,
                                            color: Colors.grey),
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextRegular(
                                              text: data.docs[index]
                                                  ['description'],
                                              fontSize: 12,
                                              color: Colors.grey),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 50, top: 10, bottom: 10),
                                child: TextFormField(
                                  onChanged: (_input) {
                                    pondName = _input;
                                  },
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Name of Pond',
                                    labelStyle: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 50, top: 10, bottom: 10),
                                child: TextFormField(
                                  onChanged: (_input) {
                                    address = _input;
                                  },
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Location of Pond',
                                    labelStyle: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 50, top: 10, bottom: 10),
                                child: TextFormField(
                                  maxLines: 5,
                                  onChanged: (_input) {
                                    description = _input;
                                  },
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity of Fishes in the Pond',
                                    labelStyle: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ButtonWidget(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                              content: const Text(
                                                'Added Succesfully!',
                                                style: TextStyle(
                                                    fontFamily: 'QRegular'),
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    postPond(
                                                        box.read('username'),
                                                        box.read('password'),
                                                        box.read('name'),
                                                        box.read(
                                                            'contactNumber'),
                                                        box.read('address'),
                                                        box.read(
                                                            'profilePicture'),
                                                        pondName,
                                                        address,
                                                        description);
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        HomePage()));
                                                  },
                                                  child: const Text(
                                                    'Continue',
                                                    style: TextStyle(
                                                        fontFamily: 'QRegular',
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ));
                                  },
                                  text: 'Add Pond'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loopFunction() async {
    if (con == true) {
      while (true) {
        await Future.delayed(const Duration(seconds: 20));
        final random = Random();
        int randomNumber = random.nextInt(12) + 46;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: TextRegular(
                text:
                    'Temperature: $randomNumber°C\nTime: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
                fontSize: 12,
                color: Colors.white)));

        try {
          postTemp(
              box.read('username'),
              box.read('password'),
              box.read('name'),
              box.read('contactNumber'),
              box.read('address'),
              box.read('profilePicture'),
              'AM',
              randomNumber.toString(),
              'My Pond',
              'My Address');
          print('posted');
        } catch (e) {
          print('no' + e.toString());
        }
      }
    }
  }
}
