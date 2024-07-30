import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:convert';
import 'package:insidentil/src/constant.dart';
import 'package:insidentil/src/api.dart';
import 'package:insidentil/src/preference.dart';

class PDFHomePage24 extends StatefulWidget {
  @override
  _PDFHomePage24State createState() => _PDFHomePage24State();
}

class _PDFHomePage24State extends State<PDFHomePage24> {
  String? pdfPath;
  SharedPref sharedPref = SharedPref();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataAndGeneratePDF();
  }

  Future<void> fetchDataAndGeneratePDF() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.getlapinsus;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(url), headers: {
        "Authorization": bearerToken,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reports = data['data'] as List;
        if (reports.isNotEmpty) {
          final report = reports[0];

          // Create a PDF document
          final PdfDocument document = PdfDocument();
          final PdfPage page = document.pages.add();
          final PdfGraphics graphics = page.graphics;
          final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

          // Add content to the PDF
          graphics.drawString('Jenis Laporan: ${report['jenis_laporan']}', font,
              bounds: Rect.fromLTWH(0, 0, 500, 20));
          graphics.drawString('No Surat: ${report['no_surat']}', font,
              bounds: Rect.fromLTWH(0, 20, 500, 20));
          graphics.drawString('Informasi: ${report['informasi']}', font,
              bounds: Rect.fromLTWH(0, 40, 500, 20));
          graphics.drawString('Sumber Info: ${report['sumber_info']}', font,
              bounds: Rect.fromLTWH(0, 60, 500, 20));
          graphics.drawString(
              'Tren Perkembangan: ${report['tren_perkembangan']}', font,
              bounds: Rect.fromLTWH(0, 80, 500, 20));
          graphics.drawString('Pendapat: ${report['pendapat']}', font,
              bounds: Rect.fromLTWH(0, 100, 500, 20));
          graphics.drawString('Saran: ${report['saran']}', font,
              bounds: Rect.fromLTWH(0, 120, 500, 20));

          // Save the PDF to bytes
          final Future<List<int>> bytes = document.save();
          document.dispose();

          // Save the PDF file to the temporary directory
          final Directory tempDir = await getTemporaryDirectory();
          final File file = File('${tempDir.path}/example.pdf');
          await file.writeAsBytes(bytes as List<int>, flush: true);

          setState(() {
            pdfPath = file.path;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _onAlertButtonPressed(context, false, 'Failed to generate PDF: $e');
    }
  }

  Future<String?> getDownloadPath(BuildContext context) async {
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

  void _onAlertButtonPressed(
      BuildContext context, bool status, String message) {
    Alert(
      context: context,
      type: status ? AlertType.success : AlertType.error,
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

  Future<void> downloadPdf(
      BuildContext context, String fileName, String fileUrl) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final output = await getDownloadPath(context);
      if (output != null) {
        final savePath = '$output/$fileName';
        await download2(context, fileUrl, savePath);
      }
    } else {
      _onAlertButtonPressed(context, false, 'Storage permission denied');
    }
  }

  Future<void> download2(
      BuildContext context, String fileUrl, String savePath) async {
    try {
      Response response = await Dio().get(
        fileUrl,
        onReceiveProgress: showDownloadProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      _onAlertButtonPressed(context, true, "File PDF berhasil di download");
    } catch (e) {
      _onAlertButtonPressed(context, false, 'Failed to download PDF: $e');
    }
  }

  void showDownloadProgress(int received, int total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Demo'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: pdfPath!,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (pdfPath != null) {
                        downloadPdf(context, 'example.pdf', pdfPath!);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: Icon(
                        Icons.download,
                        color: clrPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
