import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mwloadouts/screens/home/home.dart';
import 'package:mwloadouts/services/database.dart';

class Search extends StatefulWidget {
  final String currUserKey;

  Search({this.currUserKey});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final DatabaseService databaseService = DatabaseService();
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(String val) {
    print("initiateSearch() started");
    print(val);
    if (val.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue = val.substring(0, 1).toUpperCase() + val.substring(1);

    if (queryResultSet.length == 0 && val.length == 1) {
      databaseService.searchByName(val).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data);
          setState(() {
            tempSearchStore.add(queryResultSet[i]);
          });
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].toLowerCase().contains(val.toLowerCase()) ==
            true) {
          if (element['username'].toLowerCase().indexOf(val.toLowerCase()) ==
              0) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        }
      });
    }
    if (tempSearchStore.length == 0 && val.length > 1) {
      setState(() {});
    }
  }

  navigateToUsersPage(String username, String userKey) {
    print("Testing the Search function");
    print(username);
    print(userKey);
    print(widget.currUserKey);
    if (userKey == widget.currUserKey) {
      Navigator.pop(context);
    } else {
      // go to new page using Username
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(username: username, userkey: userKey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: TextField(
          autofocus: true,
          // textInputAction: TextInputAction.go,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search Users",
              hintStyle: TextStyle(color: Colors.grey)),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
          onChanged: (val) {
            initiateSearch(val);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: tempSearchStore.map((e) {
              return buildResultCard(e);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return ListTile(
      title: Text(data['username']),
      onTap: () {
        navigateToUsersPage(data['username'], data['userKey']);
      },
    );
  }
}
