import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:convert';

import '../../../src/api.dart';
import '../../../src/preference.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PDFHomePage(),
    );
  }
}

class PDFHomePage extends StatefulWidget {
  @override
  _PDFHomePageState createState() => _PDFHomePageState();
}

class _PDFHomePageState extends State<PDFHomePage> {
  String? pdfPath;
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];

  @override
  void initState() {
    super.initState();
    fetchDataAndGeneratePDF();
  }

  Future<void> fetchDataAndGeneratePDF() async {

     var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.getlapinsus;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri), headers: {
        "Authorization": bearerToken.toString(),
      });
      var content = json.decode(response.body);
      print("getdentil");
      print(response.statusCode);
      print(content.toString());
    // Fetch data from the API
    // final response = await http.get(Uri.parse('http://paket7.kejaksaan.info:3007/api/indexlapinsus'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Extract the required fields from the JSON
      final reports = data['data'] as List;
      if (reports.isNotEmpty) {
        final report = reports[0];
        final jenisLaporan = report['jenis_laporan'];
        final noSurat = report['no_surat'];
        final informasi = report['informasi'];
        final sumberInfo = report['sumber_info'];
        final trenPerkembangan = report['tren_perkembangan'];
        final pendapat = report['pendapat'];
        final saran = report['saran'];

        // Generate PDF
        final pdf = pw.Document();

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Jenis Laporan: $jenisLaporan'),
                  pw.Text('No Surat: $noSurat'),
                  pw.Text('Informasi: $informasi'),
                  pw.Text('Sumber Info: $sumberInfo'),
                  pw.Text('Tren Perkembangan: $trenPerkembangan'),
                  pw.Text('Pendapat: $pendapat'),
                  pw.Text('Saran: $saran'),
                ],
              ),
            ),
          ),
        );

        final Uint8List bytes = await pdf.save();

        final Directory tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/example.pdf');

        await file.writeAsBytes(bytes, flush: true);

        setState(() {
          pdfPath = file.path;
          print("pdfpath");
          
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Demo'),
      ),
      body: pdfPath != null
          ? PDFView(
              filePath: pdfPath!,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

