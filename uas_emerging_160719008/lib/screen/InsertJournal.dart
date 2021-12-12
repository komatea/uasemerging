import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uas_emerging_160719008/class/country.dart';
import 'package:uas_emerging_160719008/main.dart';

class InsertJournal extends StatefulWidget {
  InsertJournal({Key? key}) : super(key: key);

  @override
  _InsertJournalState createState() => _InsertJournalState();
}

class _InsertJournalState extends State<InsertJournal> {
  final formKey = GlobalKey<FormState>();
  String title = "";
  String content = "";
  String country_id = "";
  String user_id = "";
  Widget dropdownCountry = Text("Data Country");
  var selectedCountry;
  @override
  void initState() {
    // TODO: implement initState
    generateComboCountry();
    super.initState();
    setState(() {});
  }

  Future<List> fetchCountry() async {
    Map json;
    final response = await http.get(
      Uri.parse(
          "https://ubaya.fun/flutter/160719008/new_api/countries_index.php"),
    );
    if (response.statusCode == 200) {
      print(response.body);
      print("countries success");
      json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Failed to read API');
    }
  }

  void generateComboCountry() {
    //widget function for city list
    var country_name;
    List<Country> countries;
    var data = fetchCountry();
    data.then(
      (value) {
        countries = List<Country>.from(value.map((i) {
          return Country.fromJson(i);
        }));

        dropdownCountry = new DropdownButton(
          dropdownColor: Colors.blue[100],
          hint: Text("Select Country"),
          isDense: false,
          items: countries.map((country) {
            return DropdownMenuItem(
              child: Column(children: <Widget>[
                Text(country.name, overflow: TextOverflow.visible),
              ]),
              value: country,
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              selectedCountry = v;
              print("Value drop down " + v!.toString());
            });
          },
        );
      },
    );
    // setState(() {
    //   country_name = selectedCountry?.name.toString();
    //   country_id = selectedCountry?.id;
    // });
  }

  void submit() async {
    final response = await http.post(
      Uri.parse(
          "https://ubaya.fun/flutter/160719008/new_api/journals_create.php"),
      body: {
        'title': title,
        'content': content,
        'country_id': "1",
        'user_id': activeId,
      },
    );
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sukses Menambah Data'),
          ),
        );
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Journal'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Input Title
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  onChanged: (value) {
                    title = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Title can not be empty';
                    return null;
                  },
                ),
              ),
              Padding(
                //Input Content
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Content',
                  ),
                  onChanged: (value) {
                    content = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Content can not be empty';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 6,
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: selectedCountry == null
                      ? Text("Country: No selected")
                      : Text("Country :" + selectedCountry.name.toString())),
              Padding(padding: EdgeInsets.all(10), child: dropdownCountry),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Harap Isi Dengan Sesuai')));
                    } else {
                      submit();
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
