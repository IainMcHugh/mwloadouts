import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mwloadouts/models/user.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dbRef = Firestore.instance;
  String userID = '';

  // get the current Users Uid
  Future<String> getUid() async {
    final FirebaseUser user = await _auth.currentUser();
    return user.uid.toString();
  }

  Future createNewUser(String username, String email) async {
    print("database.dart: starting createNewUser()");
    userID = await getUid();
    await dbRef.collection("users").document(userID).setData({
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
    var result =
        await dbRef.collection('loadouts').getDocuments().then((querySnap) => {
              querySnap.documents.forEach((result) {
                dbRef
                    .collection('users')
                    .document(userID)
                    .collection('loadouts')
                    .document(result.documentID)
                    .setData(result.data);
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
          .document(userID)
          .collection('loadouts')
          .getDocuments();
      print("database.dart: returning QuerySnapshot from getUserLoadouts()");
      print(
          "database.dart: QuerySnapshot is " + qn.documents.length.toString());
      return qn.documents;
    } else {
      print("database.dart: selected another user");
      await new Future.delayed(new Duration(milliseconds: 1000));
      QuerySnapshot qn = await dbRef
          .collection('users')
          .document(userkey)
          .collection('loadouts')
          .getDocuments();
      return qn.documents;
    }
  }

  Future updateLoadoutName(String newName, String position) async {
    print("database.dart: starting updateLoadoutName()");
    userID = await getUid();
    await dbRef
        .collection("users")
        .document(userID)
        .collection("loadouts")
        .document(position)
        .setData({
      "name": newName,
    }, merge: true);
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
        .document(primary)
        .collection(type)
        .document(name)
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
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              "primary_slots": slots - 1,
              "primary": {attachmentKey: attachmentValue}
            }, merge: true)
          : await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              "secondary_slots": slots - 1,
              "secondary": {attachmentKey: attachmentValue}
            }, merge: true);
      return getUserLoadouts(true, null, null);
    } else if (currAttachment != "-") {
      print("database.dart: attachment is being changed");
      isPrimary
          ? await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              "primary": {attachmentKey: attachmentValue}
            }, merge: true)
          : await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              "secondary": {attachmentKey: attachmentValue}
            }, merge: true);
      return getUserLoadouts(true, null, null);
    } else if (slots == 5) {
      print("database.dart: too many attachments being added");
      return -1;
    } else {
      print("database.dart: new attachment is being added");
      isPrimary
          ? await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              "primary_slots": slots + 1,
              "primary": {attachmentKey: attachmentValue}
            }, merge: true)
          : await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              "secondary_slots": slots + 1,
              "secondary": {attachmentKey: attachmentValue}
            }, merge: true);
      return getUserLoadouts(true, null, null);
    }
  }

  Future getWeaponList(bool isPrimary, bool isOverkill, String type) async {
    String primary = '';
    isPrimary || isOverkill
        ? primary = "primary_weapon"
        : primary = "secondary_weapon";
    QuerySnapshot weaponDocuments = await dbRef
        .collection("guns")
        .document(primary)
        .collection(type)
        .getDocuments();

    return weaponDocuments.documents;
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
            .document(userID)
            .collection("loadouts")
            .document(position)
            .setData({
            "primary_name": name,
            "primary_slots": 0,
            "primary_type": type,
            "primary": {}
          }, merge: true)
        : await dbRef
            .collection("users")
            .document(userID)
            .collection("loadouts")
            .document(position)
            .setData({
            "secondary_name": name,
            "secondary_slots": 0,
            "secondary_type": type,
            "secondary": {}
          }, merge: true);

    for (var item in keys) {
      print("database.dart: for items in key...");
      print(item);
      item == "image"
          ? await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              primaryText: {
                item: imageURL,
              }
            }, merge: true)
          : await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .setData({
              primaryText: {
                item: "-",
              }
            }, merge: true);
    }

    return getUserLoadouts(true, null, null);
  }

  getEquipment(bool isLethal) {
    String equipment;
    isLethal ? equipment = "lethal" : equipment = "tactical";

    var equipmentDocument =
        dbRef.collection('equipment').document(equipment).snapshots();

    return equipmentDocument;
  }

  updateEquipment(String position, bool isLethal, String newEquipment) async {
    print("database.dart: starting updateEquipment()");

    userID = await getUid();
    isLethal
        ? await dbRef
            .collection("users")
            .document(userID)
            .collection("loadouts")
            .document(position)
            .setData({
            "lethal": newEquipment,
          }, merge: true)
        : await dbRef
            .collection("users")
            .document(userID)
            .collection("loadouts")
            .document(position)
            .setData({
            "tactical": newEquipment,
          }, merge: true);
    return getUserLoadouts(true, null, null);
  }

  getPerks(int tierNumber) {
    print("database.dart: started getPerks()");
    var perkDocument =
        dbRef.collection('tiers').document("tier $tierNumber").snapshots();

    return perkDocument;
  }

  updatePerks(
      String position, int tierNumber, String newPerk, String currPerk) async {
    print("database.dart: starting updatePerks();");
    userID = await getUid();

    // TODO: Two things are happening:
    // updating secondary with new "primary" (w/ overkill) updates the
    // primary spot instead of the secondary

    await dbRef
        .collection("users")
        .document(userID)
        .collection("loadouts")
        .document(position)
        .setData({
      "tier $tierNumber": newPerk,
    }, merge: true);

    // if newPerk == "Overkill" then update entire second weapon
    if (tierNumber == 2) {
      if (newPerk.toLowerCase() == "overkill") {
        if (currPerk.toLowerCase() != "overkill") {
          await dbRef
              .collection("users")
              .document(userID)
              .collection("loadouts")
              .document(position)
              .updateData({
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
              .document(userID)
              .collection("loadouts")
              .document(position)
              .updateData({
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
        .getDocuments();
  }
}
