import 'package:flutter/material.dart';
import 'package:mwloadouts/screens/home/home.dart';
import 'package:mwloadouts/services/auth.dart';
import 'package:mwloadouts/services/database.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String username = '';
  String email = '';
  String password = '';
  String repassword = '';
  final AuthService _auth = AuthService();
  final DatabaseService _database = DatabaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(17, 17, 17, 1),
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            color: Color.fromRGBO(107, 202, 250, 1),
          ),
        ),
        backgroundColor: Color.fromRGBO(25, 25, 25, 1),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              autovalidate: true,
              onChanged: () {
                Form.of(primaryFocus.context).save();
              },
              child: Column(
                children: <Widget>[
                  TextFormField(
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Please type a Username';
                      }
                      return null;
                    },
                    onSaved: (input) => username = input,
                    style: TextStyle(
                      color: Color.fromRGBO(107, 202, 250, 1),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(240, 240, 240, 1),
                      ),
                      errorStyle: TextStyle(
                        color: Color.fromRGBO(157, 202, 240, 1),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 240, 1),
                        ),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 255, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Please type an email';
                      }
                      return null;
                    },
                    onSaved: (input) => email = input,
                    style: TextStyle(color: Color.fromRGBO(107, 202, 250, 1)),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(240, 240, 240, 1),
                      ),
                      errorStyle: TextStyle(
                        color: Color.fromRGBO(157, 202, 240, 1),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 240, 1),
                        ),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 255, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Please type a password';
                      }
                      return null;
                    },
                    onSaved: (input) => password = input,
                    style: TextStyle(color: Color.fromRGBO(107, 202, 250, 1)),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(240, 240, 240, 1),
                      ),
                      errorStyle: TextStyle(
                        color: Color.fromRGBO(157, 202, 240, 1),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 240, 1),
                        ),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 255, 1),
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Please Re-enter your password';
                      }
                      return null;
                    },
                    onSaved: (input) => repassword = input,
                    style: TextStyle(color: Color.fromRGBO(107, 202, 250, 1)),
                    decoration: InputDecoration(
                      labelText: 'Re-enter password',
                      labelStyle: TextStyle(
                        color: Color.fromRGBO(240, 240, 240, 1),
                      ),
                      errorStyle: TextStyle(
                        color: Color.fromRGBO(157, 202, 240, 1),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 240, 1),
                        ),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(157, 202, 255, 1),
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  RaisedButton(
                    color: Color.fromRGBO(30, 30, 30, 1),
                    textColor: Color.fromRGBO(107, 202, 250, 1),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        dynamic result = await _auth
                            .registerWithEmailAndPassword(email, password);
                        if (result == null) {
                          print("Error with Registering");
                        } else {
                          // createNewUser in database
                          print("await _database.createNewUser");
                          var result =
                              await _database.createNewUser(username, email);
                          // if (result != null) {
                          //   navigateToHomePage();
                          // }
                          Navigator.pop(context);
                        }
                      } else {
                        print("Error with Form");
                      }
                    },
                    child: Text('Register'),
                  ),
                  SizedBox(height: 10),
                  RaisedButton(
                    color: Color.fromRGBO(30, 30, 30, 1),
                    textColor: Color.fromRGBO(107, 202, 250, 1),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Already have an Account?'),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
