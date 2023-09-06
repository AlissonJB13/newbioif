import 'package:bio_if/customizacao/themedscaffold.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import 'home.dart';
import 'recuperarSenha.dart';
import 'package:bio_if/controller/usuarioatual.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bio_if/customizacao/apptheme.dart';
import 'cadastro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bio_if/customizacao/customappbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String? _status = "";
  bool passToggle = true;
  final _formfield = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _showExitConfirmation = false;
  bool _showGoogleLoginProgress = false;

  Future<UserCredential?> signInWithGoogle() async {
    setState(() {
      _showGoogleLoginProgress = true;
    });

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    }

    setState(() {
      _showGoogleLoginProgress = false;
    });

    return null;
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
                                  const Login())); // Fecha o AlertDialog
                    },
                    child: const Text("OK"),
                  ),
                ]
              : null,
        );
      },
    );
  }

  void _exibirAlertaSair(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmação"),
          content: Text("Tem certeza que deseja sair?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o AlertDialog
                _showExitConfirmation = false; // Reseta a variável
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o AlertDialog
                _showExitConfirmation = false; // Reseta a variável
                SystemNavigator.pop(); // Sai do aplicativo
              },
              child: Text("Sair"),
            ),
          ],
        );
      },
    );
  }

  Future _Login() async {
    var auth = FirebaseAuth.instance;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    //teste de conexão da internet
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _exibirAlertDialog("Sem conexão com internet", true, false);
      return;
    }

    _exibirAlertDialog("Entrando", false, true);

    try {
      var usuario =
          await auth.signInWithEmailAndPassword(email: email, password: senha);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        _exibirAlertDialog("Usuário não encontrado!", true, false);
      } else if (e.code == "wrong-password") {
        _exibirAlertDialog("Senha invalida!", true, false);
      } else if (e.code == "The email address is badly formatted") {
        _exibirAlertDialog(
            "Endereço de E-mail não possui um formato correto", true, false);
      }
    }
  }

  void _logOut() async {
    // fazer o try catch com mensagens personalizadas do logout
    await FirebaseAuth.instance.signOut();
    /*try {
        
      } on FirebaseAuthException catch (e) {
        
      }*/
  }

  void _telaCadastro() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Cadastro(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showExitConfirmation) {
          _showExitConfirmation = false;
          return true; // Permite a saída
        } else {
          _showExitConfirmation = true;
          _exibirAlertaSair(context);
          return false; // Impede a saída e mostra o alerta
        }
      },
      child: ThemedScaffold(
        tema: Brightness.light,
        appBar: CustomAppBar(title: "Login"),
        body: Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 40,
            right: 40,
          ),
          child: ListView(
            key: _formfield,
            children: <Widget>[
              SizedBox(
                child: Image.asset("imagens/logo_login.png"),
                height: 250,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30)),
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
              Padding(padding: EdgeInsets.only(top: 10)),
              TextFormField(
                keyboardType: TextInputType.text,
                obscureText: passToggle,
                controller: _controllerSenha,
                decoration: InputDecoration(
                    labelText: "Senha",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          passToggle = !passToggle;
                        });
                      },
                      child: Icon(
                          passToggle ? Icons.visibility : Icons.visibility_off),
                    )),
                style: TextStyle(fontSize: 20),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecuperarSenha()),
                      );
                    },
                    child: Text(
                      "Esqueci a senha",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        //color: Colors.black
                      ),
                    )),
              ]),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  _status!,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  height: 70,
                  child: ElevatedButton.icon(
                    label: const Text('Entrar', style: TextStyle(fontSize: 25)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 82, 37),
                    ),
                    icon: const Icon(Icons.arrow_right_alt_sharp),
                    onPressed: _Login,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  icon: Image.asset("imagens/logo_google.png",
                      height: 32, width: 32),
                  label: Text(
                    'Login com o Google ',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 214, 214, 214),
                  ),
                  onPressed: _showGoogleLoginProgress
                      ? null
                      : () async {
                          setState(() {
                            _showGoogleLoginProgress =
                                true; // Inicia o progresso de login com o Google
                          });

                          var connectivityResult =
                              await Connectivity().checkConnectivity();
                          if (connectivityResult == ConnectivityResult.none) {
                            _exibirAlertDialog(
                                "Sem conexão com internet", true, false);
                            return;
                          }

                          _exibirAlertDialog("Realizando login com o Google",
                              false, true); // Exibe o AlertDialog de progresso
                          final UserCredential? userCredential =
                              await signInWithGoogle();

                          setState(() {
                            _showGoogleLoginProgress =
                                false; // Finaliza o progresso de login com o Google
                          });

                          if (userCredential != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()));
                            //O usuário está logado, faça alguma coisa
                          } else {
                            print("Não deu");
                            // O usuário não está logado
                          }
                        },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Não possui conta?",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                      onPressed: _telaCadastro,
                      child: Text(
                        "Clique aqui",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
