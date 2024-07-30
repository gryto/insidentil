import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../src/constant.dart';
import '../../../src/api.dart';

class LapinharDetail extends StatelessWidget {
  final String lapinharSaran,
      lapinharJenis,
      lapinharNosurat,
      lapinharInformasi,
      lapinharSumber,
      lapinharTren,
      lapinharPendapat,
      lapinharGambar;

  const LapinharDetail({
    Key? key,
    required this.lapinharJenis,
    required this.lapinharNosurat,
    required this.lapinharInformasi,
    required this.lapinharSumber,
    required this.lapinharTren,
    required this.lapinharPendapat,
    required this.lapinharSaran,
    required this.lapinharGambar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width - 0;

    var img = "";
    var avatar = lapinharGambar;
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
        title: const Text("Detail",
            style: TextStyle(
              color: Colors.white,
            )),
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
                        lapinharJenis,
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
                        lapinharNosurat,
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
                        lapinharSumber,
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
                        lapinharInformasi,
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
                        lapinharTren,
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
                        lapinharPendapat,
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
                        lapinharSaran,
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
                        lapinharGambar,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
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
