import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mwloadouts/services/database.dart';

import 'loadout.dart';

class Perk extends StatefulWidget {
  final String position;
  final int tierNumber;
  final String currPerk2;

  Perk({this.position, this.tierNumber, this.currPerk2});

  @override
  _PerkState createState() => _PerkState();
}

class _PerkState extends State<Perk> {
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
    TextEditingController controller = TextEditingController();
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
        title: Text("Tier ${widget.tierNumber.toString()}"),
        backgroundColor: Color.fromRGBO(20, 20, 20, 1),
      ),
      body: Builder(
        builder: (scaffoldContext) => Card(
          color: Color.fromRGBO(40, 40, 40, 1),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: _database.getPerks(widget.tierNumber),
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
                      print(snapshot);
                      return ListView.builder(
                          physics: new NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            print("tier ${widget.tierNumber}");
                            print(snapshot.data.data[index.toString()]);
                            return ListTile(
                                title: Text(
                                  snapshot.data.data[index.toString()],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                onTap: () async {
                                  _loading();
                                  var listLoadout = await _database.updatePerks(
                                    widget.position, // "0"
                                    widget.tierNumber, // "tier 1"
                                    snapshot.data
                                        .data[index.toString()], // clicked perk
                                    widget.currPerk2,
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
