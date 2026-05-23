import 'package:e_commerce_market/data/account_sql.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final _fromKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Sign Up",
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
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Username",
                        hintText: "Hint yours username",
                        prefixIcon: Icon(Icons.person_outline_outlined),
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
                        return value == null || value.isEmpty ? "username isn't null" : null;
                      },
                    ),
        
                    SizedBox(height: 20),
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
                      controller: _confirmPasswordController,
                      obscureText: _isPasswordVisible,
                      decoration: InputDecoration(
                          labelText: "Confirm Password",
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
                        return value == null || value.isEmpty ? "Confirm Password isn't null" : null;
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
                    "Sign Up",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                  ),
        
                  onPressed: () {
                    if (_fromKey.currentState!.validate()) handleDatabase();
                  },
                ),
              ),
        
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Did you have account?"),
                  SizedBox(width: 20),
                  TextButton(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
        
                    onPressed: () => Navigator.pushReplacementNamed(context, "/sign-in"),
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
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    int result = await AccountSQL.instance.register(username, email, password);

    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully"),
          )
      );

      Navigator.pushReplacementNamed(context, "/name");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("username, E-mail and password is wrong"),
        )
    );
  }
}