import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Reading and Writing Files',
      home: MyList(storage: DataStorage()),
    ),
  );
}

class DataStorage {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await localPath;
    return File('$path/data.json');
  }

  Future<Map> read() async {
    try {
      final file = await _localFile;
      final source = await file.readAsString();
      Map data = json.decode(source);
      return data;
    } catch (e) {
      print(e);
      // If encountering an error, return 0
      return {};
    }
  }

  Future<File> write(Map value) async {
    final file = await _localFile;
    print(json.encode(value));
    return file.writeAsString(json.encode(value));
  }
}

class MyList extends StatefulWidget {
  const MyList({Key? key, required this.storage}) : super(key: key);
  final DataStorage storage;

  @override
  _MyListState createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  Map _data = {};

  @override
  void initState() {
    print("setState");
    widget.storage.read().then((Map value) {
      setState(() {
        print("data: $value");
        _data = value;
      });
    });
    super.initState();
  }

  Future<File> _clearList() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    List _dataTmp = data!.text!
        .split("\n")
        .where((element) => element.trim() != " ")
        .where((element) => !element.endsWith(":"))
        .toSet()
        .toList();
    Map _dataFiltered = {};
    _dataTmp.forEach((element) {
      _dataFiltered[element] = false;
    });
    setState(() {
      _data = _dataFiltered;
    });
    return widget.storage.write(_data);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 60),
            child: Column(
              children: [
                ..._data.keys.map((key) {
                  return Column(
                    children: [
                      CustomCheckListItem(
                          title: key.toString(),
                          status: _data[key.toString()],
                          onChange: (bool value) {
                            _data[key.toString()] = !value;
                            widget.storage.write(_data).then((value) => print);
                            return value;
                          }),
                      SizedBox(height: 10),
                    ],
                  );
                })
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _clearList,
          child: const Icon(Icons.list_alt),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}

class CustomCheckListItem extends StatefulWidget {
  String title;
  Function onChange;
  bool status;

  CustomCheckListItem(
      {Key? key,
      required this.title,
      required this.onChange,
      required this.status});

  @override
  State<CustomCheckListItem> createState() =>
      _CustomCheckListItemState(title, onChange, status);
}

class _CustomCheckListItemState extends State<CustomCheckListItem> {
  bool _value = false;
  String title;
  Function onChange;
  bool status;

  _CustomCheckListItemState(this.title, this.onChange, this.status) {
    _value = status;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _value = !onChange(_value);
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(title,
              style: TextStyle(
                  decoration: _value
                      ? TextDecoration.lineThrough
                      : TextDecoration.none)),
          SizedBox(width: 20),
          Container(
            height: 30.0,
            width: 30.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _value ? Colors.blue : Colors.transparent),
            child: _value
                ? Icon(
                    Icons.check,
                    size: 20.0,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.close,
                    size: 20.0,
                    color: Colors.blue,
                  ),
          ),
        ],
      ),
    );
  }
}
