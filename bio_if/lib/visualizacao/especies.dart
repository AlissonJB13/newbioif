import 'dart:io';
import 'package:bio_if/customizacao/customappbar.dart';
import 'package:bio_if/customizacao/themedscaffold.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'home.dart';
import 'package:bio_if/controller/postagem.dart';
import 'package:bio_if/controller/usuarioatual.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:bio_if/customizacao/apptheme.dart';
import 'mapa.dart';

/*cadastro das especies
    -nome conhecido da especies
    -descricao
    -tipo
    -data
    -localização
    -foto
    -likes e deslikes
    -usuario que publicou
  */

class Especies extends StatefulWidget {
  String LatLongStr;
  Especies(this.LatLongStr, {super.key});
  //Especies(this.LatLongStr, {super.key});

  @override
  State<Especies> createState() => _EspeciesState();
}

class _EspeciesState extends State<Especies> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  String? _campoSelecionado = "";
  String _resultado = "";
  XFile? _arquivoImagem;
  String? dataHora = DateTime.now().toString();
  var db = FirebaseFirestore.instance;
  String _urlImagem = "";
  String? _status = "Postagem não realizada";
  int contagem = 0;
  String nomeUsuario = "";
  bool _isUploading = false;

  Future _capturaFoto(bool daCamera) async {
    final ImagePicker picker = ImagePicker();
    XFile? imagem;

    if (daCamera) {
      imagem = await picker.pickImage(source: ImageSource.camera);
    } else {
      imagem = await picker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _arquivoImagem = imagem;
    });
  }

  void _selecao() {
    if (_campoSelecionado == "") {
      setState(() {
        _resultado = "Não Informado";
      });
    } else if (_campoSelecionado == 'P') {
      setState(() {
        _resultado = "Planta";
      });
    } else {
      setState(() {
        _resultado = "Animal";
      });
    }
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");
    var formatador = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);

    return formatador.format(dataConvertida);
  }

  void _exibirAlertDialogDeConfirmacao() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmação"),
          content: Text("Deseja prosseguir com a postagem?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fechar o AlertDialog
                _iniciarUpload(); // Iniciar o processo de upload
              },
              child: Text("Sim"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fechar o AlertDialog
              },
              child: Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  void _exibirStatusAlertDialog(
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
          actions: [
            if (showButton && !showProgress)
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o AlertDialog
                  if (statusMessage == "Postagem realizada com sucesso") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  }
                },
                child: const Text("OK"),
              ),
          ],
        );
      },
    );
  }

  Future _postagem() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _exibirStatusAlertDialog("Sem conexão com internet", true, false);
      return;
    }

    _exibirAlertDialogDeConfirmacao();
  }

  Future _iniciarUpload() async {
    //_exibirAlertDialogDeConfirmacao();

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("fotos")
        .child(DateTime.now().millisecondsSinceEpoch.toString());

    if (_arquivoImagem == null) {
      // Se o arquivo de imagem for nulo, exiba uma mensagem de erro.
      _exibirStatusAlertDialog("Por favor carregue uma imagem", true, false);
      return; // Pare o processo aqui.
    }

    UploadTask task = arquivo.putFile(File(_arquivoImagem!.path));

    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.running) {
        _exibirStatusAlertDialog(
            "Realizando postagem", true, true); // com botão e carregamento
      } else if (taskSnapshot.state == TaskState.success) {
        _recuperarImagem(taskSnapshot);
        _exibirStatusAlertDialog(
            "Postagem realizada com sucesso", true, false); // Com botão

        Future.delayed(const Duration(seconds: 5), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        });
      } else if (taskSnapshot.state == TaskState.error) {
        _exibirStatusAlertDialog(
            "Erro. Tente novamente", true, false); // Com botão
      }
    });
  }

  Future _recuperarImagem(TaskSnapshot taskSnapshot) async {
    String? url = await taskSnapshot.ref.getDownloadURL();

    print("URL: $url");

    setState(() {
      _urlImagem = url;
    });

    _selecao();

    Postagem postagem = Postagem(
        nomeusuario: UsuarioAtual().currentUser?.displayName,
        nome: _controllerNome.text,
        descricao: _controllerDescricao.text,
        tipo: _resultado,
        dataHora: _formatarData(dataHora!),
        foto: _urlImagem,
        localizacao: widget.LatLongStr,
        like: contagem,
        dislike: contagem,
        //likes: [],
        //dislikes: [],
        verificado: false);

    db.collection("Postagem2").add(postagem.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      tema: Brightness.light,
      appBar: CustomAppBar(title: "Cadastro de Espécies"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 20)),
              const Text(
                "Tipo da Espécie:",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              RadioListTile(
                  title: const Text(
                    "Planta",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  value: "P",
                  groupValue: _campoSelecionado,
                  onChanged: (String? resultado) {
                    setState(() {
                      _campoSelecionado = resultado;
                    });
                  }),
              RadioListTile(
                  title: const Text("Animal",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  value: "A",
                  groupValue: _campoSelecionado,
                  onChanged: (String? resultado) {
                    setState(() {
                      _campoSelecionado = resultado;
                    });
                  }),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Nome Popular do Animal ou Planta",
                  hintStyle: TextStyle(fontSize: 20),
                ),
                controller: _controllerNome,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150,
                ),
                child: TextFormField(
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Descrição do Animal ou Planta",
                    hintStyle: TextStyle(fontSize: 20),
                  ),
                  controller: _controllerDescricao,
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              //Row(children: [

              const Text(
                "Imagem:",
                style: TextStyle(fontSize: 30),
              ),

              _arquivoImagem != null
                  ? Image.file(
                      File(_arquivoImagem!.path),
                      fit: BoxFit.cover,
                    )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder),
                    onPressed: () {
                      _capturaFoto(false);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      _capturaFoto(true);
                    },
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 30)),
              Container(
                height: 70,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar', style: TextStyle(fontSize: 25)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 04, 82, 37),
                  ),
                  onPressed: _postagem,
                ),
              ),
              /*Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            _status!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),*/
            ],
          ),
        ),
      ),
    );
  }
}
