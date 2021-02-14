import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mwloadouts/models/user.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dbRef = FirebaseFirestore.instance;
  String userID = '';

  // get the current Users Uid
  String getUid() {
    String user = _auth.currentUser.uid;
    return user;
  }

  Future createNewUser(String username, String email) async {
    print("database.dart: starting createNewUser()");
    userID = getUid();
    await dbRef.collection("users").doc(userID).set({
      'userKey': userID,
      'username': username,
      'email': email,
      'searchKey': username.substring(0, 1).toUpperCase(),
    });
    print("database.dart: Username & Email set within database");
    print("database.dart: await copyOverDefaultLoadouts()");
    var result = await copyOverDefaultLoadouts();
    print("database.dart: copyOverDefaultLoadouts() finished");
  }

  copyOverDefaultLoadouts() async {
    print("database.dart: starting copyOverDefaultLoadouts");
    var result = await dbRef.collection('loadouts').get().then((querySnap) => {
          querySnap.docs.forEach((res) {
            dbRef
                .collection('users')
                .doc(userID)
                .collection('loadouts')
                .doc(res.id)
                .set(res.data());
          })
        });
  }

  Future getUserLoadouts(bool isUser, String username, String userkey) async {
    print("database.dart: started getUserLoadouts()");
    if (isUser) {
      userID = await getUid();
      await new Future.delayed(new Duration(milliseconds: 1000));
      QuerySnapshot qn = await dbRef
          .collection('users')
          .doc(userID)
          .collection('loadouts')
          .get();
      print("database.dart: returning QuerySnapshot from getUserLoadouts()");
      print("database.dart: QuerySnapshot is " + qn.docs.length.toString());
      return qn.docs;
    } else {
      print("database.dart: selected another user");
      await new Future.delayed(new Duration(milliseconds: 1000));
      QuerySnapshot qn = await dbRef
          .collection('users')
          .doc(userkey)
          .collection('loadouts')
          .get();
      return qn.docs;
    }
  }

  Future updateLoadoutName(String newName, String position) async {
    print("database.dart: starting updateLoadoutName()");
    userID = await getUid();
    await dbRef
        .collection("users")
        .doc(userID)
        .collection("loadouts")
        .doc(position)
        .set({
      "name": newName,
    }, SetOptions(merge: true));
  }

  getWeaponAttachments(bool isPrimary, bool isOverkill, String type,
      String name, String attachment) {
    print("database.dart: starting getWeaponAttachments();");
    print(isPrimary);
    print(isOverkill);
    print(isPrimary || isOverkill);
    String primary = '';

    (isPrimary || isOverkill)
        ? primary = 'primary_weapon'
        : primary = 'secondary_weapon';
    var gunDocument = dbRef
        .collection('guns')
        .doc(primary)
        .collection(type)
        .doc(name)
        .snapshots();

    return gunDocument;
  }

  Future updateAttachment(
      int slots,
      String position,
      bool isPrimary,
      String attachmentKey,
      String currAttachment,
      String attachmentValue) async {
    userID = await getUid();

    if (attachmentValue == "-") {
      print("database.dart: attachment being removed");
      isPrimary
          ? await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              "primary_slots": slots - 1,
              "primary": {attachmentKey: attachmentValue}
            }, SetOptions(merge: true))
          : await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              "secondary_slots": slots - 1,
              "secondary": {attachmentKey: attachmentValue}
            }, SetOptions(merge: true));
      return getUserLoadouts(true, null, null);
    } else if (currAttachment != "-") {
      print("database.dart: attachment is being changed");
      isPrimary
          ? await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              "primary": {attachmentKey: attachmentValue}
            }, SetOptions(merge: true))
          : await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              "secondary": {attachmentKey: attachmentValue}
            }, SetOptions(merge: true));
      return getUserLoadouts(true, null, null);
    } else if (slots == 5) {
      print("database.dart: too many attachments being added");
      return -1;
    } else {
      print("database.dart: new attachment is being added");
      isPrimary
          ? await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              "primary_slots": slots + 1,
              "primary": {attachmentKey: attachmentValue}
            }, SetOptions(merge: true))
          : await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              "secondary_slots": slots + 1,
              "secondary": {attachmentKey: attachmentValue}
            }, SetOptions(merge: true));
      return getUserLoadouts(true, null, null);
    }
  }

  Future getWeaponList(bool isPrimary, bool isOverkill, String type) async {
    String primary = '';
    isPrimary || isOverkill
        ? primary = "primary_weapon"
        : primary = "secondary_weapon";
    QuerySnapshot weaponDocuments =
        await dbRef.collection("guns").doc(primary).collection(type).get();

    return weaponDocuments.docs;
  }

  Future setNewWeapon(bool isOverkill, bool isPrimary, String type, String name,
      String position, Iterable<String> keys, String imageURL) async {
    final userID = await getUid();
    String primaryText = '';
    isPrimary ? primaryText = "primary" : primaryText = "secondary";
    // if overkill
    isPrimary
        ? await dbRef
            .collection("users")
            .doc(userID)
            .collection("loadouts")
            .doc(position)
            .set({
            "primary_name": name,
            "primary_slots": 0,
            "primary_type": type,
            "primary": {}
          }, SetOptions(merge: true))
        : await dbRef
            .collection("users")
            .doc(userID)
            .collection("loadouts")
            .doc(position)
            .set({
            "secondary_name": name,
            "secondary_slots": 0,
            "secondary_type": type,
            "secondary": {}
          }, SetOptions(merge: true));

    for (var item in keys) {
      print("database.dart: for items in key...");
      print(item);
      item == "image"
          ? await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              primaryText: {
                item: imageURL,
              }
            }, SetOptions(merge: true))
          : await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .set({
              primaryText: {
                item: "-",
              }
            }, SetOptions(merge: true));
    }

    return getUserLoadouts(true, null, null);
  }

  getEquipment(bool isLethal) {
    String equipment;
    isLethal ? equipment = "lethal" : equipment = "tactical";

    var equipmentDocument =
        dbRef.collection('equipment').doc(equipment).snapshots();

    return equipmentDocument;
  }

  updateEquipment(String position, bool isLethal, String newEquipment) async {
    print("database.dart: starting updateEquipment()");

    userID = await getUid();
    isLethal
        ? await dbRef
            .collection("users")
            .doc(userID)
            .collection("loadouts")
            .doc(position)
            .set({
            "lethal": newEquipment,
          }, SetOptions(merge: true))
        : await dbRef
            .collection("users")
            .doc(userID)
            .collection("loadouts")
            .doc(position)
            .set({
            "tactical": newEquipment,
          }, SetOptions(merge: true));
    return getUserLoadouts(true, null, null);
  }

  getPerks(int tierNumber) {
    print("database.dart: started getPerks()");
    var perkDocument =
        dbRef.collection('tiers').doc("tier $tierNumber").snapshots();

    return perkDocument;
  }

  updatePerks(
      String position, int tierNumber, String newPerk, String currPerk) async {
    print("database.dart: starting updatePerks();");
    userID = getUid();

    await dbRef
        .collection("users")
        .doc(userID)
        .collection("loadouts")
        .doc(position)
        .set({
      "tier $tierNumber": newPerk,
    }, SetOptions(merge: true));

    // if newPerk == "Overkill" then update entire second weapon
    if (tierNumber == 2) {
      if (newPerk.toLowerCase() == "overkill") {
        if (currPerk.toLowerCase() != "overkill") {
          await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .update({
            "secondary_name": "AK47",
            "secondary_type": "assault_rifles",
            "secondary_slots": 0,
            "secondary": {
              "ammunition": "-",
              "barrel": "-",
              "image": "gs://mwloadouts.appspot.com/guns/primary/ar/AK47.png",
              "laser": "-",
              "muzzle": "-",
              "optic": "-",
              "perks": "-",
              "stock": "-",
              "underbarrel": "-",
            }
          });
        } else {}
      } else {
        if (currPerk.toLowerCase() == "overkill") {
          await dbRef
              .collection("users")
              .doc(userID)
              .collection("loadouts")
              .doc(position)
              .update({
            "secondary_name": "M1911",
            "secondary_type": "pistols",
            "secondary_slots": 0,
            "secondary": {
              "ammunition": "-",
              "barrel": "-",
              "image":
                  "gs://mwloadouts.appspot.com/guns/secondary/pistols/1911.png",
              "laser": "-",
              "muzzle": "-",
              "optic": "-",
              "perks": "-",
              "rear grip": "-",
              "trigger action": "-",
            }
          });
        }
      }
    }

    return getUserLoadouts(true, null, null);
  }

  searchByName(String searchField) {
    return dbRef
        .collection("users")
        .where(
          "searchKey",
          isEqualTo: searchField.substring(0, 1).toUpperCase(),
        )
        .get();
  }
}
