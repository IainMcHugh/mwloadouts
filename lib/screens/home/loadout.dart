import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:mwloadouts/screens/home/attachment.dart';
import 'package:mwloadouts/screens/home/equipment.dart';
import 'package:mwloadouts/screens/home/home.dart';
import 'package:mwloadouts/screens/home/perk.dart';
import 'package:mwloadouts/screens/home/weapon.dart';
import 'package:mwloadouts/services/database.dart';
import 'package:mwloadouts/services/storage.dart';

import 'package:basic_utils/basic_utils.dart';

class Loadout extends StatefulWidget {
  final DocumentSnapshot loadout;
  final bool isUser;
  final String username;
  final String userKey;

  Loadout({this.loadout, this.isUser, this.username, this.userKey});

  @override
  _LoadoutState createState() => _LoadoutState();
}

class _LoadoutState extends State<Loadout> {
  final DatabaseService _database = DatabaseService();
  final StorageService _storage = StorageService();

  var attachKeysPrimary = [];
  var attachValuesPrimary = [];

  var attachKeysSecondary = [];
  var attachValuesSecondary = [];

  String loadoutName = "";
  bool isOverkill = false;

  @override
  void initState() {
    super.initState();
    loadoutName = widget.loadout.data['name'];

    if (widget.loadout.data['tier 2'].toLowerCase() == "overkill") {
      isOverkill = true;
    }
  }

  int getLoadoutAttachmentsQtyPrimary() {
    int attachQtyPrimary = 0;
    widget.loadout.data["primary"].forEach(
      (key, value) => {
        if (key == "image")
          {
            // do nothing
          }
        else
          {
            print(value),
            attachKeysPrimary.add(key),
            attachValuesPrimary.add(value),
            attachQtyPrimary++
          }
      },
    );
    return attachQtyPrimary;
  }

  int getLoadoutAttachmentsQtySecondary() {
    int attachQtySecondary = 0;
    widget.loadout.data["secondary"].forEach(
      (key, value) => {
        if (key == "image")
          {
            // do nothing
          }
        else
          {
            print(value),
            attachKeysSecondary.add(key),
            attachValuesSecondary.add(value),
            attachQtySecondary++
          }
      },
    );
    return attachQtySecondary;
  }

