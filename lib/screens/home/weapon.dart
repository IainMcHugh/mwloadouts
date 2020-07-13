import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mwloadouts/screens/home/loadout.dart';
import 'package:mwloadouts/services/database.dart';

import 'package:basic_utils/basic_utils.dart';

class Weapon extends StatefulWidget {
  final bool isOverkill;
  final bool isPrimary;
  final String weaponType;
  final String position;

  Weapon({this.isOverkill, this.isPrimary, this.weaponType, this.position});

  @override
  _WeaponState createState() => _WeaponState();
}

class _WeaponState extends State<Weapon> {
  final DatabaseService _database = DatabaseService();
  var type = "";

  @override
  void initState() {
    super.initState();
    type = widget.weaponType;
  }

  drawerListTile(String headingVal) {
    // split headingVal by "_"
    // toUpperCase
    var test = headingVal.split("_");
    var test2 = test.join(" ");
    String test3 = StringUtils.capitalize(test2);
    return ListTile(
      title: Text(
        test3,
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
      ),
      onTap: () {
        setState(() {
          type = headingVal;
        });
        Navigator.pop(context);
      },
    );
  }

  navigateBackToLoadoutPage(DocumentSnapshot loadout) {
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
    return Container(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(30, 30, 30, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(20, 20, 20, 1),
          title: Text(
            "Weapon",
            style: TextStyle(
              color: Color.fromRGBO(240, 240, 240, 1),
            ),
          ),
          bottom: PreferredSize(
            child: Container(
              color: Color.fromRGBO(107, 202, 250, 1),
              height: 2,
            ),
            preferredSize: Size.fromHeight(4),
          ),
        ),
        drawer: widget.isPrimary || widget.isOverkill
            ? Drawer(
                child: Container(
                  color: Color.fromRGBO(40, 40, 40, 1),
                  child: ListView(
                    children: <Widget>[
                      DrawerHeader(
                        child: Text(
                          "Weapon Type",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(30, 30, 30, 1),
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromRGBO(107, 202, 250, 1),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      drawerListTile("assault_rifles"),
                      drawerListTile("sub_machine_guns"),
                      drawerListTile("light_machine_guns"),
                      drawerListTile("shotguns"),
                      drawerListTile("marksman_rifles"),
                      drawerListTile("snipers"),
                    ],
                  ),
                ),
              )
            : Drawer(
                child: Container(
                  color: Color.fromRGBO(40, 40, 40, 1),
                  child: ListView(
                    children: <Widget>[
                      DrawerHeader(
                        child: Text(
                          "Weapon Type",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(30, 30, 30, 1),
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromRGBO(107, 202, 250, 1),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      drawerListTile("pistols"),
                    ],
                  ),
                ),
              ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FutureBuilder(
                future: _database.getWeaponList(
                    widget.isPrimary, widget.isOverkill, type),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text("Loading..."),
                    );
                  } else {
                    return ListView.builder(
                        physics: new NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snap.data.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot weapons = snap.data[index];
                          print(weapons.data.keys);
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            title: Text(
                              weapons.documentID,
                              style: TextStyle(
                                  color: Color.fromRGBO(240, 240, 240, 1),
                                  fontSize: 20),
                            ),
                            onTap: () async {
                              _loading();
                              // PASSING WEAPON DATA KEYS INCLUDES IMAGE: "gs.ww..." need to pass value as well!
                              String imageURL = weapons.data["image"];
                              print(imageURL);
                              var listLoadout = await _database.setNewWeapon(
                                  widget.isOverkill,
                                  widget.isPrimary,
                                  type,
                                  weapons.documentID,
                                  widget.position,
                                  weapons.data.keys,
                                  imageURL);
                              // await new Future.delayed(new Duration(milliseconds: 3000));
                              int pos = int.parse(widget.position);
                              DocumentSnapshot loadout = listLoadout[pos];
                              navigateBackToLoadoutPage(loadout);
                            },
                          );
                        });
                  }
                },
              ),
              SizedBox(
                height: AdSize.banner.height + 5.0,
              ),
            ],
          ),
        ),
        // body: FutureBuilder(
        //   future: _database.getWeaponList(
        //       widget.isPrimary, widget.isOverkill, type),
        //   builder: (context, snap) {
        //     if (snap.connectionState == ConnectionState.waiting) {
        //       return Center(
        //         child: Text("Loading..."),
        //       );
        //     } else {
        //       return ListView.builder(
        //           itemCount: snap.data.length,
        //           itemBuilder: (context, index) {
        //             DocumentSnapshot weapons = snap.data[index];
        //             print(weapons.data.keys);
        //             return ListTile(
        //               contentPadding:
        //                   EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        //               title: Text(
        //                 weapons.documentID,
        //                 style: TextStyle(
        //                     color: Color.fromRGBO(240, 240, 240, 1),
        //                     fontSize: 20),
        //               ),
        //               onTap: () async {
        //                 // PASSING WEAPON DATA KEYS INCLUDES IMAGE: "gs.ww..." need to pass value as well!
        //                 String imageURL = weapons.data["image"];
        //                 print(imageURL);
        //                 var listLoadout = await _database.setNewWeapon(
        //                     widget.isOverkill,
        //                     widget.isPrimary,
        //                     type,
        //                     weapons.documentID,
        //                     widget.position,
        //                     weapons.data.keys,
        //                     imageURL);
        //                 // await new Future.delayed(new Duration(milliseconds: 3000));
        //                 int pos = int.parse(widget.position);
        //                 DocumentSnapshot loadout = listLoadout[pos];
        //                 navigateBackToLoadoutPage(loadout);
        //               },
        //             );
        //           });
        //     }
        //   },
        // ),
      ),
    );
  }
}
