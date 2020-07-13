import 'package:flutter/material.dart';
import 'package:mwloadouts/models/user.dart';
import 'package:mwloadouts/screens/authenticate/authenticate.dart';
import 'package:mwloadouts/screens/home/home.dart';
import 'package:provider/provider.dart';

// class Wrapper extends StatefulWidget {
//   @override
//   _WrapperState createState() => _WrapperState();
// }

// class _WrapperState extends State<Wrapper> {
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User>(context);
    
//     print("Wrapper: below is the user:");
//     print(user);
//     // return either Home or Authenticate Widget
//     if (user == null) {
//       print("User is null");
//       return Authenticate();
//     } else {
//       print("User is not null");
//       return Home();
//     }
//     // return user != null ? Home() : Authenticate();
//   }
// }

class Wrapper extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    
    print("Wrapper: below is the user:");
    print(user);
    // return either Home or Authenticate Widget
    if (user == null) {
      print("User is null");
      return Authenticate();
    } else {
      print("User is not null");
      return Home();
    }
  }
}
