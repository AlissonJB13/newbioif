import 'dart:async';

import 'package:bio_if/customizacao/customappbar.dart';
import 'package:bio_if/customizacao/themedscaffold.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'login.dart';
import 'package:bio_if/controller/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//import 'package:bio_if/customizacao/apptheme.dart';

//cadastro dos usuarios
class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerConfirmaSenha = TextEditingController();
  var db = FirebaseFirestore.instance;
  String? _status = "";
  bool senha1 = true;
  bool senha2 = true;
  bool _isLoading = false;
  bool _isButtonEnabled = false; // Inicialmente, o botão está desabilitado

  void _checkButtonState() {
    // Verifica se os campos de texto estão vazios
    final nomeIsEmpty = _controllerNome.text.isEmpty;
    final emailIsEmpty = _controllerEmail.text.isEmpty;
    final senhaIsEmpty = _controllerSenha.text.isEmpty;
    final confirmasenhaIsEmpty = _controllerConfirmaSenha.text.isEmpty;

    // Atualiza o estado do botão com base na condição
    setState(() {
      _isButtonEnabled = !(nomeIsEmpty ||
          emailIsEmpty ||
          senhaIsEmpty ||
          confirmasenhaIsEmpty);
    });
  }

  @override
  void initState() {
    _controllerNome.addListener(_checkButtonState);
    _controllerSenha.addListener(_checkButtonState);
    _controllerEmail.addListener(_checkButtonState);
    _controllerConfirmaSenha.addListener(_checkButtonState);

    super.initState();
  }

  @override
  void dispose() {
    // Remove os ouvintes ao encerrar o widget
    _controllerNome.removeListener(_checkButtonState);
    _controllerEmail.removeListener(_checkButtonState);
    _controllerSenha.removeListener(_checkButtonState);
    _controllerConfirmaSenha.removeListener(_checkButtonState);
    _controllerNome.dispose();
    _controllerEmail.dispose();
    _controllerSenha.dispose();
    _controllerConfirmaSenha.dispose();
  }

  void _exibirAlertDialog(
      String statusMessage, bool showButton, bool showProgress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress)
                CircularProgressIndicator(
                    color: Color.fromARGB(255, 4, 82,
                        37)), // Mostra o CircularProgressIndicator se showProgress for true
              SizedBox(height: 16),
              Text(statusMessage),
            ],
          ),
          actions: showButton && !showProgress
              ? [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const Cadastro())); // Fecha o AlertDialog
                      if (statusMessage == "Usuário criado com sucesso!") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      }
                    },
                    child: const Text("OK"),
                  ),
                ]
              : null,
        );
      },
    );
  }

  Future _cadastrarUsuario() async {
    var auth = FirebaseAuth.instance;
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    String confirmasenha = _controllerConfirmaSenha.text;

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _exibirAlertDialog("Sem conexão com internet", true, false);
      return;
    }

    if (senha == confirmasenha) {
      _exibirAlertDialog("Realizando cadastro...", false, true);

      try {
        var usuario = await auth.createUserWithEmailAndPassword(
            email: email, password: senha);
        print(
            "usuario criado com sucesso: ID: ${usuario.user!.uid} - Email ${usuario.user!.email}");
        setState(() {
          _isLoading = true;
          //_status = "Usuário criado com sucesso!!";
        });

        Usuario user = Usuario(id: usuario.user!.uid, nome: nome, email: email);
        db.collection("Usuario").doc(usuario.user!.uid).set(user.toMap());

        _exibirAlertDialog("Usuário criado com sucesso!", true, false);
      } on FirebaseAuthException catch (e) {
        if (e.code == "email-already-in-use") {
          _exibirAlertDialog("Email já está em uso!", true, false);
        } else if (e.code == "weak-password") {
          _exibirAlertDialog(
              "Senha fraca! Sua senha precisa ter pelo menos 6 caracteres.",
              true,
              false);
        } else if (e.code == "invalid-email") {
          _exibirAlertDialog("Email inválido", true, false);
        }
      }
    } else {
      _exibirAlertDialog("Erro, senhas não conferem", true, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      tema: Brightness.light,
      appBar: CustomAppBar(title: "Cadastro"),
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
              "Cadastre-se",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30)),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Nome completo",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle_sharp),
            ),
            controller: _controllerNome,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
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
          Padding(padding: EdgeInsets.only(top: 20)),
          TextFormField(
            keyboardType: TextInputType.text,
            obscureText: senha1,
            controller: _controllerSenha,
            decoration: InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      senha1 = !senha1;
                    });
                  },
                  child: Icon(senha1 ? Icons.visibility : Icons.visibility_off),
                )),
            style: TextStyle(fontSize: 20),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          TextFormField(
            keyboardType: TextInputType.text,
            obscureText: senha2,
            controller: _controllerConfirmaSenha,
            decoration: InputDecoration(
                labelText: "Confirmar Senha",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      senha2 = !senha2;
                    });
                  },
                  child: Icon(senha2 ? Icons.visibility : Icons.visibility_off),
                )),
            style: TextStyle(fontSize: 20),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("* Todos os campos são obrigatório",
                style: TextStyle(color: Colors.red)),
          ),
          const Padding(padding: EdgeInsets.only(top: 30)),
          Container(
            height: 70,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Cadastrar', style: TextStyle(fontSize: 25)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 04, 82, 37),
              ),
              onPressed: _isButtonEnabled ? _cadastrarUsuario : null,
            ),
          )
        ]),
      ),
    );
  }
}
