// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:mwloadouts/models/user.dart';
// import 'package:mwloadouts/screens/authenticate/authenticate.dart';
// import 'package:mwloadouts/screens/home/loadout.dart';
import 'package:mwloadouts/screens/wrapper.dart';
import 'package:mwloadouts/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// _loading() {
//     // TextEditingController controller = TextEditingController();
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) {
//           return Center(child: CircularProgressIndicator());
//         });
//   }

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // // This widget is the root of your application
  // @override
  // Widget build(BuildContext context) {
  //   return StreamProvider<WZUser>.value(
  //     catchError: (_, err) => null,
  //     value: AuthService().user,
  //     child: MaterialApp(
  //       home: Wrapper(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        // if (snapshot.hasError) {
        //   return -1;
        // }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamProvider<WZUser>.value(
            catchError: (_, err) => null,
            value: AuthService().user,
            updateShouldNotify: (_, __) => true,
            child: MaterialApp(
              home: Wrapper(),
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}

// WARNING::::
// To get this working I had to modify 'picture_stream.dart' changing
// DiagnosticableMixin to Diagnosticable
// can be found here: \src\flutter\.pub-cache\hosted\pub.dartlang.org\flutter_svg-0.17.4\lib\src\picture_stream.dart
