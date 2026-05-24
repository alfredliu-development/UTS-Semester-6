import 'package:e_commerce_market/database/account_sql.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() => SignUpState();
}

class SignUpState extends State<StatefulWidget> {
  final _fromKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController = new TextEditingController();

  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Sign Up",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Form(
          key: _fromKey,
          child: Container(
            margin: EdgeInsets.only(
              left: 35,
              right: 35
            ),

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "username",
                      hintText: "Hint your username",
                      prefixIcon: Icon(Icons.person_outline_outlined),
                      prefixIconColor: WidgetStateColor.resolveWith((state) {
                        return state.contains(WidgetState.focused) ? Colors.lightBlueAccent : Colors.black54;
                      }),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),

                      labelStyle: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold
                      ),

                      floatingLabelStyle: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.w500
                      ),
                    ),

                    validator: (value) => value == null || value.isEmpty ? "The username is null" : null,
                  ),

                  SizedBox(height: 27),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "e-mail",
                      hintText: "Hint your e-mail",
                      prefixIcon: Icon(Icons.person_outline_outlined),
                      prefixIconColor: WidgetStateColor.resolveWith((state) {
                        return state.contains(WidgetState.focused) ? Colors.lightBlueAccent : Colors.black54;
                      }),

                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),

                      labelStyle: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold
                      ),

                      floatingLabelStyle: TextStyle(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.w500
                      ),
                    ),

                    validator: (value) {
                      if (!value!.contains("@")) return "Format email is wrong";
                      return value.isEmpty ? "Email isn't null" : null;
                    },
                  ),

                  SizedBox(height: 27),
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

                    validator: (value) => value == null || value.isEmpty ? "Password isn't null" : null,
                  ),

                  SizedBox(height: 27),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isPasswordVisible,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        hintText: "Hint your confirm password",
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

                    validator: (value) => value == null || value.isEmpty ? "Confirm Password isn't null" : null,
                  ),

                  SizedBox(height: 39),
                  ElevatedButton(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),

                    onPressed: () => handleDatabase(),
                  ),

                  SizedBox(height: 20),
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
        ),
      ),
    );
  }

  void handleDatabase() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("The Password and the confirm password isn't same"),
          )
      );

      return;
    }

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
  }
}