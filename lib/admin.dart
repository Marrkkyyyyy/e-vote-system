import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class admin extends StatefulWidget {
  @override
  State<admin> createState() => _adminState();
}

class _adminState extends State<admin> {
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future _getAdmin() async {
    String apiUrl = "${globals.endpoint}display_admin.php";
    var response = await http.post(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setStateIfMounted(() {});

      return json.decode(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    _getAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Admin"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: FutureBuilder(
          future: _getAdmin(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List list = snapshot.data;

              return list.isEmpty
                  ? const Center(
                      child: Text("No Admin Found"),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        List list = snapshot.data;

                        return Card(
                          child: ListTile(
                            minLeadingWidth: 0.0,
                            dense: true,
                            title: Text(list[index]['username'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            subtitle: Text(list[index]['email']),
                          ),
                        );
                      });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addAdmin(context);
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  var username = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  _addAdmin(BuildContext contextD) {
    AlertDialog alert = AlertDialog(
      titlePadding: const EdgeInsets.only(top: 15, left: 18, bottom: 15),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      actionsPadding: const EdgeInsets.only(
        bottom: 5,
        right: 10,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      content: Builder(
        builder: (context) {
          return Container(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: username,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    isDense: true,
                    label: Text("Username"),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(
                    isDense: true,
                    label: Text("Email"),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                    isDense: true,
                    label: Text("Password"),
                    border: OutlineInputBorder()),
              ),
            ],
          ));
        },
      ),
      title: const Text(
        "Add Admin",
        style: TextStyle(
            color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(50, 40),
            padding: const EdgeInsets.symmetric(horizontal: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel",
              style: TextStyle(
                color: Colors.indigo,
              )),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(50, 40),
            padding: const EdgeInsets.symmetric(horizontal: 15),
          ),
          onPressed: () {
            if (username.text == "") {
              Fluttertoast.showToast(
                  msg: "Textfield is Emtpy!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (email.text == "") {
              Fluttertoast.showToast(
                  msg: "Textfield is Emtpy!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (password.text == "") {
              Fluttertoast.showToast(
                  msg: "Textfield is Emtpy!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              addAdmin();
            }
          },
          child: const Text("Add",
              style: TextStyle(
                color: Colors.indigo,
              )),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void addAdmin() async {
    String apiUrl = "${globals.endpoint}add_admin.php";
    var response = await http.post(Uri.parse(apiUrl), body: {
      "username": username.text,
      "email": email.text,
      "password": password.text,
    });
    var message = json.decode(response.body);
    if (message == "Success") {
      Fluttertoast.showToast(
          msg: "Successfully Added",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context, rootNavigator: true).pop(context);
      setState(() {
        username.text = "";
        email.text = "";
        password.text = "";
      });
    } else if (message == "duplicateEmail") {
      Fluttertoast.showToast(
          msg: "Email Has Already Taken",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
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
}
