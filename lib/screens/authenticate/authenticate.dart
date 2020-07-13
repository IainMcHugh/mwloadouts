import 'package:flutter/material.dart';
import 'package:mwloadouts/screens/authenticate/register.dart';
import 'package:mwloadouts/screens/home/home.dart';
import 'package:mwloadouts/services/auth.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  String email, password = '';
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String error = '';

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
          'Sign in',
          style: TextStyle(
            color: Color.fromRGBO(107, 202, 250, 1),
          ),
        ),
        backgroundColor: Color.fromRGBO(25, 25, 25, 1),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
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
                    return 'Please type an email';
                  }
                  return null;
                },
                onSaved: (input) => email = input,
                style: TextStyle(
                  color: Color.fromRGBO(107, 202, 250, 1),
                ),
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
                style: TextStyle(
                  color: Color.fromRGBO(107, 202, 250, 1),
                ),
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
              RaisedButton(
                color: Color.fromRGBO(30, 30, 30, 1),
                textColor: Color.fromRGBO(107, 202, 250, 1),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    print("FormKey Was Validated");
                    dynamic result =
                        await _auth.signInWithEmailAndPassword(email, password);
                    print(result);
                    // if (result != null) {
                    //   navigateToHomePage();
                    // }
                  } else {
                    print("FormKey was not validated!");
                  }
                },
                child: Text('Sign in'),
              ),
              SizedBox(height: 10),
              RaisedButton(
                color: Color.fromRGBO(30, 30, 30, 1),
                textColor: Color.fromRGBO(107, 202, 250, 1),
                onPressed: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => Register()));
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