  navigateToAttachmentPage(String attachmentKey, String attachmentValue,
      bool isPrimary, bool isOverkill) {
    print("Made it to: navigateToAttachmentPage");
    print(isOverkill);
    if (isPrimary) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Attachment(
            slots: widget.loadout.data["primary_slots"],
            loadout: widget.loadout,
            position: widget.loadout.data["position"],
            isPrimary: isPrimary,
            isOverkill: isOverkill,
            type: widget.loadout.data['primary_type'],
            weapon: widget.loadout.data['primary_name'],
            attachmentKey: attachmentKey.toLowerCase(),
            attachmentValue: attachmentValue,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Attachment(
            slots: widget.loadout.data["secondary_slots"],
            loadout: widget.loadout,
            position: widget.loadout.data["position"],
            isPrimary: isPrimary,
            isOverkill: isOverkill,
            type: widget.loadout.data['secondary_type'],
            weapon: widget.loadout.data['secondary_name'],
            attachmentKey: attachmentKey.toLowerCase(),
            attachmentValue: attachmentValue,
          ),
        ),
      );
    }
  }

  navigateToWeaponPage(bool isPrimary, bool isOverkill, String weaponType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Weapon(
          isOverkill: isOverkill,
          isPrimary: isPrimary,
          weaponType: weaponType,
          position: widget.loadout.data["position"],
        ),
      ),
    );
  }

  navigateToEquipmentPage(bool isLethal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Equipment(
          position: widget.loadout.data['position'],
          isLethal: isLethal,
        ),
      ),
    );
  }

  navigateToPerkPage(int tierNumber, String currPerk2) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Perk(
            position: widget.loadout.data['position'],
            tierNumber: tierNumber,
            currPerk2: currPerk2),
      ),
    );
  }

  Future<bool> _navigateBackwards() {
    if (widget.isUser) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    } else {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Home(username: widget.username, userkey: widget.userKey),
        ),
      );
      // Navigator.pop(context);
    }
  }

  _changeLoadoutName() {
    TextEditingController controller = TextEditingController();
    print("HELLLO");
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update Loadout Name:"),
            content: TextField(
              autofocus: true,
              controller: controller,
            ),
            actions: <Widget>[
              RaisedButton(
                child: Text("Cancel"),
                onPressed: () => {
                  Navigator.pop(context),
                },
              ),
              RaisedButton(
                child: Text("Update"),
                onPressed: () async => {
                  print(controller.text),
                  // Update database with New Name
                  await _database.updateLoadoutName(
                      controller.text, widget.loadout.data['position']),
                  // update local Loadout Name displayed
                  this.setState(() {
                    loadoutName = controller.text;
                  }),
                  Navigator.pop(context)
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _navigateBackwards,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(30, 30, 30, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(20, 20, 20, 1),
          bottom: PreferredSize(
            child: Container(
              color: Color.fromRGBO(107, 202, 250, 1),
              height: 2,
            ),
            preferredSize: Size.fromHeight(4),
          ),
          title: GestureDetector(
            onTap: () {
              _changeLoadoutName();
            },
            child: Text(
              loadoutName,
              style: TextStyle(
                color: Color.fromRGBO(240, 240, 240, 1),
              ),
            ),
          ),
          actions: <Widget>[
            widget.isUser
                ? IconButton(
                    icon: Icon(
                      Icons.create,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _changeLoadoutName();
                    },
                  )
                : Container()
          ],
        ),
        body: SingleChildScrollView(
          key: PageStorageKey<String>("test"),
          child: Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Column(children: <Widget>[
              Card(
                margin: EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 10),
                color: Color.fromRGBO(20, 20, 20, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        widget.loadout.data['primary_name'],
                        style: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    widget.isUser
                        ? FlatButton(
                            color: Colors.transparent,
                            child: Icon(Icons.play_arrow, color: Colors.orange),
                            onPressed: () {
                              navigateToWeaponPage(
                                true,
                                isOverkill,
                                widget.loadout.data['primary_type'],
                              );
                            },
                          )
                        : Container()
                  ],
                ),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: FutureBuilder<String>(
                  future:
                      // _storage.getWeaponImage(widget.loadout.data["primary_image"]),
                      _storage.getWeaponImage(
                          widget.loadout.data["primary"]["image"]),
                  builder: (context, image) {
                    if (image.hasData) {
                      return Image(
                        // color: Colors.transparent,
                        image: AdvancedNetworkImage(
                          image.data,
                          timeoutDuration: Duration(minutes: 1),
                          useDiskCache: true,
                          cacheRule: CacheRule(
                            maxAge: const Duration(days: 7),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListTile(
                  title: Text(
                    'Attachments',
                    style: TextStyle(
                        color: Color.fromRGBO(107, 202, 250, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    "Slots: " +
                        widget.loadout.data['primary_slots'].toString() +
                        "/5",
                    style: TextStyle(
                        color: Color.fromRGBO(240, 240, 240, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListView.builder(
                    physics: new NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: getLoadoutAttachmentsQtyPrimary(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          title: Text(
                            StringUtils.capitalize(
                                attachKeysPrimary[index].toString()),
                            style: TextStyle(
                                color: Color.fromRGBO(107, 202, 250, 1),
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            attachValuesPrimary[index].toString(),
                            style: TextStyle(
                                color: Color.fromRGBO(240, 240, 240, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                          onTap: () => widget.isUser
                              ? navigateToAttachmentPage(
                                  attachKeysPrimary[index],
                                  attachValuesPrimary[index].toString(),
                                  true,
                                  isOverkill)
                              : null);
                    }),
              ),
              Card(
                margin: EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 10),
                color: Color.fromRGBO(20, 20, 20, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        widget.loadout.data['secondary_name'],
                        style: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    widget.isUser
                        ? FlatButton(
                            color: Colors.transparent,
                            child: Icon(Icons.play_arrow, color: Colors.orange),
                            onPressed: () {
                              navigateToWeaponPage(
                                // Need to pass true for overkill
                                // and false for secondary
                                false,
                                isOverkill,
                                widget.loadout.data['secondary_type'],
                              );
                            },
                          )
                        : Container()
                  ],
                ),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: FutureBuilder<String>(
                  future: _storage.getWeaponImage(
                      widget.loadout.data["secondary"]["image"]),
                  builder: (context, image) {
                    if (image.hasData) {
                      return Image(
                        image: AdvancedNetworkImage(
                          image.data,
                          timeoutDuration: Duration(minutes: 1),
                          useDiskCache: true,
                          cacheRule: CacheRule(
                            maxAge: const Duration(days: 7),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListTile(
                  title: Text(
                    'Attachments',
                    style: TextStyle(
                        color: Color.fromRGBO(107, 202, 250, 1),
                        fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    "Slots: " +
                        widget.loadout.data['secondary_slots'].toString() +
                        "/5",
                    style: TextStyle(
                        color: Color.fromRGBO(240, 240, 240, 1),
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListView.builder(
                  physics: new NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: getLoadoutAttachmentsQtySecondary(),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        StringUtils.capitalize(
                            attachKeysSecondary[index].toString()),
                        style: TextStyle(
                            color: Color.fromRGBO(107, 202, 250, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        attachValuesSecondary[index].toString(),
                        style: TextStyle(
                            color: Color.fromRGBO(240, 240, 240, 1),
                            fontSize: 14,
                            fontWeight: FontWeight.w300),
                      ),
                      onTap: () => widget.isUser
                          ? navigateToAttachmentPage(
                              attachKeysSecondary[index],
                              attachValuesSecondary[index].toString(),
                              false,
                              isOverkill)
                          : null,
                    );
                  },
                ),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListTile(
                    title: Text(
                      "Lethal",
                      style: TextStyle(
                          color: Color.fromRGBO(107, 202, 250, 1),
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      widget.loadout.data["lethal"],
                      style: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontWeight: FontWeight.w300),
                    ),
                    onTap: () =>
                        widget.isUser ? navigateToEquipmentPage(true) : null),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListTile(
                    title: Text(
                      "Tactical",
                      style: TextStyle(
                          color: Color.fromRGBO(107, 202, 250, 1),
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      widget.loadout.data["tactical"],
                      style: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontWeight: FontWeight.w300),
                    ),
                    onTap: () =>
                        widget.isUser ? navigateToEquipmentPage(false) : null),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListTile(
                    title: Text(
                      "Tier 1",
                      style: TextStyle(
                          color: Color.fromRGBO(107, 202, 250, 1),
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      widget.loadout.data["tier 1"],
                      style: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontWeight: FontWeight.w300),
                    ),
                    onTap: () => widget.isUser
                        ? navigateToPerkPage(
                            1,
                            widget.loadout.data['tier 2'],
                          )
                        : null),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListTile(
                    title: Text(
                      "Tier 2",
                      style: TextStyle(
                          color: Color.fromRGBO(107, 202, 250, 1),
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      widget.loadout.data["tier 2"],
                      style: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontWeight: FontWeight.w300),
                    ),
                    onTap: () => widget.isUser
                        ? navigateToPerkPage(
                            2,
                            widget.loadout.data['tier 2'],
                          )
                        : null),
              ),
              Card(
                color: Color.fromRGBO(20, 20, 20, 1),
                child: ListTile(
                    title: Text(
                      "Tier 3",
                      style: TextStyle(
                          color: Color.fromRGBO(107, 202, 250, 1),
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      widget.loadout.data["tier 3"],
                      style: TextStyle(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          fontWeight: FontWeight.w300),
                    ),
                    onTap: () => widget.isUser
                        ? navigateToPerkPage(
                            3,
                            widget.loadout.data['tier 2'],
                          )
                        : null),
              ),
              SizedBox(
                height: AdSize.banner.height + 5.0,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
