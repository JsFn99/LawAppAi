import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:io';
import 'pdf_viewer_page.dart';

class LawsPage extends StatelessWidget {
  final List<String> pdfFiles = [
    'Data/Code civil.pdf',
    'Data/Code de commerce.pdf',
    'Data/Code de la famille.pdf',
    'Data/Code de la route.pdf',
    'Data/Code des Obligations et des Contrats.pdf',
    'Data/Code du travail.pdf',
    'Data/Code general des impots.pdf',
    'Data/Constitution.pdf',
    'Data/Procédure civile.pdf',
    'Data/Procedure penale.pdf',
  ];

  Future<File> _loadPdf(String filePath) async {
    ByteData data = await rootBundle.load(filePath);
    final buffer = data.buffer;
    Directory tempDir = Directory.systemTemp;
    File tempFile = File('${tempDir.path}/temp_${filePath.split('/').last}');
    await tempFile.writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return tempFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Textes de loi",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: pdfFiles.length,
          itemBuilder: (context, index) {
            String fileName = pdfFiles[index].split('/').last.replaceAll('.pdf', '');
            return GestureDetector(
              onTap: () async {
                File file = await _loadPdf(pdfFiles[index]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerPage(filePath: file.path),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.balance,
                      color: Colors.green,
                    ),
                    SizedBox(width: 16.0),
                    Text(
                      fileName,
                      style: TextStyle(color: Colors.black, fontSize: 19.0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
