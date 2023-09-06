import 'package:bio_if/customizacao/customappbar.dart';
import 'package:bio_if/customizacao/themedscaffold.dart';
import 'package:flutter/material.dart';
//import 'package:bio_if/customizacao/apptheme.dart';

class Sobre extends StatefulWidget {
  const Sobre({super.key});

  @override
  State<Sobre> createState() => _SobreState();
}

class _SobreState extends State<Sobre> {
  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      tema: Brightness.light,
      appBar: CustomAppBar(title: "Sobre"),
      body: const SingleChildScrollView(
        child:
            // ignore: prefer_const_literals_to_create_immutables
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              "Bem vindo ao Bio IF!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Com nosso aplicativo você é capaz de registar animais e plantas que encontrar através de fotos e demais "
              "informações, como nome e um texto descritivo.",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Você também poderá registrar a localização em que a imagem foi capturada utilizando o GPS do seu dispositivo móvel, "
              "que ao clicar em NOVA PUBLICAÇÃO irá direciona-lo para o mapa, onde poderá fixar a localização desejada.",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
                "Para acessar o aplicativo, visualizar as publicações e criar uma nova publicação será necessário realizar seu login, caso não possua conta, clique no botão CADASTRE-SE.",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.justify),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "As publicações possuem a opção de LIKE e DISLIKE, disponíveis abaixo da foto.",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.justify,
            ),
          ),
        ]),
      ),
    );
  }
}
