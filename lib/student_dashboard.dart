import 'package:flutter/material.dart';
import 'package:voting_system/main.dart';
import 'package:voting_system/position.dart';
import 'package:voting_system/student_position.dart';
import 'package:voting_system/voters.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class studentDashboard extends StatefulWidget {
  final String votersID;
  final String student_id;
  final String password;
  final String password_changed;

  studentDashboard(
      {required this.votersID,
      required this.student_id,
      required this.password,
      required this.password_changed});

  @override
  State<studentDashboard> createState() => _studentDashboardState();
}

class _studentDashboardState extends State<studentDashboard> {
  alertDialog(BuildContext context) {
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
        return alertDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                alertDialog(context);
              },
              icon: Icon(Icons.logout)),
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
                                    builder: (BuildContext context) =>
                                        studentPosition(
                                          positionID: list[index]['positionID'],
                                          votersID: widget.votersID,
                                          max_vote: list[index]['max_vote'],
                                        )));
                              },
                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                  subtitle: Text("Maximum Vote: " +
                                      list[index]['max_vote']),
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
      ),
    );
  }
}
