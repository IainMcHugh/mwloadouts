import 'package:flutter/material.dart';
import 'package:mwloadouts/models/user.dart';
import 'package:mwloadouts/screens/authenticate/authenticate.dart';
import 'package:mwloadouts/screens/home/loadout.dart';
import 'package:mwloadouts/screens/wrapper.dart';
import 'package:mwloadouts/services/auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      catchError: (_, err) => null,
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
