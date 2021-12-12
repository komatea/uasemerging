import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emerging_160719008/screen/DisplayJournal.dart';
import 'package:uas_emerging_160719008/screen/Home.dart';
import 'package:uas_emerging_160719008/screen/InsertJournal.dart';
import 'package:uas_emerging_160719008/screen/login.dart';

String activeUser = "";
String activeId = "";
String activeRole = "";

Future<List<String>> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String name = prefs.getString("name") ?? '';
  String userId = prefs.getString("userId") ?? '';
  String roleId = prefs.getString("roleId") ?? '';
  return [name, userId, roleId];
}

void main() {
  //Check User First if ever login
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then(
    (List result) {
      if (result[0] == "") {
        print(result[0]);
        runApp(MyLogin());
      } else {
        activeUser = result[0];
        activeId = result[1];
        activeRole = result[2];
        runApp(MyApp());
      }
    },
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Inspire'),
      routes: {
        'displayJournal': (context) => DisplayJournal(),
        'insertJournal': (context) => InsertJournal(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //To Log Out
  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userId");
    prefs.remove("name");
    main();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerNav(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Home(),
    );
  }

  Widget drawerNav() {
    return Drawer(
      elevation: 16.0,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(activeUser),
              accountEmail: Text("as " + activeRole == 1 ? "admin" : "user"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
              ),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text("All Journals"),
              onTap: () {
                Navigator.pushNamed(context, 'displayJournal');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_basket),
              title: Text("Insert Journal"),
              onTap: () {
                Navigator.pushNamed(context, 'insertJournal');
              },
            ),
            Divider(
              color: Colors.black,
              height: 3,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: doLogout,
            ),
          ],
        ),
      ),
    );
  }
}
