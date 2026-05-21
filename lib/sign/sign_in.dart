import 'package:e_commerce_market/data/account_sql.dart';
import 'package:flutter/material.dart';

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
        child: Form(
          key: _fromKey,
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
                  horizontal: 20
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
                        if (!value!.contains("@")) return "Format email is wrong";

                        return value.isEmpty ? "Email isn't null" : null;
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
                    if (_fromKey.currentState!.validate()) handleDatabase();

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
      ),
    );
  }

  void handleDatabase() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    bool result = await AccountSQL.instance.login(email, password);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("E-mail is successfully"),
        )
      );

      Navigator.pushReplacementNamed(context, "/name");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("E-mail and password is wrong"),
        )
    );
  }
}