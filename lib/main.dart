import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'dart:io';

import 'package:voting_system/dashboard.dart';
import 'package:voting_system/student_dashboard.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(HomePage());
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class HomePage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var email = TextEditingController();
  var password = TextEditingController();
  var new_password = TextEditingController();
  var confirm_password = TextEditingController();
  String votersID = "";

  bool changed_password = false;
  bool _passwordVisible = true;
  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;
  void _login() async {
    String apiUrl = globals.endpoint + "login.php";
    var _response = await http.post(Uri.parse(apiUrl), body: {
      "email": email.text,
      "password": password.text,
    });
    var jsonData = json.decode(_response.body);
    if (jsonData['message'] == "SuccessAdmin") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => adminDashboard(
                adminID: jsonData['adminID'],
                username: jsonData['username'],
                email: jsonData['email'],
                password: jsonData['password'],
              )));
    } else if (jsonData['message'] == "SuccessStudent") {
      if (jsonData['password_changed'] == '1') {
        setState(() {
          changed_password = true;
          setState(() {
            votersID = jsonData['votersID'];
          });
        });
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => studentDashboard(
                  votersID: jsonData['votersID'],
                  student_id: jsonData['student_id'],
                  password: jsonData['password'],
                  password_changed: jsonData['password_changed'],
                )));
      }
    } else if (jsonData['message'] == "NotRegistered") {
      Fluttertoast.showToast(
          msg: "Email Not Registered",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Incorrect Password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _studentLogin() async {
    String apiUrl = globals.endpoint + "student_login.php";
    var _response = await http.post(Uri.parse(apiUrl), body: {
      "votersID": votersID,
      "password": new_password.text,
    });
    var jsonData = json.decode(_response.body);
    if (jsonData['message'] == "Success") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => studentDashboard(
                votersID: jsonData['votersID'],
                student_id: jsonData['student_id'],
                password: jsonData['password'],
                password_changed: jsonData['password_changed'],
              )));
    } else {
      Fluttertoast.showToast(
          msg: "Error!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return exit(0);
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.indigo,
          body: Container(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: Container(
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: Colors.indigo,
                              height: MediaQuery.of(context).size.height * 0.30,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      radius: 40,
                                      child: Icon(
                                        Icons.how_to_vote,
                                        size: 50,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Voting System',
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    topRight: Radius.circular(50),
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      enabled: !changed_password,
                                      controller: email,
                                      autocorrect: true,
                                      decoration: InputDecoration(
                                        label: Text("Email / Student ID"),
                                        hintText: 'Enter Email or Student ID',
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 3,
                                          ),
                                        ),
                                        prefixIcon: IconTheme(
                                          data: IconThemeData(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: Icon(Icons.email),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    TextField(
                                      enabled: !changed_password,
                                      controller: password,
                                      autocorrect: true,
                                      obscureText: changed_password
                                          ? true
                                          : _passwordVisible,
                                      decoration: InputDecoration(
                                        label: Text("Password"),
                                        hintText: 'Enter Password',
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 3,
                                          ),
                                        ),
                                        prefixIcon: IconTheme(
                                          data: IconThemeData(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: Icon(Icons.lock),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            // Based on passwordVisible state choose the icon
                                            changed_password
                                                ? Icons.visibility_off
                                                : (!_passwordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          onPressed: () {
                                            // Update the state i.e. toogle the state of passwordVisible variable
                                            setState(() {
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    changed_password
                                        ? TextField(
                                            controller: new_password,
                                            autocorrect: true,
                                            obscureText: _passwordVisible1,
                                            decoration: InputDecoration(
                                              label: Text("New Password"),
                                              hintText: 'Enter New Password',
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 3,
                                                ),
                                              ),
                                              prefixIcon: IconTheme(
                                                data: IconThemeData(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                child: Icon(Icons.lock),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  !_passwordVisible1
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _passwordVisible1 =
                                                        !_passwordVisible1;
                                                  });
                                                },
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    changed_password
                                        ? SizedBox(
                                            height: 20,
                                          )
                                        : Container(),
                                    changed_password
                                        ? TextField(
                                            controller: confirm_password,
                                            autocorrect: true,
                                            obscureText: _passwordVisible2,
                                            decoration: InputDecoration(
                                              label: Text("Confirm Password"),
                                              hintText:
                                                  'Enter Confirm Password',
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  width: 3,
                                                ),
                                              ),
                                              prefixIcon: IconTheme(
                                                data: IconThemeData(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                child: Icon(Icons.lock),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  !_passwordVisible2
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _passwordVisible2 =
                                                        !_passwordVisible2;
                                                  });
                                                },
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    changed_password
                                        ? SizedBox(
                                            height: 20,
                                          )
                                        : Container(),
                                    changed_password
                                        ? InkWell(
                                            onTap: () {
                                              if (new_password.text == "") {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Please Enter New Password",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              } else if (confirm_password
                                                      .text ==
                                                  "") {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Please Enter Confirm Password",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              } else if (new_password.text !=
                                                  confirm_password.text) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Password Doesn't Match",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                              } else {
                                                _studentLogin();
                                              }
                                            },
                                            child: Container(
                                              height: 50,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.indigo,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Login",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              _login();
                                            },
                                            child: Container(
                                              height: 50,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.indigo,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Login",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
