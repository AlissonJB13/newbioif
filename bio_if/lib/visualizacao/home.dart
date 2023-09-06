import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sobre.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ajuda.dart';
import 'package:bio_if/customizacao/apptheme.dart';
import 'mapa.dart';

//listagem das especies
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  var db = FirebaseFirestore.instance;
  String latlong = "";
  List<String> itensMenu = ["Sobre", "Ajuda", "Sair"];
  int likeCount = 0;
  late final FirebaseFirestore _db;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  Size? imageSize;
  String tipo = '';
  bool _showExitConfirmation = false;
  var connectivityResult = Connectivity().checkConnectivity();
  Map<String, bool> likedItems = {};
  Map<String, bool> dislikedItems = {};
  bool isLikeButtonEnabled = true;
  bool isDislikeButtonEnable = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    AppTheme.setTheme();
    //_showExitConfirmation = false;

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    AppTheme.setTheme();
  }

  Stream<QuerySnapshot> getDataStream() {
    Query<Map<String, dynamic>> dadosCollection = FirebaseFirestore.instance
        .collection('Postagem2')
        .orderBy('data e hora', descending: false);

    return dadosCollection.snapshots();
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

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Sobre":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Sobre()));
        break;
      case "Ajuda":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Ajuda()));
        break;
      case "Sair":
        SystemNavigator.pop();
        break;
      default:
    }
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
      child: ValueListenableBuilder(
        valueListenable: AppTheme.tema,
        builder: (BuildContext context, Brightness tema, _) {
          return Builder(
            builder: (context) {
              return Theme(
                data: ThemeData(
                  brightness: tema,
                  appBarTheme: AppBarTheme(
                    color: tema == Brightness.light
                        ? const Color.fromARGB(
                            255, 04, 82, 37) // Cor do AppBar no tema claro
                        : const Color(
                            0xFF28372F), // Cor do AppBar no tema escuro
                  ),
                  // Aqui você pode personalizar mais o tema
                  // conforme suas necessidades
                ),
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    centerTitle: true,
                    toolbarHeight: 80,
                    title: Text("BioIF"),
                    automaticallyImplyLeading: false,
                    actions: [
                      PopupMenuButton(
                        itemBuilder: (context) {
                          return itensMenu.map((String item) {
                            return PopupMenuItem(
                                value: item, child: Text(item));
                          }).toList();
                        },
                        onSelected: _escolhaMenuItem,
                      )
                    ],
                  ),
                  body: SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: getDataStream(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                final snap = snapshot.data!.docs;
                                return ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: snap.length,
                                  itemBuilder: (context, index) {
                                    final postId = snap[index].id;
                                    final isLiked =
                                        likedItems.containsKey(postId)
                                            ? likedItems[postId]!
                                            : false;
                                    final isDisliked =
                                        dislikedItems.containsKey(postId)
                                            ? dislikedItems[postId]!
                                            : false;
                                    return Column(children: [
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        child: Text(
                                          snap[index]['nome'].toUpperCase(),
                                          style: const TextStyle(
                                            //color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          snap[index]['verificado']
                                              ? 'Verificado'
                                              : 'Não verificado',
                                          style: TextStyle(
                                            color: snap[index]['verificado']
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            Icon(
                                              snap[index]['tipo'] == 'Planta'
                                                  ? Icons.local_florist
                                                  : Icons.pets,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "${snap[index]['nome usuario']}"
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            //color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        width:
                                            400, // Defina a largura da imagem desejada
                                        height:
                                            300, // Defina a altura da imagem desejada
                                        child: /*connectivityResult ==
                                                ConnectivityResult.none
                                            ? const Text("Erro de conexão...")
                                            : */
                                            Image.network(
                                          snap[index]['foto'],
                                          width: 350, // Largura da imagem
                                          height: 300, // Altura da imagem
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child; // Exibe a imagem quando estiver carregada
                                            } else {
                                              // Mostra o CircularProgressIndicator enquanto a imagem estiver sendo carregada
                                              return CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                                color: const Color.fromARGB(
                                                    255, 04, 82, 37),
                                                // strokeCap: StrokeCap.round,
                                                strokeWidth: 3.0,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                          margin: const EdgeInsets.all(5),
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            "${snap[index]['data e hora']}",
                                          )),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "${snap[index]['descricao']}",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "${snap[index]['localizacao']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            //fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        alignment: Alignment.centerRight,
                                        child: Row(children: [
                                          IconButton(
                                              onPressed: isLikeButtonEnabled
                                                  ? () async {
                                                      setState(() {
                                                        isLikeButtonEnabled =
                                                            false; // Desabilita o botão
                                                      });

                                                      final userId =
                                                          FirebaseAuth.instance
                                                              .currentUser?.uid;
                                                      int numLikes =
                                                          snap[index]['like'];
                                                      String idPublicacao =
                                                          snap[index].id;

                                                      // Verifique se o usuário está logado antes de permitir que ele coloque ou remova um like
                                                      if (userId != null) {
                                                        // Verifique se o usuário já deu like na publicação
                                                        bool alreadyLiked = await db
                                                            .collection(
                                                                'Postagem2')
                                                            .doc(idPublicacao)
                                                            .collection(
                                                                'SubLikes')
                                                            .doc(userId)
                                                            .get()
                                                            .then((snapshot) =>
                                                                snapshot
                                                                    .exists);

                                                        if (!alreadyLiked) {
                                                          // Adicione um novo documento na subcoleção "comentarios" com o ID do usuário
                                                          await db
                                                              .collection(
                                                                  'Postagem2')
                                                              .doc(idPublicacao)
                                                              .collection(
                                                                  'SubLikes')
                                                              .doc(userId)
                                                              .set({
                                                            'userId': userId,
                                                          });

                                                          setState(() {
                                                            likedItems[postId] =
                                                                true; // Atualiza o estado do item
                                                          });
                                                          // Atualize a publicação com o novo valor de likes

                                                          await db
                                                              .collection(
                                                                  'Postagem2')
                                                              .doc(idPublicacao)
                                                              .update({
                                                            'like':
                                                                numLikes + 1,
                                                          });

                                                          setState(() {
                                                            isLikeButtonEnabled =
                                                                true; // Habilita o botão novamente
                                                          });
                                                        } else {
                                                          setState(() {
                                                            isLikeButtonEnabled =
                                                                false; // Habilita o botão novamente
                                                          }); // Exclua o documento do usuário na subcoleção "comentarios"
                                                          await db
                                                              .collection(
                                                                  'Postagem2')
                                                              .doc(idPublicacao)
                                                              .collection(
                                                                  'SubLikes')
                                                              .doc(userId)
                                                              .delete();

                                                          // Atualize a publicação com o novo valor de likes
                                                          await db
                                                              .collection(
                                                                  'Postagem2')
                                                              .doc(idPublicacao)
                                                              .update({
                                                            'like':
                                                                numLikes - 1,
                                                          });

                                                          setState(() {
                                                            likedItems[postId] =
                                                                false;
                                                            isLikeButtonEnabled =
                                                                true; // Habilita o botão novamente
                                                          });
                                                        }
                                                      } else {
                                                        // O usuário não está logado
                                                        print('Erro');
                                                        setState(() {
                                                          isLikeButtonEnabled =
                                                              true; // Habilita o botão novamente
                                                        });
                                                      }
                                                    }
                                                  : null,
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons
                                                        .favorite_border_outlined,
                                                color: isLiked
                                                    ? Colors.red[800]
                                                    : null,
                                              )),
                                          Text('${snap[index]['like']}'),
                                          IconButton(
                                            onPressed: isDislikeButtonEnable
                                                ? () async {
                                                    setState(() {
                                                      isDislikeButtonEnable =
                                                          false; // Desabilita o botão
                                                    });

                                                    final userId = FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.uid;
                                                    int numLikes =
                                                        snap[index]['dislike'];
                                                    String idPublicacao =
                                                        snap[index].id;

                                                    // Verifique se o usuário está logado antes de permitir que ele coloque ou remova um like
                                                    if (userId != null) {
                                                      // Verifique se o usuário já deu like na publicação
                                                      bool alreadyLiked =
                                                          await db
                                                              .collection(
                                                                  'Postagem2')
                                                              .doc(idPublicacao)
                                                              .collection(
                                                                  'SubDisLikes')
                                                              .doc(userId)
                                                              .get()
                                                              .then((snapshot) =>
                                                                  snapshot
                                                                      .exists);

                                                      if (!alreadyLiked) {
                                                        // Adicione um novo documento na subcoleção "comentarios" com o ID do usuário
                                                        await db
                                                            .collection(
                                                                'Postagem2')
                                                            .doc(idPublicacao)
                                                            .collection(
                                                                'SubDisLikes')
                                                            .doc(userId)
                                                            .set({
                                                          'userId': userId,
                                                        });

                                                        setState(() {
                                                          dislikedItems[
                                                                  postId] =
                                                              true; // Atualiza o estado do item
                                                        });
                                                        // Atualize a publicação com o novo valor de likes
                                                        await db
                                                            .collection(
                                                                'Postagem2')
                                                            .doc(idPublicacao)
                                                            .update({
                                                          'dislike':
                                                              numLikes + 1,
                                                        });

                                                        setState(() {
                                                          isDislikeButtonEnable =
                                                              true; // Habilita o botão novamente
                                                        });
                                                      } else {
                                                        setState(() {
                                                          isDislikeButtonEnable =
                                                              false; // Habilita o botão novamente
                                                        });

                                                        // Exclua o documento do usuário na subcoleção "comentarios"
                                                        await db
                                                            .collection(
                                                                'Postagem2')
                                                            .doc(idPublicacao)
                                                            .collection(
                                                                'SubDisLikes')
                                                            .doc(userId)
                                                            .delete();

                                                        // Atualize a publicação com o novo valor de likes
                                                        await db
                                                            .collection(
                                                                'Postagem2')
                                                            .doc(idPublicacao)
                                                            .update({
                                                          'dislike':
                                                              numLikes - 1,
                                                        });
                                                        setState(() {
                                                          dislikedItems[
                                                              postId] = false;
                                                          // Atualiza o estado do item

                                                          isDislikeButtonEnable =
                                                              true; // Habilita o botão novamente
                                                        });
                                                      }
                                                    } else {
                                                      // O usuário não está logado
                                                      print('Erro');
                                                    }
                                                  }
                                                : null,
                                            icon: Icon(
                                              isDisliked
                                                  ? Icons.heart_broken_sharp
                                                  : Icons.heart_broken_outlined,
                                              color: isDisliked
                                                  ? Colors.orange[800]
                                                  : null,
                                            ),
                                          ),
                                          Text('${snap[index]['dislike']}'),
                                        ]),
                                      ),
                                      Divider(
                                        color: Colors.black,
                                        indent: 20,
                                        endIndent: 20,
                                      )
                                    ]);
                                  },
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ],
                    ),
                  )),
                  floatingActionButton: FloatingActionButton.extended(
                    label: const Text("Nova Publicação"),
                    extendedTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    icon: Icon(Icons.yard),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Mapa()));
                    },
                    backgroundColor: const Color.fromARGB(255, 04, 82, 37),
                    foregroundColor: Colors.white,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
