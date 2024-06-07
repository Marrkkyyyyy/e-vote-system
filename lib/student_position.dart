import 'package:flutter/material.dart';
import 'package:voting_system/model.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class studentPosition extends StatefulWidget {
  final String positionID;
  final String votersID;
  final String max_vote;
  studentPosition(
      {required this.positionID,
      required this.votersID,
      required this.max_vote});
  @override
  State<studentPosition> createState() => _studentPositionState();
}

class _studentPositionState extends State<studentPosition> {
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  List _data = [];
  List<VoteList> data_list = [];
  String message = "";
  List<bool> _isChecked = [];

  getList() async {
    String apiUrl = globals.endpoint + "display_candidate.php";
    var _response = await http.post(Uri.parse(apiUrl),
        body: {"positionID": widget.positionID, "votersID": widget.votersID});

    if (_response.statusCode == 200) {
      setStateIfMounted(() {
        _data = json.decode(_response.body);

        _isChecked = List<bool>.filled(_data.length, false);
      });

      return _data;
    }
  }

  Future _getCandidate() async {
    String apiUrl = globals.endpoint + "display_candidate.php";
    var _response = await http.post(Uri.parse(apiUrl),
        body: {"positionID": widget.positionID, "votersID": widget.votersID});

    if (_response.statusCode == 200) {
      setStateIfMounted(() {});

      return json.decode(_response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCandidate();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("President"),
        centerTitle: true,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FutureBuilder(
            future: _getCandidate(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List list = snapshot.data;

                return list.isEmpty
                    ? Center(
                        child: Text("No Candidate Found"),
                      )
                    : _data[0] == 'VoteAlready'
                        ? voted()
                        : ListView.builder(
                            itemCount: _data.length,
                            itemBuilder: (context, index) {
                              int index_id = index + 1;
                              return Card(
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
                                  title: Text(
                                      _data[index]['last_name'] +
                                          ", " +
                                          _data[index]['first_name'] +
                                          " " +
                                          _data[index]['middle_initial'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  trailing: Checkbox(
                                    value: _isChecked[index],
                                    onChanged: (val) {
                                      setState(
                                        () {
                                          _isChecked[index] = val!;
                                          // print(_data[index]['candidateID']);
                                          // print(widget.positionID);
                                          // print(widget.votersID);
                                          // print(widget.max_vote);
                                          // print(_isChecked[index]);

                                          if (_isChecked[index] == true) {
                                            data_list.add(VoteList(
                                                votersID: widget.votersID,
                                                candidateID: _data[index]
                                                    ['candidateID'],
                                                positionID: widget.positionID,
                                                isChecked: _isChecked[index]));
                                          } else {
                                            data_list.removeWhere((item) =>
                                                item.candidateID ==
                                                _data[index]['candidateID']);
                                          }
                                        },
                                      );
                                    },
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
      floatingActionButton: message == 'VoteAlready'
          ? Container()
          : FloatingActionButton.extended(
              onPressed: () async {
                if (data_list.length == 0) {
                  Fluttertoast.showToast(
                      msg: "Error!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (data_list.length > int.parse(widget.max_vote)) {
                  Fluttertoast.showToast(
                      msg: "You have reached the maximum vote (Maximum Vote: " +
                          widget.max_vote +
                          ")",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  addVote();
                }
              },
              label: Text("Submit Vote"),
              backgroundColor: Colors.indigo,
            ),
    );
  }

  Widget voted() {
    message = "VoteAlready";

    return Center(
      child: Text("You have already voted for this position",
          style: TextStyle(
            fontSize: 16,
          )),
    );
  }

  void addVote() async {
    var body = json.encode(data_list);
    String apiUrl = globals.endpoint + "add_vote.php";
    var _response = await http.post(Uri.parse(apiUrl), body: {"list": body});
    var result = _response.body.substring(_response.body.length - 7);
    if (result == "Success") {
      Fluttertoast.showToast(
          msg: "Success!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context, rootNavigator: true).pop(context);
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
