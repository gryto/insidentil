import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:insidentil/src/constant.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../src/preference.dart';

// ignore: must_be_immutable
class PDFHomeLapinharPage extends StatefulWidget {
  String lapinsusCreated, lapinsusId;
  List data;
  PDFHomeLapinharPage({
    super.key,
    required this.lapinsusCreated,
    required this.lapinsusId,
    required this.data,
  });

  @override
  State<PDFHomeLapinharPage> createState() => _PDFHomeLapinharPageState();
}

class _PDFHomeLapinharPageState extends State<PDFHomeLapinharPage> {
  String? pdfPath;
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];

  @override
  void initState() {
    super.initState();
    fetchDataAndGeneratePDF(widget.lapinsusId);
  }

  Future<void> fetchDataAndGeneratePDF(String reportId) async {
    // Find the report based on the ID
    var report =
        widget.data.firstWhere((report) => report['id'].toString() == reportId);

    if (report != null) {
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
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('RAHASIA',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Kejaksaan Agung',
                        textAlign: pw.TextAlign.start,
                        style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Copy Ke : ....... Dari : ....... Copies',
                        style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
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
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Dikeluarkan di ...........',
                        textAlign: pw.TextAlign.center),
                    pw.Text('Pada Tanggal $date',
                        textAlign: pw.TextAlign.center),
                    pw.Text('Yang Membuat Laporan',
                        textAlign: pw.TextAlign.center),
                    pw.Text(
                        'Pranata Komputer Ahli Pertama Pada Bagian Umum Biro',
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
                ),
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
        print("PDF path: $pdfPath");
      });
    } else {
      throw Exception('Report not found');
    }
  }

  Dio dio = Dio();

  Future downloadPdf(context, fileUrl, fileName) async {
    final output = await getDownloadPath(context);
    final savePath = '$output/$fileName';
    print("donlod33");
    print(output);
    print(savePath);

    download2(context, fileUrl, savePath);
  }

  Future download2(context, fileUrl, savePath) async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var bearerToken = 'Bearer $accessToken';
      Response response = await Dio().get(
        fileUrl,
        onReceiveProgress: showDownloadProgress,
        options: Options(
          responseType:
              ResponseType.bytes, // Mendapatkan response sebagai bytes
          headers: {
            'Authorization': bearerToken
                .toString(), // Tambahkan token otorisasi jika diperlukan
          },
        ),
      );

      File file = File(savePath);
      print("filepath");
      print(file);
      var raf = file.openSync(mode: FileMode.write);

      raf.writeFromSync(response.data);
      await raf.close();

      _onAlertButtonPressed(context, true, "File PDF berhasil di download");
    } catch (e) {
      _onAlertButtonPressed(context, false, e.toString());
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      (received / total * 100).toStringAsFixed(0);
    }
  }

  Future<String?> getDownloadPath(context) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      _onAlertButtonPressed(context, false, "Folder download tidak ditemukan");
    }

    return directory?.path;
  }

  _onAlertButtonPressed(context, status, message) {
    Alert(
      context: context,
      type: !status ? AlertType.error : AlertType.success,
      title: "",
      desc: message,
      buttons: [
        DialogButton(
          color: clrPrimary,
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('PDF Demo'),
          GestureDetector(
            onTap: () {
              downloadPdf(
                  context,
                  "http://paket7.kejaksaan.info:3007/api/laporanpdf/${widget.lapinsusId}",
                  // 'laporan.pdf',
                  'Report_insidentil${widget.lapinsusCreated}.pdf');

              // );
            },
            child: const Icon(Icons.download),
          ),
        ],
      )),
      body: pdfPath != null
          ? Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: pdfPath!,
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.all(8.0),
                //   child: GestureDetector(
                //     onTap: () {
                //       // downloadPDF;
                //       downloadPdf(context, "widget.name", pdfPath);
                //     },
                //     child: const Padding(
                //       padding: EdgeInsets.only(right: 15),
                //       child: Icon(
                //         Icons.download,
                //         color: clrPrimary,
                //       ),
                //     ),
                //   ),
                //   //  ElevatedButton(
                //   //   onPressed: downloadPdf(context, "widget.name", pdfPath),
                //   //   child: Text('Download PDF'),
                //   // ),
                // ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}



// class PDFHomeLapinharPage extends StatefulWidget {
//   late String lapinsusCreated;
//   @override
//   _PDFHomeLapinharPageState createState() => _PDFHomeLapinharPageState();
// }

// class _PDFHomeLapinharPageState extends State<PDFHomeLapinharPage> {
  

//   // Future<void> downloadPDF() async {
//   //   print("pdfpath");
//   //   print(pdfPath);
//   //   print(pdfPath == null);
//   //   if (pdfPath == null) return;

//   //   final status = await Permission.storage.request();
//   //   print("status");
//   //   print(status);

//   //   if (status.isGranted) {
//   //     final Directory? downloadsDir = await getExternalStorageDirectory();
//   //     final String newPath = '${downloadsDir!.path}/example.pdf';
//   //     print("path baru");
//   //     print(newPath);

//   //     final File newFile = File(newPath);
//   //     final File oldFile = File(pdfPath!);
//   //     await newFile.writeAsBytes(await oldFile.readAsBytes(), flush: true);

//   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //       content: Text('PDF Downloaded to $newPath'),
//   //     ));
//   //   } else {
//   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //       content: Text('Storage permission denied'),
//   //     ));
//   //   }
//   // }

//   @override
  
// }
