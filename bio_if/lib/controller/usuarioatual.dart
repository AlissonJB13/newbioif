import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UsuarioAtual {
  final auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  Future<User?> getUser() async {
    if (currentUser != null) {
      const Text("faça o login");
    } else {
      return currentUser;
    }
  }
}
