import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mwloadouts/screens/authenticate/authenticate.dart';
import 'package:mwloadouts/screens/home/loadout.dart';
import 'package:mwloadouts/screens/home/search.dart';
import 'package:mwloadouts/services/admob.dart';
import 'package:mwloadouts/services/auth.dart';
import 'package:mwloadouts/services/database.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final String username;
  final String userkey;

  Home({this.username, this.userkey});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _database = DatabaseService();
  final AuthService _auth = AuthService();
  final AdMobService _admob = AdMobService();
  BannerAd myBanner;
  static bool isUser = true;
  static var user;
  static String userKey1;

  resetUserKey() async {
        userKey1 = await _database.getUid();
      }

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      print("Home.dart: Initialising State");
      print(widget.username);
      // This is the user
      isUser = false;
      user = widget.username;
      userKey1 = widget.userkey;
    } else {
      print("Home.dart: user is null");
      isUser = true;
      user = null;
      resetUserKey();
    }

    
    // UNCOMMENT THIS ON RELEASE!!!!!!!
    FirebaseAdMob.instance.initialize(
      appId: _admob.getAdMobAppId(),
      // appId: FirebaseAdMob.testAppId,
    );
    
    myBanner = buildBannerAd()..load();
  }
  // UNCOMMENT ALL OF THIS TOO!!!!!
  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  Icon searchIcon = Icon(
    Icons.search,
    color: Color.fromRGBO(240, 240, 240, 1),
  );

  navigateToLoadoutPage(
      DocumentSnapshot loadout, bool isUser, String username, String userKey) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Loadout(
                  loadout: loadout,
                  isUser: isUser,
                  username: username,
                  userKey: userKey,
                )));
  }

  navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => Search(currUserKey: widget.userkey),
        builder: (context) => Search(currUserKey: userKey1),
      ),
    );
  }

  refreshUsersPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(
          username: null,
          userkey: null,
        ),
      ),
    );
  }

  navigateToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Authenticate(),
      ),
    );
  }

  BannerAd buildBannerAd() {
    return BannerAd(
        // adUnitId: BannerAd.testAdUnitId,
        // adUnitId: _admob.getAdMobAppId(),
        adUnitId: _admob.getBannerAdId(),
        size: AdSize.banner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            myBanner..show();
          }
        });
  }

  signUserOut() async {
    dynamic result = await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(17, 17, 17, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(25, 25, 25, 1),
        leading: new Container(),
        titleSpacing: -35.0,
        title: isUser
            ? Text(
                "My Loadouts",
                style: TextStyle(
                  color: Color.fromRGBO(240, 240, 240, 1),
                ),
              )
            : Text(
                "$user's Loadouts",
                style: TextStyle(
                  color: Color.fromRGBO(107, 202, 250, 1),
                ),
              ),
        actions: <Widget>[
          isUser
              ? IconButton(
                  icon: searchIcon,
                  onPressed: () {
                    navigateToSearchPage();
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.home,
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                  onPressed: () {
                    // refresh page as Users page
                    // refreshUsersPage();
                    setState(() {
                      isUser = true;
                      resetUserKey();
                    });
                  },
                ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              new PopupMenuItem(child: Text("Sign Out"), value: "signout")
            ],
            onSelected: (val) async => {
              print(val),
              if (val == "signout")
                {
                  await signUserOut(),
                  // await _auth.signOut(),
                }
            },
          ),
        ],
      ),
      body: Container(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              FutureBuilder(
                future: _database.getUserLoadouts(isUser, user, widget.userkey),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      child: Center(
                        child: Text(
                          "Loading...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                    print(snapshot.data.length);
                    print(snapshot.data[0]);
                    return ListView.builder(
                        physics: new NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot loadout = snapshot.data[index];
                          return Card(
                            color: Color.fromRGBO(40, 40, 40, 1),
                            shadowColor: Color.fromRGBO(107, 202, 250, 1),
                            child: ListTile(
                              title: Text(
                                loadout.data['name'],
                                style: TextStyle(
                                  color: Color.fromRGBO(107, 202, 250, 1),
                                ),
                              ),
                              // onTap: () => navigateToLoadoutPage(loadout),
                              onTap: () => navigateToLoadoutPage(
                                  loadout, isUser, user, widget.userkey),
                            ),
                          );
                        });
                  }
                },
              ),
              // AdMob Here
              SizedBox(height: AdSize.banner.height + 5.0,),
            ],
          ),
        ),
      )),
    );
    // );
  }
}
