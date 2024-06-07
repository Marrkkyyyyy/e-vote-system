import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voting_system/admin.dart';
import 'package:voting_system/main.dart';
import 'package:voting_system/position.dart';
import 'package:voting_system/voters.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class adminDashboard extends StatefulWidget {
  final String adminID;
  final String username;
  final String email;
  final String password;

  adminDashboard(
      {required this.adminID,
      required this.username,
      required this.email,
      required this.password});

  @override
  State<adminDashboard> createState() => _adminDashboardState();
}

class _adminDashboardState extends State<adminDashboard> {
  alertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      titlePadding: EdgeInsets.fromLTRB(25, 30, 25, 0),
      contentPadding: EdgeInsets.fromLTRB(25, 15, 25, 10),
      title: Text("Reseting...",
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
          )),
      content: Text("This will delete all votes and counting back to 0.",
          style: GoogleFonts.assistant(
            fontSize: 17,
            height: 1.5,
            letterSpacing: 1.3,
          )),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(80, 40),
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(0),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.indigo, fontSize: 16),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(80, 40),
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(0),
          ),
          onPressed: () {
            _reset();
          },
          child: Text(
            "Reset",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
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

  void _reset() async {
    String apiUrl = globals.endpoint + "reset_votes.php";
    var _response = await http.post(
      Uri.parse(apiUrl),
    );
    var message = json.decode(_response.body);
    if (message == "Success") {
      Fluttertoast.showToast(
          msg: "Votes Reset Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context, rootNavigator: true).pop(context);
      Navigator.of(context, rootNavigator: true).pop(context);
    } else {
      Fluttertoast.showToast(
          msg: "Error in Reseting Votes into Database!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  logout(BuildContext context) {
    AlertDialog alert = AlertDialog(
      actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      titlePadding: EdgeInsets.fromLTRB(25, 30, 25, 0),
      contentPadding: EdgeInsets.fromLTRB(25, 15, 25, 10),
      title: Text("Are you sure?",
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
          )),
      content: Text("Do you want to logout?",
          style: GoogleFonts.assistant(
            fontSize: 17,
            height: 1.5,
            letterSpacing: 1.3,
          )),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(80, 40),
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(0),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.indigo, fontSize: 16),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(80, 40),
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(0),
          ),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) => Login()));
          },
          child: Text(
            "Logout",
            style: TextStyle(color: Colors.indigo, fontSize: 16),
          ),
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

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future _getPosition() async {
    String apiUrl = globals.endpoint + "display_position.php";
    var _response = await http.post(Uri.parse(apiUrl));
    if (_response.statusCode == 200) {
      setStateIfMounted(() {});

      return json.decode(_response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    _getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return logout(context);
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 150,
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.indigo),
                  accountName: Text(
                    widget.username,
                    style: TextStyle(fontSize: 20),
                  ),
                  accountEmail: Text(widget.email,
                      style: TextStyle(fontSize: 17),
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.indigo,
                ),
                title: Text("Admin"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => admin()));
                },
              ),
              ListTile(
                leading: Icon(Icons.supervised_user_circle_rounded,
                    color: Colors.indigo),
                title: Text("Voters"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => voters()));
                },
              ),
              ListTile(
                leading: Icon(Icons.supervised_user_circle_rounded,
                    color: Colors.indigo),
                title: Text("Reset Votes"),
                onTap: () {
                  alertDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.indigo),
                title: Text("Logout"),
                onTap: () {
                  logout(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text("Dashboard"),
          centerTitle: true,
        ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: FutureBuilder(
              future: _getPosition(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List list = snapshot.data;

                  return list.isEmpty
                      ? Center(
                          child: Text("No Position Found"),
                        )
                      : ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            List list = snapshot.data;

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => position(
                                        positionID: list[index]['positionID'],
                                        positionName: list[index]
                                            ['position'])));
                              },
                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                  subtitle: Text("Maximum Vote: " +
                                      list[index]['max_vote']),
                                  trailing: PopupMenuButton(
                                      elevation: 2,
                                      offset: Offset(0, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      iconSize: 17,
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(
                                              value: 0,
                                              child: TextButton.icon(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _updatePosition(
                                                        context,
                                                        list[index]
                                                            ['positionID'],
                                                        list[index]['position'],
                                                        list[index]
                                                            ['max_vote']);
                                                  },
                                                  icon: Icon(Icons.edit,
                                                      color: Colors.indigo),
                                                  label: Text("Edit",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black)))),
                                          PopupMenuItem(
                                              value: 1,
                                              child: TextButton.icon(
                                                  onPressed: () async {
                                                    var url = globals.endpoint +
                                                        "delete_position.php";
                                                    http.post(Uri.parse(url),
                                                        body: {
                                                          'positionID':
                                                              list[index]
                                                                  ['positionID']
                                                        });
                                                    Navigator.pop(context);

                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Deleted Successfully",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.green,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  },
                                                  icon: Icon(Icons.delete,
                                                      color: Colors.indigo),
                                                  label: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ))),
                                        ];
                                      },
                                      onSelected: (value) async {
                                        if (value == 0) {
                                          _updatePosition(
                                              context,
                                              list[index]['positionID'],
                                              list[index]['position'],
                                              list[index]['max_vote']);
                                        } else if (value == 1) {
                                          var url = globals.endpoint +
                                              "delete_position.php";
                                          http.post(Uri.parse(url), body: {
                                            'positionID': list[index]
                                                ['positionID']
                                          });

                                          Fluttertoast.showToast(
                                              msg: "Deleted Successfully",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        }
                                      }),
                                  dense: true,
                                  title: Text(list[index]['position'],
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
            _addPosition(context);
          },
          label: Text("Add Position"),
          icon: Icon(Icons.add),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }

  var positionController = TextEditingController();
  var max_vote = TextEditingController();

  _addPosition(BuildContext contextD) {
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      actionsPadding: EdgeInsets.only(
        bottom: 5,
        right: 10,
        top: 5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      content: Builder(
        builder: (context) {
          return Container(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: positionController,
                decoration: InputDecoration(label: Text("Position")),
              ),
              TextFormField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                controller: max_vote,
                decoration: InputDecoration(label: Text("Maximum Vote")),
              ),
            ],
          ));
        },
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
            if (positionController.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (max_vote.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              addPosition();
            }
          },
          child: Text("Add",
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

  _updatePosition(BuildContext contextD, String positionID, String positionName,
      String maxVote) {
    var edit_positionController = TextEditingController(text: positionName);
    var edit_max_vote = TextEditingController(text: maxVote);

    void _editPosition() async {
      String apiUrl = globals.endpoint + "update_position.php";
      var _response = await http.post(Uri.parse(apiUrl), body: {
        'positionID': positionID,
        'position': edit_positionController.text,
        'max_vote': edit_max_vote.text,
      });
      var message = json.decode(_response.body);
      if (message == "Success") {
        Fluttertoast.showToast(
            msg: "Updated Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.of(context, rootNavigator: true).pop(context);
      } else {
        Fluttertoast.showToast(
            msg: "Error in Updating into Database!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      actionsPadding: EdgeInsets.only(
        bottom: 5,
        right: 10,
        top: 5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      content: Builder(
        builder: (context) {
          return Container(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: edit_positionController,
                decoration: InputDecoration(label: Text("Position")),
              ),
              TextFormField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                controller: edit_max_vote,
                decoration: InputDecoration(label: Text("Maximum Vote")),
              ),
            ],
          ));
        },
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
            if (edit_positionController.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (edit_max_vote.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              _editPosition();
            }
          },
          child: Text("Update",
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

  void addPosition() async {
    String apiUrl = globals.endpoint + "add_position.php";
    var _response = await http.post(Uri.parse(apiUrl), body: {
      "position": positionController.text,
      "max_vote": max_vote.text,
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
        positionController.text = "";
        max_vote.text = "";
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
}
