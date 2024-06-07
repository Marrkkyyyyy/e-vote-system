import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class position extends StatefulWidget {
  final String positionName;
  final String positionID;

  position({required this.positionID, required this.positionName});
  @override
  State<position> createState() => _positionState();
}

class _positionState extends State<position> {
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future _getCandidate() async {
    String apiUrl = globals.endpoint + "admin_display_candidate.php";
    var _response = await http
        .post(Uri.parse(apiUrl), body: {"positionID": widget.positionID});
    if (_response.statusCode == 200) {
      setStateIfMounted(() {});

      return json.decode(_response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCandidate();
  }

  bool percentage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(widget.positionName),
        centerTitle: true,
        actions: [
          percentage == false
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      percentage = true;
                    });
                  },
                  icon: Icon(Icons.numbers))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      percentage = false;
                    });
                  },
                  icon: Icon(Icons.percent))
        ],
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
                  : ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        List list = snapshot.data;

                        return InkWell(
                          onLongPress: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: new Icon(Icons.edit),
                                        title: new Text('Edit'),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          _editCandidate(
                                              context,
                                              list[index]['candidateID'],
                                              list[index]['first_name'],
                                              list[index]['last_name'],
                                              list[index]['middle_initial']);
                                        },
                                      ),
                                      ListTile(
                                        leading: new Icon(Icons.delete),
                                        title: new Text('Delete'),
                                        onTap: () async {
                                          String apiUrl = globals.endpoint +
                                              "delete_candidate.php";
                                          var _response = await http
                                              .post(Uri.parse(apiUrl), body: {
                                            'candidateID': list[index]
                                                ['candidateID']
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
                              minLeadingWidth: 0.0,
                              dense: true,
                              title: Text(
                                  list[index]['last_name'] +
                                      ", " +
                                      list[index]['first_name'] +
                                      " " +
                                      list[index]['middle_initial'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              trailing: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  width: 47,
                                  decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Text(
                                      percentage == true
                                          ? list[index]['total'] == null
                                              ? ("0" + "%")
                                              : (list[index]['total'] + "%")
                                          : list[index]['total_vote'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addCandidate(context);
        },
        label: Text("Add Candidates"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  var first_name = TextEditingController();
  var last_name = TextEditingController();
  var middle_initial = TextEditingController();

  _addCandidate(BuildContext contextD) {
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
                controller: last_name,
                decoration: InputDecoration(label: Text("Last Name")),
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: first_name,
                decoration: InputDecoration(label: Text("First Name")),
              ),
              TextFormField(
                inputFormatters: [
                  new LengthLimitingTextInputFormatter(1),
                ],
                textCapitalization: TextCapitalization.words,
                controller: middle_initial,
                decoration: InputDecoration(label: Text("Middle Initial")),
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
            if (first_name.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (last_name.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              addCandidate();
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

  _editCandidate(
    BuildContext contextD,
    String candidateID,
    String firstName,
    String middleInitial,
    String lastName,
  ) {
    var edit_first_name = TextEditingController(text: firstName);
    var edit_last_name = TextEditingController(text: middleInitial);
    var edit_middle_initial = TextEditingController(text: lastName);

    void _editCandidate() async {
      String apiUrl = globals.endpoint + "update_candidate.php";
      var _response = await http.post(Uri.parse(apiUrl), body: {
        'candidateID': candidateID,
        'first_name': edit_first_name.text,
        'last_name': edit_last_name.text,
        'middle_initial': edit_middle_initial.text,
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
                controller: edit_last_name,
                decoration: InputDecoration(label: Text("Last Name")),
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                controller: edit_first_name,
                decoration: InputDecoration(label: Text("First Name")),
              ),
              TextFormField(
                inputFormatters: [
                  new LengthLimitingTextInputFormatter(1),
                ],
                textCapitalization: TextCapitalization.words,
                controller: edit_middle_initial,
                decoration: InputDecoration(label: Text("Middle Initial")),
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
            if (edit_first_name.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (edit_last_name.text == "") {
              Fluttertoast.showToast(
                  msg: "TextField is Empty",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              _editCandidate();
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

  void addCandidate() async {
    String apiUrl = globals.endpoint + "add_candidate.php";
    var _response = await http.post(Uri.parse(apiUrl), body: {
      "positionID": widget.positionID,
      "first_name": first_name.text,
      "last_name": last_name.text,
      "middle_initial": middle_initial.text,
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
        first_name.text = "";
        last_name.text = "";
        middle_initial.text = "";
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
