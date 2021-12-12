import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_emerging_160719008/class/journal.dart';
import 'package:uas_emerging_160719008/main.dart';
import 'package:uas_emerging_160719008/screen/EditJournal.dart';

class DetailJournal extends StatefulWidget {
  final String journal_id;
  DetailJournal({Key? key, required this.journal_id}) : super(key: key);
  @override
  _DetailJournalState createState() => _DetailJournalState();
}

class _DetailJournalState extends State<DetailJournal> {
  Journal? j;

  late var journal;
  var title = "";
  var content = "";
  // var created_at = "";
  var user = "";
  var country = "";

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  void delete() async {
    final response = await http.post(
      Uri.parse(
          "https://ubaya.fun/flutter/160719008/new_api/journals_delete.php"),
      body: {
        'journal_id': widget.journal_id.toString(),
      },
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sukses Menghapus Data'),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    print(activeUser);
    fetchData().then((value) {
      Map json = jsonDecode(value);
      for (var journal in json['data']) {
        Journal j = Journal.fromJson(journal);
        setState(() {
          journal = j;
          title = journal.title;
          content = journal.content;
          user = journal.user;
          country = journal.country;
          // created_at = journal.created_at;
        });
      }
    });
  }

  Future<String> fetchData() async {
    print(widget.journal_id.toString());
    final response = await http.post(
      Uri.parse(
          "https://ubaya.fun/flutter/160719008/new_api/journals_index.php"),
      body: {
        'journal_id': widget.journal_id.toString(),
      },
    );
    if (response.statusCode == 200) {
      print("success");
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget displayDetailData(data) {
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Journal"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: size.height * 0.3,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/150'),
                      fit: BoxFit.fill)),
            ),
            Divider(
              color: Colors.white,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "By: " + user.toString() + "\n Country: " + country,
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            // Text(""),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                user == activeUser
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditJournal(
                                  journal_id: widget.journal_id.toString()),
                            ),
                          );
                        },
                        child: Text("Edit"))
                    : Text(""),
                user == activeUser
                    ? ElevatedButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         EditNewsCat(idNews.toString()),
                          //   ),
                          // );
                        },
                        child: Text("Edit categories"))
                    : Text(""),
                user == activeUser
                    ? ElevatedButton(
                        onPressed: () {
                          delete();
                        },
                        child: Text("Delete"))
                    : Text(""),
              ],
            )
            // Divider(
            //   thickness: 1,
            // ),
            // SizedBox(
            //     height: size.height * 0.05,
            //     child: DaftarKategories(categories, size.height * 0.25)),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     user == active_user
            //         ? ElevatedButton(
            //             onPressed: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => EditNews(news(
            //                       id: int.parse(idNews),
            //                       body: body,
            //                       title: title,
            //                       up: date)),
            //                 ),
            //               );
            //             },
            //             child: Text("Edit"))
            //         : Text(""),
            //     user == active_user
            //         ? ElevatedButton(
            //             onPressed: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => EditNewsCat(idNews.toString()),
            //                 ),
            //               );
            //             }, child: Text("Edit categories"))
            //         : Text(""),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
