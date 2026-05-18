import 'package:e_commerce_market/page/home_page.dart';
import 'package:e_commerce_market/sign/sign_in.dart';
import 'package:e_commerce_market/sign/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isSign = prefs.getBool("isSignIn") ?? false;

  runApp(MyApp(isSign: isSign));
}

class MyApp extends StatelessWidget {
  final bool isSign;
  const MyApp({super.key, required this.isSign});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isSign ? "/home" : "/sign-in",
      onGenerateRoute: (settings) {
        Widget widgetName = SignIn();

        switch (settings.name) {
          case "/sign-up":
            widgetName = SignUp();
            break;

          case "/sign-in":
            widgetName = SignIn();
            break;

          case "/home":
            widgetName = HomePage();
            break;
        }

        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widgetName,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }
        );
      },
    );
  }
}