import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class voters extends StatefulWidget {
  @override
  State<voters> createState() => _votersState();
}

class _votersState extends State<voters> {
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future _getVoters() async {
    String apiUrl = globals.endpoint + "display_voters.php";
    var _response = await http.post(Uri.parse(apiUrl));
    if (_response.statusCode == 200) {
      setStateIfMounted(() {});

      return json.decode(_response.body);
    }
  }

  bool _passwordVisible = true;
  @override
  void initState() {
    super.initState();
    _getVoters();
  }

  var student_id = TextEditingController();
  var last_name = TextEditingController();

  Future<void> scanStudentQR() async {
    String UserQrCodeScan;

    try {
      UserQrCodeScan = await FlutterBarcodeScanner.scanBarcode(
              '#ff6666', 'Cancel', true, ScanMode.QR)
          .then((value) {
        if (value == "-1") {
          return "";
        } else {
          return student_id.text = value;
        }
      });
    } on PlatformException {
      UserQrCodeScan = 'Failed to Scan QR Code.';
    }
    if (!mounted) return;
  }

  _addVoters(BuildContext contextD) {
    AlertDialog alert = AlertDialog(
      titlePadding: EdgeInsets.only(top: 15, left: 18, bottom: 15),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      actionsPadding: EdgeInsets.only(
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
                keyboardType: TextInputType.number,
                controller: student_id,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          scanStudentQR();
                        },
                        icon: Icon(
                          Icons.qr_code_scanner_outlined,
                          color: Colors.indigo,
                          size: 28,
                        )),
                    isDense: true,
                    label: Text("Student ID"),
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: last_name,
                decoration: InputDecoration(
                    isDense: true,
                    label: Text("Last Name"),
                    border: OutlineInputBorder()),
              ),
            ],
          ));
        },
      ),
      title: Text(
        "Register Voters",
        style: TextStyle(
            color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(50, 40),
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel",
              style: TextStyle(
                color: Colors.indigo,
              )),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(50, 40),
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
          onPressed: () {
            if (student_id.text == "") {
              Fluttertoast.showToast(
                  msg: "Textfield is Emtpy!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (last_name.text == "") {
              Fluttertoast.showToast(
                  msg: "Textfield is Emtpy!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              addVoters();
            }
          },
          child: Text("Register",
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

  var new_password = TextEditingController();

  _requestChangePassword(BuildContext contextD, String votersID) {
    void requestPassword() async {
      String apiUrl = globals.endpoint + "request_change_password.php";
      var _response = await http.post(Uri.parse(apiUrl), body: {
        "votersID": votersID,
        "password": new_password.text.replaceAll(' ', '').toLowerCase(),
      });
      var message = json.decode(_response.body);
      if (message == "Success") {
        Fluttertoast.showToast(
            msg: "Changed Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.of(context, rootNavigator: true).pop(context);
        setState(() {
          new_password.text = "";
        });
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

    AlertDialog alert = AlertDialog(
      titlePadding: EdgeInsets.only(top: 15, left: 18, bottom: 15),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      actionsPadding: EdgeInsets.only(
        bottom: 5,
        right: 10,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Builder(
            builder: (context) {
              return Container(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    obscureText: _passwordVisible,
                    controller: new_password,
                    decoration: InputDecoration(
                      isDense: true,
                      label: Text("New Password"),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          !_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ));
            },
          );
        },
      ),
      title: Text(
        "Request Change Password",
        style: TextStyle(
            color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(50, 40),
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel",
              style: TextStyle(
                color: Colors.indigo,
              )),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(50, 40),
            padding: EdgeInsets.symmetric(horizontal: 15),
          ),
          onPressed: () {
            if (new_password.text == "") {
              Fluttertoast.showToast(
                  msg: "Textfield is Empty!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              requestPassword();
            }
          },
          child: Text("Submit",
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

  void addVoters() async {
    String apiUrl = globals.endpoint + "add_voters.php";
    var _response = await http.post(Uri.parse(apiUrl), body: {
      "student_id": student_id.text,
      "password": last_name.text.replaceAll(' ', '').toLowerCase(),
    });
    var message = json.decode(_response.body);
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
        student_id.text = "";
        last_name.text = "";
      });
    } else if (message == "duplicateStudentID") {
      Fluttertoast.showToast(
          msg: "Student ID Cannot Duplicate",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("Voters"),
        centerTitle: true,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FutureBuilder(
            future: _getVoters(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List list = snapshot.data;

                return list.isEmpty
                    ? Center(
                        child: Text("No Voters Found"),
                      )
                    : ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          List list = snapshot.data;
                          int index_id = index + 1;
                          return InkWell(
                            onLongPress: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading:
                                              new Icon(Icons.change_circle),
                                          title: new Text(
                                              'Request Change Password'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _requestChangePassword(context,
                                                list[index]['votersID']);
                                          },
                                        ),
                                        ListTile(
                                          leading: new Icon(Icons.delete),
                                          title: new Text('Delete'),
                                          onTap: () async {
                                            String apiUrl = globals.endpoint +
                                                "delete_voters.php";
                                            var _response = await http
                                                .post(Uri.parse(apiUrl), body: {
                                              'votersID': list[index]
                                                  ['votersID']
                                            });

                                            Fluttertoast.showToast(
                                                msg: "Deleted Successfully",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Card(
                              child: ListTile(
                                leading: Text(
                                  "$index_id" + ".",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.indigo,
                                      fontSize: 16),
                                ),
                                minLeadingWidth: 0.0,
                                dense: true,
                                title: Text(list[index]['student_id'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          );
                        });
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addVoters(context);
        },
        label: Text("Add Voters"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
