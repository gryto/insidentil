import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../../../src/constant.dart';
import '../../../src/api.dart';
import '../../../src/preference.dart';

class LapinsusDetail extends StatefulWidget {
  final String lapinsusSaran,
      lapinsusJenis,
      lapinsusNosurat,
      lapinsusInformasi,
      lapinsusSumber,
      lapinsusTren,
      lapinsusPendapat,
      lapinsusGambar,
      lapinsusId,
      lapinsusCreated;
  const LapinsusDetail({
    super.key,
    required this.lapinsusJenis,
    required this.lapinsusNosurat,
    required this.lapinsusInformasi,
    required this.lapinsusSumber,
    required this.lapinsusTren,
    required this.lapinsusPendapat,
    required this.lapinsusSaran,
    required this.lapinsusGambar,
    required this.lapinsusId,
    required this.lapinsusCreated,
  });

  @override
  State<LapinsusDetail> createState() => _LapinsusDetailState();
}

class _LapinsusDetailState extends State<LapinsusDetail> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
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
    double w = MediaQuery.of(context).size.width - 0;

    var img = "";
    var avatar = widget.lapinsusGambar;
    if (avatar != "") {
      img = '${ApiService.folder}/$avatar';
    } else {
      img = ApiService.imgDefault;
    }
  
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: clrPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Detail",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
              },
              child: const Icon(Icons.download),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                width: w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        // width: 200,
                        // height: 200,
                        imageUrl: img,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: const Text(
                        "Jenis Surat",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusJenis,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.text_fields),
                      title: const Text(
                        "No Surat",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusNosurat,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.wifi),
                      title: const Text(
                        "Sumber Informasi",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusSumber,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.mobile_friendly),
                      title: const Text(
                        "Informasi",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusInformasi,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.laptop),
                      title: const Text(
                        "Trend Informasi",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusTren,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.create),
                      title: const Text(
                        "Pendapat",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusPendapat,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text(
                        "Saran",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusSaran,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text(
                        "Gambar",
                        style: TextStyle(fontSize: 12, height: 1.8),
                      ),
                      subtitle: Text(
                        widget.lapinsusGambar,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
