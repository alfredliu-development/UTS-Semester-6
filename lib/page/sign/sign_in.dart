import 'package:e_commerce_market/database/account_sql.dart';
import 'package:e_commerce_market/page/sign/auth_cubit.dart';
import 'package:e_commerce_market/page/sign/save_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<StatefulWidget> createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, SaveData>(
      listener: (context, state) {
        if (state.email.isEmpty) return;

        _emailController.text = state.email;
        _passwordController.text = state.password;
      },

      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "Sign In",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 35
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

                  SizedBox(height: 39),
                  ElevatedButton(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    onPressed: () {
                      if (_formKey.currentState!.validate()) handleDatabase();
                    },
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Didn't you have an account?"),
                      SizedBox(width: 20),
                      TextButton(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),

                        onPressed: () => Navigator.pushReplacementNamed(context, "/sign-up"),
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

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthCubit>().state;
    _emailController.text = authState.email;
    _passwordController.text = authState.password;
  }

  void handleDatabase() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text;
    String password = _passwordController.text;

    bool result = await AccountSQL.instance.login(email, password);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully"),
          )
      );

      Navigator.pushReplacementNamed(context, "/home");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("The email and password is wrong"),
      )
    );
  }
}