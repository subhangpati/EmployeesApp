import 'package:flutter/material.dart';

AppBar buildAppBar(String heading) {
  return AppBar(
    backgroundColor:  Color(0xFF2E2E2E),
    title: Text(
      heading,
      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      )
    ],
  );
}
