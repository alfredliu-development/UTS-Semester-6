import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<StatefulWidget> createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final _fromKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Sign In",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Center(
              child: Image.asset(
                "assets/image/my_logo.png",
                height: 120,
              ),
            ),
        
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 20
              ),
        
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Hint yours e-mail",
                      prefixIcon: Icon(Icons.email_outlined),
                      prefixIconColor: WidgetStateColor.resolveWith((states) {
                        return states.contains(WidgetState.focused) ? Colors.lightBlueAccent : Colors.black54;
                      }),
        
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
        
                      labelStyle: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold
                      ),
        
                      floatingLabelStyle: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.w500
                      ),
                    ),
        
                    validator: (value) {
                      return value == null || value.isEmpty ? "Email isn't null" : null;
                    },
                  ),
        
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordVisible,
                    decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Hint your password",
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black54,
                          ),
        
                          onPressed: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                        ),
        
                        prefixIconColor: WidgetStateColor.resolveWith((states) {
                          return states.contains(WidgetState.focused) ? Colors.lightBlueAccent : Colors.black54;
                        }),
        
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
        
                        labelStyle: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold
                        ),
        
                        floatingLabelStyle: TextStyle(color: Colors.lightBlueAccent)
                    ),
        
                    validator: (value) {
                      return value == null || value.isEmpty ? "Password isn't null" : null;
                    },
                  ),
                ],
              ),
            ),
        
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
        
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white
                ),
        
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
        
                onPressed: () {
                  if (_fromKey.currentState!.validate()) {
                    Navigator.pushReplacementNamed(context, "/home");
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Your email and password is empty"
                      ),
                    )
                  );
                },
              ),
            ),
        
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't have account?"),
                SizedBox(width: 20),
                TextButton(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
        
                  onPressed: () => Navigator.pushReplacementNamed(context, "/home"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}