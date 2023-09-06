import 'package:cloud_firestore/cloud_firestore.dart';

class Postagem {
  String? nomeusuario;
  String nome;
  String descricao;
  String tipo;
  String dataHora;
  String foto;
  String localizacao;
  int like;
  int dislike;
  bool verificado;
  CollectionReference<Map<String, dynamic>>? subLikes;
  CollectionReference<Map<String, dynamic>>? subDisLikes;

  Postagem(
      {this.nomeusuario,
      required this.nome,
      required this.descricao,
      required this.tipo,
      required this.dataHora,
      required this.foto,
      required this.localizacao,
      required this.like,
      required this.dislike,
      required this.verificado,
      this.subLikes,
      this.subDisLikes});

  Map<String, dynamic> toMap() {
    return {
      "nome usuario": nomeusuario,
      "nome": nome,
      "descricao": descricao,
      "tipo": tipo,
      "data e hora": dataHora,
      "foto": foto,
      "localizacao": localizacao,
      "like": like,
      "dislike": dislike,
      //if (likes != null) "likes": likes,
      //if (dislikes != null) "dislikes": dislikes,
      "verificado": verificado
    };
  }

  Postagem.fromJson(Map<String, dynamic> json)
      : nomeusuario = json["nome usuario"],
        nome = json["nome"],
        descricao = json["descricao"],
        tipo = json["tipo"],
        dataHora = json["data e hora"],
        foto = json["foto"],
        localizacao = json["localizacao"],
        like = json["like"],
        dislike = json["dislike"],
        //likes = json["likes"],
        //dislikes = json["dislikes"],
        verificado = json["verificado"];

  //trazer dados que esta gravado na colecao do firebase
  factory Postagem.fromDocument(DocumentSnapshot doc) {
    final dados = doc.data()! as Map<String, dynamic>;
    return Postagem.fromJson(dados);
  }
}
