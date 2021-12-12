import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emerging_160719008/class/journal.dart';
import 'package:uas_emerging_160719008/screen/detailjournal.dart';

class DisplayJournal extends StatefulWidget {
  DisplayJournal({Key? key}) : super(key: key);

  @override
  _DisplayJournalState createState() => _DisplayJournalState();
}

class _DisplayJournalState extends State<DisplayJournal> {
  @override
  //store array of data
  var listOfJournals = [];

  //get data from API
  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse(
          "https://ubaya.fun/flutter/160719008/new_api/journals_index.php"),
      body: {"cari": ""},
    );
    if (response.statusCode == 200) {
      print("success");
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    Future<String> data = fetchData();
    data.then(
      (value) {
        listOfJournals.clear();
        Map json = jsonDecode(value);
        for (var journal in json['data']) {
          Journal j = Journal.fromJson(journal);
          // print(j.title);
          setState(
            () {
              listOfJournals.add(j);
              // listOfJournals.add(j);
            },
          );
        }
        // print("List of Journals " + listOfJournals.toString());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  Widget displayListOfJournal(data) {
    if (data != null) {
      return ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new Card(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.article, size: 30),
                  title: GestureDetector(
                    child: Text(data[index].title),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailJournal(
                              journal_id: data[index].id.toString()),
                        ),
                      );
                    },
                  ),
                  subtitle: Text(data[index].content.length >= 36
                      ? data[index].content.substring(0, 36)
                      : data[index].content),
                  // Text("ID : " + listOfJournals[index].caption.toString()),
                ),
              ],
            ));
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  //Function get data
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Journal'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: displayListOfJournal(listOfJournals),
          )
        ],
      ),
    );
  }
}
