import 'package:fishery_management_client/utils/colors.dart';
import 'package:fishery_management_client/widgets/text_widget.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget AppbarWidget(
  String title,
) {
  return AppBar(
    backgroundColor: secondaryColor,
    title: TextRegular(text: title, fontSize: 18, color: Colors.white),
    centerTitle: true,
  );
}
