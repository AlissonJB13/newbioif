import 'package:bio_if/customizacao/customappbar.dart';
import 'package:bio_if/customizacao/themedscaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:bio_if/customizacao/apptheme.dart';

class RecuperarSenha extends StatefulWidget {
  const RecuperarSenha({super.key});

  @override
  State<RecuperarSenha> createState() => _RecuperarSenhaState();
}

class _RecuperarSenhaState extends State<RecuperarSenha> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  bool passToggle = true;

  Future<void> recuperarSenha(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('E-mail enviado'),
            content: Text(
                'Um e-mail de recuperação de senha foi enviado para $email.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text(
                'Ocorreu um erro ao enviar o e-mail de recuperação de senha.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      tema: Brightness.light,
      appBar: CustomAppBar(title: "Recuperar Senha"),
      body: Container(
        padding: EdgeInsets.only(
          top: 40,
          left: 40,
          right: 40,
        ),
        child: ListView(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 30, top: 50),
            child: Text(
              "Recuperar Senha",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60)),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "E-mail",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            controller: _controllerEmail,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 50)),
          Padding(
            padding: EdgeInsets.only(top: 50),
          ),
          InkWell(
            onTap: () {
              recuperarSenha(_controllerEmail.text);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 04, 82, 37),
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Text(
                  "Atualizar",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
