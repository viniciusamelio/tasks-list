import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }

  Future<File> _getFile() async{
  final dir = await getApplicationDocumentsDirectory(); // Get the directory where i can place files without permissions and this things
  return File("${dir.path}/data.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async{
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

