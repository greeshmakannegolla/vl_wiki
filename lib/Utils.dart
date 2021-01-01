import 'dart:io';

import 'package:flutter/material.dart';

Future<bool> checkInternetConnectivity() async {
  try {
    await InternetAddress.lookup('google.com');
    return true;
  } on SocketException catch (_) {
    return false;
  }
}

String capitalizeFirstLetter(String input) {
  if (input.length < 1 || input == null) {
    return "";
  }
  String output = input.replaceRange(0, 1, input[0].toUpperCase());
  return output;
}

Future<void> showAlert(
    BuildContext context, String title, Widget content) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: content,
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pop(); // dismisses only the dialog and returns nothing
          },
          child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
