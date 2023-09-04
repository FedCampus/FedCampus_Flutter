import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FedToast {
  static void internetIssue() {
    Fluttertoast.showToast(
        msg: "Internet Connection Issue, please connect to Internet.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
