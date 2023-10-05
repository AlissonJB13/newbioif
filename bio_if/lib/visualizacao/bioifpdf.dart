import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:printing/printing.dart';

import '../customizacao/customappbar.dart';
import '../customizacao/themedscaffold.dart';

class BioIfPDF extends StatefulWidget {
  const BioIfPDF({Key? key}) : super(key: key);

  @override
  State<BioIfPDF> createState() => _BioIfPDFState();
}

class _BioIfPDFState extends State<BioIfPDF> {
  int pdfPage = 0;
  String pdfPath = '';
  String imagem = '';

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    // Busque os dados da coleção Firebase e adicione-os ao PDF
    final QuerySnapshot<Map<String, dynamic>> collection =
        await FirebaseFirestore.instance.collection('Postagem2').get();

    for (final doc in collection.docs) {
      final data = doc.data();
      final nome = data['nome'];
      final nomeUsuario = data['nome usuario'];
      final tipo = data['tipo'];
      final netImage = await networkImage(data['foto']);
      final localizacao = data['localizacao'];
      final dataHora = data['data e hora'];
      final verificado = data['verificado'];
      final like = data['like'];
      final dislike = data['dislike'];

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Nome: $nome'),
                pw.Text('Nome do Usuário: $nomeUsuario'),
                pw.Text('Tipo: $tipo'),
                pw.Image(netImage),
                pw.Text('Localização: $localizacao'),
                pw.Text('Data: $dataHora'),
                pw.Text('Verificado: ${verificado ? "Sim" : "Não"}'),
                pw.Text('Like: $like  |  Dislike: $dislike'),
              ],
            );
          },
        ),
      );
    }

    // Obtenha o diretório de documentos do dispositivo
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/firebase.pdf';

    // Salve o PDF em um arquivo
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Atualize o estado com o caminho do PDF gerado
    setState(() {
      pdfPath = filePath;
    });
  }

  Future<void> downloadPDF() async {
    if (pdfPath.isNotEmpty) {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/firebase.pdf';
      final file = File(pdfPath);
      final newPath = '${directory.path}/bioif_report.pdf';

      await file.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Relatório baixado com sucesso!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você precisa gerar o relatório primeiro.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      tema: Brightness.light,
      appBar: CustomAppBar(title: "Relatório"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (pdfPath.isNotEmpty)
              Expanded(
                child: PDFView(
                  filePath: pdfPath,
                  enableSwipe: true,
                ),
              )
            else
              Text('Clique no botão abaixo para gerar o PDF.'),
            ElevatedButton(
              onPressed: generatePDF,
              child: Text('Gerar Relatório'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 4, 82, 37),
              ),
            ),
            ElevatedButton(
              onPressed: downloadPDF,
              child: Text('Baixar Relatório'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 4, 82, 37),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
