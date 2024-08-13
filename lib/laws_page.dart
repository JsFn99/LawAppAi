import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:io';
import 'pdf_viewer_page.dart';

class LawsPage extends StatefulWidget {
  @override
  _LawsPageState createState() => _LawsPageState();
}

class _LawsPageState extends State<LawsPage> {
  final List<String> pdfFiles = [
    'Data/Code civil.pdf',
    'Data/Code penal.pdf',
    'Data/Code de commerce.pdf',
    'Data/Code de la famille.pdf',
    'Data/Code de la route.pdf',
    'Data/Code des Obligations et des Contrats.pdf',
    'Data/Code du travail.pdf',
    'Data/Code general des impots.pdf',
    'Data/Code de la nationalite.pdf',
    'Data/Code des droits reels.pdf',
    'Data/Code de recouvrement.pdf',
    'Data/Constitution.pdf',
    'Data/Etat civil.pdf',
    'Data/Procédure civile.pdf',
    'Data/Procedure penale.pdf',
    'Data/Organisation judiciaire.pdf',
    'Data/La cour constitutionnelle.pdf',
  ];

  late List<String> filteredPdfFiles;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPdfFiles = pdfFiles;
    searchController.addListener(_filterPdfFiles);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterPdfFiles);
    searchController.dispose();
    super.dispose();
  }

  void _filterPdfFiles() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPdfFiles = pdfFiles
          .where((file) => file.toLowerCase().contains(query))
          .toList();
    });
  }

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
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: filteredPdfFiles.length,
                itemBuilder: (context, index) {
                  String fileName = filteredPdfFiles[index].split('/').last.replaceAll('.pdf', '');
                  return GestureDetector(
                    onTap: () async {
                      File file = await _loadPdf(filteredPdfFiles[index]);
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
          ],
        ),
      ),
    );
  }
}
