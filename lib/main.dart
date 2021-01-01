import 'package:flutter/material.dart';
import 'package:wiki/MyWikiApp.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyWikiApp()));
}
