import 'package:bio_if/customizacao/customappbar.dart';
import 'package:bio_if/customizacao/themedscaffold.dart';
import 'package:flutter/material.dart';

import '../customizacao/apptheme.dart';

class Ajuda extends StatefulWidget {
  const Ajuda({super.key});

  @override
  State<Ajuda> createState() => _AjudaState();
}

class _AjudaState extends State<Ajuda> {
  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      tema: Brightness.light,
      appBar: CustomAppBar(title: "Ajuda"),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Dúvidas?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                "Entre em contato com os desenvolvedores:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "Alisson: alissonjb13@gmail.com\n\n"
                "Josmar: josmarbatisteladi@gmail.com",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
