import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class PDFHomePage22 extends StatefulWidget {
  @override
  _PDFHomePage22State createState() => _PDFHomePage22State();
}

class _PDFHomePage22State extends State<PDFHomePage22> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    fetchDataAndGeneratePDF();
  }

  Future<void> fetchDataAndGeneratePDF() async {
    // Fetch data from the API
    final response = await http
        .get(Uri.parse('http://paket7.kejaksaan.info:3007/api/indexlapinsus'));

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

        final date = DateFormat('d MMM yyyy').format(DateTime.now());

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('RAHASIA',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 16),
                  pw.Text('Copy Ke : ....... Dari : ....... Copies',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    jenisLaporan == "lapinhar"
                        ? 'LAPORAN INFORMASI HARIAN'
                        : 'LAPORAN INFORMASI KHUSUS',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text('Nomor : $noSurat', textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 16),
                  pw.Text('I. INFORMASI YANG DIPEROLEH',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Bullet(text: informasi),
                  pw.SizedBox(height: 16),
                  pw.Text('II. SUMBER INFORMASI',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Bullet(text: sumberInfo),
                  pw.SizedBox(height: 16),
                  pw.Text('III. TREN PERKEMBANGAN',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Bullet(text: trenPerkembangan),
                  pw.SizedBox(height: 16),
                  pw.Text('IV. PENDAPAT SARAN',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Bullet(text: pendapat),
                  pw.Bullet(text: saran),
                  pw.SizedBox(height: 32),
                  pw.Text('Dikeluarkan di ...........',
                      textAlign: pw.TextAlign.center),
                  pw.Text('Pada Tanggal $date', textAlign: pw.TextAlign.center),
                  pw.Text('Yang Membuat Laporan',
                      textAlign: pw.TextAlign.center),
                  pw.Text('Pranata Komputer Ahli Pertama Pada Bagian Umum Biro',
                      textAlign: pw.TextAlign.center),
                  pw.Text('Kepegawaian Muda Bidang Pembinaan',
                      textAlign: pw.TextAlign.center),
                  pw.Text('Kejaksaan Agung', textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 64),
                  pw.Text('Taruna Wira NIP.XXXXXX',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline)),
                ],
              );
            },
          ),
        );

        final Uint8List bytes = await pdf.save();

        final Directory tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/example.pdf');

        await file.writeAsBytes(bytes, flush: true);

        setState(() {
          pdfPath = file.path;
          print("pdfpath");
          print(pdfPath);
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> downloadPDF(BuildContext context) async {
    if (pdfPath == null) return;

    final status = await Permission.storage.request();

    if (status.isGranted) {
      final Directory? downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir!.exists()) {
        downloadsDir.create(recursive: true);
      }
      final String newPath = '${downloadsDir.path}/example.pdf';

      final File newFile = File(newPath);
      final File oldFile = File(pdfPath!);

      await newFile.writeAsBytes(await oldFile.readAsBytes(), flush: true);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PDF Downloaded to $newPath'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Storage permission denied'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Demo'),
      ),
      body: pdfPath != null
          ? Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: pdfPath!,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => downloadPDF(context),
                    child: const Text('Download PDF'),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
