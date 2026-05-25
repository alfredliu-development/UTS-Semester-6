import 'package:e_commerce_market/page/sign/save_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCubit extends Cubit<SaveData> {
  AuthCubit() : super(SaveData());

  void saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("saved_email", email);
    await prefs.setString("saved_password", password);

    emit(SaveData(email: email, password: password));
  }

  void loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("save_email") ?? "";
    final password = prefs.getString("save_password") ?? "";

    emit(SaveData(email: email, password:  password));
  }
}