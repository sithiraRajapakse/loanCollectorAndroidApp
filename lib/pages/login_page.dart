import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loan_collection_android/services/login_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var isLoading = false;
  String loadingMessage = 'Welcome!\nPlease wait...';

  late String? _email, _password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
      ),
    );
  }

  void _handleSubmitted() async {
    final FormState? form = _formKey.currentState;
    if (!form!.validate()) {
      showInSnackBar('Please enter your credentials');
      setState(() {
        isLoading = false;
        loadingMessage = 'Please wait..';
      });
    } else {
      setState(() {
        isLoading = true;
        loadingMessage = 'Trying to log in..\nPlease wait..';
      });

      form.save();

      bool loggedIn = await logIn(_email!, _password!);

      if (loggedIn) {
        // show the home
        setState(() {
          isLoading = false;
        });
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
      } else {
        // not moving.
        showInSnackBar(
            'Failed to log in. Please check your credentials and try again.');
        setState(() {
          isLoading = false;
          loadingMessage = 'Please wait..';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? buildLoadingScreen() : buildLoginScreen();
  }

  Scaffold buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 32.0,
            ),
            Image.asset(
              'images/logo_256_transparent.png',
              width: 128.0,
            ),
            const Text(
              'Loan Collector',
              style: TextStyle(fontSize: 24.0, color: Colors.black54),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Text(
              loadingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24.0),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Scaffold buildLoginScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 64.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 32.0,
                  ),
                  Image.asset(
                    'images/logo_256_transparent.png',
                    width: 128.0,
                  ),
                  const Text(
                    'Loan Collector',
                    style: TextStyle(fontSize: 32.0, color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    key: const Key("_mobile"),
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String? value) {
                      _email = value;
                    },
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Email is required';
                      }
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    onSaved: (String? value) {
                      _password = value;
                    },
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Password is required';
                      }
                    },
                  ),
                  const SizedBox(height: 10.0),
                  ButtonBar(
                    children: <Widget>[
                      ElevatedButton.icon(
                          onPressed: _handleSubmitted,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Sign in')),
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  const Text(
                    'Developed by',
                    style: TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                  const SizedBox(height: 10.0),
                  Image.asset(
                    'images/Mb_logo.png',
                    height: 50.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
