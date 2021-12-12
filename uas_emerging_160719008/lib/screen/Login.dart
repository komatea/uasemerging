import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_emerging_160719008/main.dart';

class MyLogin extends StatelessWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String email;
  late String password;
  String errorMessage = "";

  //Login Function
  void doLogin() async {
    final response = await http.post(
        // TODO: Change The Link
        Uri.parse("https://ubaya.fun/flutter/160719008/new_api/login.php"),
        body: {'email': email, 'password': password});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(
          () {
            errorMessage = "Success Login";
          },
        );
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("name", json['name']);
        prefs.setString("userId", json['user_id']);
        prefs.setString("roleId", json['role_id']);
        print("user id " + json['user_id']);
        main();
      } else {
        setState(
          () {
            errorMessage = "Invalid email or password. Please Try Again";
          },
        );
      }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
          height: size.height,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text("Inspire", style: TextStyle(fontSize: 24.0)),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter valid email id as abc@gmail.com',
                  ),
                  onChanged: (v) {
                    email = v;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password',
                  ),
                  onChanged: (v) {
                    password = v;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: doLogin,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
