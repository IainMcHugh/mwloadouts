import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mwloadouts/screens/home/loadout.dart';
import 'package:mwloadouts/services/database.dart';

class Attachment extends StatefulWidget {
  final DocumentSnapshot loadout;
  final int slots;
  final String position;
  final bool isPrimary;
  final bool isOverkill;
  final String type;
  final String weapon;
  final String attachmentKey;
  final String attachmentValue;

  Attachment(
      {this.slots,
      this.loadout,
      this.position,
      this.isPrimary,
      this.isOverkill,
      this.type,
      this.weapon,
      this.attachmentKey,
      this.attachmentValue});

  @override
  _AttachmentState createState() => _AttachmentState();
}

class _AttachmentState extends State<Attachment> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(30, 30, 30, 1),
      appBar: AppBar(
        title: Text(widget.weapon + " - " + widget.attachmentKey),
        backgroundColor: Color.fromRGBO(20, 20, 20, 1),
      ),
      body: Builder(
        builder: (scaffoldContext) => Card(
          color: Color.fromRGBO(40, 40, 40, 1),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: _database.getWeaponAttachments(
                    widget.isPrimary,
                    widget.isOverkill,
                    widget.type,
                    widget.weapon,
                    widget.attachmentKey,
                  ),
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
                      // return Container();
                      return ListView.builder(
                          physics: new NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount:
                              snapshot.data.data[widget.attachmentKey].length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                title: Text(
                                  snapshot
                                      .data.data[widget.attachmentKey].values
                                      .elementAt(index),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                onTap: () async {
                                  _loading();
                                  var listLoadout =
                                      await _database.updateAttachment(
                                    widget.slots, // "0"
                                    widget.position, // "0"
                                    widget.isPrimary, // "true"
                                    widget.attachmentKey, // "ammunition"
                                    widget
                                        .attachmentValue, // "current attachment"
                                    snapshot
                                        .data.data[widget.attachmentKey].values
                                        .elementAt(
                                            index), // "clicked attachment"
                                  );
                                  if (listLoadout == -1) {
                                    print("TOO MANY ATTACHMENTS");
                                    Scaffold.of(scaffoldContext).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Error, too many attachments!"),
                                      ),
                                    );
                                    // Navigator.pop(context);
                                  } else {
                                    int pos = int.parse(widget.position);
                                    DocumentSnapshot loadout = listLoadout[pos];
                                    navigateToLoadoutPage(loadout);
                                  }
                                });
                          });
                    }
                  },
                ),
                widget.attachmentValue == "-"
                    ? Container()
                    : ListTile(
                        title: Text(
                          "Clear Attachment",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        onTap: () async {
                          var listLoadout = await _database.updateAttachment(
                              widget.slots,
                              widget.position,
                              widget.isPrimary,
                              widget.attachmentKey,
                              widget.attachmentValue,
                              "-");
                          int pos = int.parse(widget.position);
                          DocumentSnapshot loadout = listLoadout[pos];
                          navigateToLoadoutPage(loadout);
                        },
                      ),
                SizedBox(
                  height: AdSize.banner.height + 5.0,
                ),
              ],
            ),
          ),
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
}
