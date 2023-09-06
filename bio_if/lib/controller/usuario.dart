import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? id;
  String? nome;
  String? email;

  Usuario({this.id, this.nome, this.email});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      if (nome != null) "nome": nome,
      if (email != null) "email": email
    };
  }

  Usuario.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        nome = json["nome"],
        email = json["email"];

  //trazer dados que esta gravado na colecao do firebase
  factory Usuario.fromDocument(DocumentSnapshot doc) {
    final dados = doc.data()! as Map<String, dynamic>;
    return Usuario.fromJson(dados);
  }

  @override
  String toString() {
    return "email: $email\n ";
  }
}
