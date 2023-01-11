import 'package:fishery_management_client/utils/colors.dart';
import 'package:fishery_management_client/widgets/drawer_widget.dart';
import 'package:fishery_management_client/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class ReadingPage extends StatelessWidget {
  const ReadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: TextRegular(
            text: 'Temperature Readings', fontSize: 18, color: Colors.white),
        centerTitle: true,
      ),
    );
  }
}
