import 'package:e_commerce_market/page/home_page.dart';
import 'package:e_commerce_market/page/sign/auth_cubit.dart';
import 'package:e_commerce_market/page/sign/sign_in.dart';
import 'package:e_commerce_market/page/sign/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => AuthCubit()..loadCredentials(),
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/sign-in",
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