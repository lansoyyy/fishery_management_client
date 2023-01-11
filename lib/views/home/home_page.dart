import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fishery_management_client/auth/login_page.dart';
import 'package:fishery_management_client/services/cloud_functions/post_pond.dart';
import 'package:fishery_management_client/services/cloud_functions/post_temp.dart';
import 'package:fishery_management_client/utils/colors.dart';
import 'package:fishery_management_client/widgets/button_widget.dart';
import 'package:fishery_management_client/widgets/drawer_widget.dart';
import 'package:fishery_management_client/widgets/text_widget.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/temp1.png',
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextRegular(
                      text: 'Temperature', fontSize: 12, color: Colors.white)
                ],
              ),
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              floatingActionButton: FloatingActionButton(
                  backgroundColor: secondaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {}),
              body: SizedBox(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Temp')
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
            Stack(
              children: [
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      ToggleButtons(
                          borderRadius: BorderRadius.circular(5),
                          splashColor: Colors.grey,
                          color: Colors.black,
                          selectedColor: Colors.blue,
                          fillColor: secondaryColor,
                          children: [
                            TextBold(
                                text: 'AM', fontSize: 15, color: Colors.black),
                            TextBold(
                                text: 'PM', fontSize: 15, color: Colors.black),
                          ],
                          onPressed: (int newIndex) {
                            setState(() {
                              for (int index = 0;
                                  index < _isSelected.length;
                                  index++) {
                                if (index == newIndex) {
                                  _isSelected[index] = true;
                                  if (_isSelected[0] == true) {
                                    time = 'AM';
                                  } else {
                                    time = 'PM';
                                  }
                                } else {
                                  _isSelected[index] = false;
                                }
                              }
                            });
                          },
                          isSelected: _isSelected),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 50, right: 50, top: 30, bottom: 10),
                        child: TextFormField(
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          onChanged: (_input) {
                            temp = double.parse(_input);
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            suffix: TextRegular(
                                text: '°C', fontSize: 12, color: Colors.red),
                            labelText: 'Input Temperature',
                            labelStyle: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
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
                            labelStyle:
                                TextStyle(fontSize: 12, color: Colors.grey),
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
                            labelStyle:
                                TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ButtonWidget(
                          onPressed: () {
                            postTemp(
                                box.read('username'),
                                box.read('password'),
                                box.read('name'),
                                box.read('contactNumber'),
                                box.read('address'),
                                box.read('profilePicture'),
                                time,
                                temp.toString(),
                                pondName,
                                address);
                            if (temp < 20) {
                              setState(() {
                                weather = 'Cold';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Warning: Temperature too Cold'),
                                ),
                              );
                            } else if (temp > 29) {
                              setState(() {
                                weather = 'Hot';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Warning: Temperature too Hot'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Temperature is Right'),
                                ),
                              );
                            }
                          },
                          text: 'Add Temperature'),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 50),
                    child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(image()),
                        onPressed: () {}),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
