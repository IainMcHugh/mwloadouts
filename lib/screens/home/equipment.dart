import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mwloadouts/screens/home/loadout.dart';
import 'package:mwloadouts/services/database.dart';

class Equipment extends StatefulWidget {
  final String position;
  final bool isLethal;

  Equipment({this.position, this.isLethal});

  @override
  _EquipmentState createState() => _EquipmentState();
}

class _EquipmentState extends State<Equipment> {
  final DatabaseService _database = DatabaseService();

  navigateToLoadoutPage(DocumentSnapshot loadout) {
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (context) => Loadout(loadout: loadout)));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Loadout(
          loadout: loadout,
          isUser: true,
        ),
      ),
    );
  }

  _loading() {
    // TextEditingController controller = TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(30, 30, 30, 1),
      appBar: AppBar(
        title: widget.isLethal
            ? Text("Lethal Equipment")
            : Text("Tactical Equipment"),
        backgroundColor: Color.fromRGBO(20, 20, 20, 1),
      ),
      body: Builder(
        builder: (scaffoldContext) => Card(
          color: Color.fromRGBO(40, 40, 40, 1),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: _database.getEquipment(widget.isLethal),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        child: Text(
                          "Loading...",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      print("INSIDE EQUIPMENT PAGE");
                      print(snapshot.data.data);
                      return ListView.builder(
                          physics: new NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                title: Text(
                                  snapshot.data[index.toString()],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                onTap: () async {
                                  _loading();
                                  var listLoadout =
                                      await _database.updateEquipment(
                                          widget.position, // "0"
                                          widget.isLethal, // "true"
                                          snapshot.data[index
                                              .toString()] // clicked equipment
                                          );
                                  int pos = int.parse(widget.position);
                                  DocumentSnapshot loadout = listLoadout[pos];
                                  navigateToLoadoutPage(loadout);
                                });
                          });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
