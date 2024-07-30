import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insidentil/src/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../src/api.dart';
import '../../../src/preference.dart';

class PdfPage extends StatefulWidget {
  final String lapinsusId, lapinsusCreated;
  const PdfPage(
      {super.key, required this.lapinsusId, required this.lapinsusCreated});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];

  createData(id) async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.getPdf;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(
        Uri.parse(uri),
        headers: {
          "Authorization": bearerToken.toString(),
        },
      );
      var content = json.decode(response.body);
      print("isidentil");
      print(response.statusCode);
      print(content.toString());

      if (response.statusCode == 200) {
        var content = json.decode(response.body);
        print("datanya");
        listData.add(content['data']);
        print(listData);
      } else {
        // ignore: use_build_context_synchronously
        // onBasicAlertPressed(context, 'Error', content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // onBasicAlertPressed(context, 'Error', e.toString());
      // toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Download PDF Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              downloadPdf(
                  context,
                  "http://paket7.kejaksaan.info:3007/api/laporanpdf/${widget.lapinsusId}",
                  // 'laporan.pdf',
                  'Report_insidentil${widget.lapinsusCreated}.pdf');
            },
            child: const Text('Download PDF'),
          ),
        ),
      ),
    );
  }
}
