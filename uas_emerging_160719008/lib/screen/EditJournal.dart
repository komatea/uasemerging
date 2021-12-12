import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uas_emerging_160719008/class/country.dart';
import 'package:uas_emerging_160719008/class/journal.dart';
import 'package:uas_emerging_160719008/main.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uas_emerging_160719008/screen/DetailJournal.dart';

class EditJournal extends StatefulWidget {
  final String journal_id;
  EditJournal({Key? key, required this.journal_id}) : super(key: key);

  @override
  _EditJournalState createState() => _EditJournalState();
}

class _EditJournalState extends State<EditJournal> {
  late Journal j;
  final formKey = GlobalKey<FormState>();

  TextEditingController _titleCont = new TextEditingController();
  TextEditingController _contentCont = new TextEditingController();
  late var journal;
  var title = "";
  var content = "";
  // var created_at = "";
  var user = "";
  var country = "";
  var selectedCountry;

  File? _image = null;
  File? _imageProses = null;

  Widget dropdownCountry = Text("Data Country");

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  bacaData() {
    print(activeUser);
    fetchData().then((value) {
      Map json = jsonDecode(value);
      for (var journal in json['data']) {
        Journal j = Journal.fromJson(journal);
        setState(() {
          journal = j;
          _titleCont.text = journal.title;
          _contentCont.text = journal.content;
          user = journal.user;
          selectedCountry = journal.country;
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
          value: selectedCountry,
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

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    tileColor: Colors.white,
                    leading: new Icon(Icons.photo_library),
                    title: new Text('Galeri'),
                    onTap: () {
                      _imgGaleri();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Kamera'),
                  onTap: () {
                    _imgKamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _imgGaleri() async {
    final picker = ImagePicker();
    final image = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 600,
        maxWidth: 600);
    setState(() {
      if (image != null) {
        _image = File(image.path);
        prosesFoto();
      }
    });
  }

  _imgKamera() async {
    final picker = ImagePicker();
    final image =
        await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    setState(() {
      if (image != null) {
        _image = File(image.path);
        prosesFoto();
      }
    });
  }

  void prosesFoto() {
    Future<Directory?> extDir = getExternalStorageDirectory();
    extDir.then((value) {
      String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

      final DateTime now = DateTime.now();
      // final DateFormat formatter = DateFormat('yyyy-MM-dd H:m:s');
      // final String formatted = formatter.format(now);

      final String filePath = value!.path + '/${_timestamp()}.jpg';
      _imageProses = File(filePath);
      img.Image? temp = img.readJpg(_image!.readAsBytesSync());
      img.Image temp2 = img.copyResize(temp!, width: 480, height: 640);
      img.drawString(temp2, img.arial_24, 4, 4, 'Photo by : ' + activeUser,
          color: img.getColor(250, 100, 100));
      img.drawString(temp2, img.arial_24, 4, 60, 'Taken : ' + now.toString(),
          color: img.getColor(250, 100, 100));
      setState(() {
        _imageProses!.writeAsBytesSync(img.writeJpg(temp2));
      });
    });
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
                  controller: _titleCont,
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
                  controller: _contentCont,
                  validator: (value) {
                    if (value == null) {
                      return 'Content can not be empty';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 10,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: (_imageProses != null)
                      ? Image.file(_imageProses!)
                      : Image.network("http://ubaya.fun/blank.jpg"),
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
