import 'package:flutter/material.dart';

import 'Forms/login_page.dart';
import 'Forms/sign_up_page.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({Key? key}) : super(key: key);

  @override
  State<AuthenticatePage> createState() => _MainPageState();
}

class _MainPageState extends State<AuthenticatePage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: size.width,
                    height: size.height,
                    child: const Image(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/large_UIR.jpg'),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white
                        .withOpacity(0.4), //blue.shade900.withOpacity(0.6),
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(80.0),
                  //Todo: Add the login form here
                  // child: Text('Hello World'),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin
      ? LoginPage(
          onClickSignUp: toggle,
        )
      : SignUpPage(
          onClickSignUp: toggle,
        );

  void toggle() {
    setState(() => isLogin = !isLogin);
  }
}