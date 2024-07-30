import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../src/api.dart';
import '../../src/constant.dart';
import '../../src/loader.dart';
import '../../src/preference.dart';
import '../../src/utils.dart';
import '../../widgets/notification_widget.dart';
import 'package:path/path.dart' as path;

import 'component/pdfLapinhar.dart';

class LapinharPage extends StatefulWidget {
  // final id;
  const LapinharPage({Key? key}) : super(key: key);

  @override
  State<LapinharPage> createState() => _LapinharPageState();
}

class _LapinharPageState extends State<LapinharPage> {
  SharedPref sharedPref = SharedPref();
  String message = "";
  bool isProcess = true;
  List listData = [];
  String photo = "";

  String fullname = "";
  int userId = 0;
  var formatter = DateFormat.yMMMMd('en_US');

  final ScrollController _scrollController = ScrollController();
  var offset = 0;
  var limit = 10;

  final ctrlJenis = TextEditingController();
  final ctrlNoSurat = TextEditingController();
  final ctrlInformasi = TextEditingController();
  final ctrlSumber = TextEditingController();
  final ctrlTrend = TextEditingController();
  final ctrlPendapat = TextEditingController();
  final ctrlSaran = TextEditingController();
  final ctrlGambar = TextEditingController();
  final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  String? dropdownValue;

  // List of satker data
  final List<Map<String, String>> listDataJenis = [
    {'namaSatker': 'Lapinhar'},
    {'namaSatker': 'Lapinsus'},
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getData();
    super.initState();
  }

  createData() async {
    try {
      final jenisLaporan = ctrlJenis.text;
      final noSurat = ctrlNoSurat.text;
      final informasi = ctrlInformasi.text;
      final sumber = ctrlSumber.text;
      final trend = ctrlTrend.text;
      final pendapat = ctrlPendapat.text;
      final saran = ctrlSaran.text;

      var params = ({
        "jenis_laporan": jenisLaporan,
        "no_surat": noSurat,
        "informasi": informasi,
        "sumber_info": sumber,
        "tren_perkembangan": trend,
        "pendapat": pendapat,
        "saran": saran,
        "image": null,
      });
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.isindetil;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.post(Uri.parse(uri),
          headers: {
            "Authorization": bearerToken.toString(),
          },
          body: params);
      var content = json.decode(response.body);
      print("isidentil");
      print(response.statusCode);
      print(content.toString());

      if (response.statusCode == 200) {
        var content = json.decode(response.body);
        print("datanya");
        // listData = content['data'];
        fullname = content['data']['fullname'];
        // print(fullname);
        // listData = content['data'];
        listData.add(content['data']);
        print(listData);

        userId = content['data']['id'];
        print(userId);
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

  updateData() async {
    try {
      // final params = {'message': str.toString()};
      final jenisLaporan = ctrlJenis.text;
      final noSurat = ctrlNoSurat.text;
      final informasi = ctrlInformasi.text;
      final sumber = ctrlSumber.text;
      final trend = ctrlTrend.text;
      final pendapat = ctrlPendapat.text;
      final saran = ctrlSaran.text;
      final photo = _image;
      final photo2 = '${ApiService.folder}/$gambar';

      var url = ApiService.isindetil;
      var uri = url;
      var response = http.MultipartRequest(
        'POST',
        Uri.parse(uri),
      );
      var accessToken = await sharedPref.getPref("access_token");
      var bearerToken = 'Bearer $accessToken';
      Map<String, String> headers = {
        "Authorization": bearerToken.toString(),
        // "Content-type": "multipart/form-data" // Not required since it's automatically added by http.MultipartRequest
      };

      response.headers.addAll(headers);
      response.fields.addAll({
        "jenis_laporan": jenisLaporan,
        "no_surat": noSurat,
        "informasi": informasi,
        "sumber_info": sumber,
        "tren_perkembangan": trend,
        "pendapat": pendapat,
        "saran": saran,
      });

      if (photo is File) {
        final httpImage = http.MultipartFile.fromBytes(
          'image',
          // _image ?? photo as File
          File(photo.path).readAsBytesSync(),
          filename: path.basename(photo.path),
        );
        response.files.add(httpImage);
        // Use the URL directly
      } else {
        // final image = response.fields['image'] =photo2;
        // response.fields(photo2);
        //  response.files.clear();
        response.fields['image'] = photo2;
      }

      var request = await response.send();
      var responsed = await http.Response.fromStream(request);
      var content = json.decode(responsed.body);

      print(request);
      print(responsed);
      print(content);

      if (responsed.statusCode == 200) {
        _onAlertButtonPressed(context, true, "Data Berhasil Diperbaharui");
      } else {
        // ignore: use_build_context_synchronously
        _onAlertButtonPressed(context, 'Error', content['message']);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _onAlertButtonPressed(context, 'Error', e.toString());
      // toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
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

  getData() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.getisidentil;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri), headers: {
        "Authorization": bearerToken.toString(),
      });
      var content = json.decode(response.body);
      print("getdentil");
      print(response.statusCode);
      print(content.toString());

      if (response.statusCode == 200) {
        var content = json.decode(response.body);
        print("datanya");
        // listData = content['data'];
        // fullname = content['data']['fullname'];
        // print(fullname);
        // listData = content['data'];
        listData = content['data'];
        // listData.add(content['data']);
        print(listData);

        // userId = content['data']['id'];
        // print(userId);
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

  String formatDate(String dateTimeString) {
    DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'");
    DateFormat outputFormat = DateFormat("dd-MM-yyyy");
    DateTime dateTime = inputFormat.parse(dateTimeString);
    String formattedDate = outputFormat.format(dateTime);
    return formattedDate;
  }

  // XFile? _image;
  File? _image;
  var gambar;
  final picker = ImagePicker();
  var imageData;
  var filename;
  var splitted;
  File? pathgambar;

// Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageData = await pickedFile
          .readAsBytes(); //ini bytes imagenya yg dikirim ke server

      setState(() {
        // _image != null ? _image = File(pickedFile.path) :  _image = photo as File;
        _image = File(pickedFile.path);
        filename = pickedFile.name;
        ctrlGambar.text = pickedFile.path;
        print("imagepicked");
        print(_image);
      });

      // gambar = _image.toString();

      // splitted = gambar.split("/"); //ini path imagenya
      // print("object");

      // print(splitted[6]);
      // print(splitted[6] + "/" + splitted[7]);

      filename = pickedFile.name; //ini nama imagenya
    } else {
      _image = photo as File;
    }
  }

// Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageData = await pickedFile.readAsBytes();

      setState(() {
        // _image != null ? _image = File(pickedFile.path) :  _image = photo as File;
        _image = File(pickedFile.path);
        filename = pickedFile.name;
        ctrlGambar.text = pickedFile.path;
        print("imagepicked");
        print(_image);
      });

      filename = pickedFile.name;
      print(filename);
      print(_image);
    } else {
      _image = photo as File;
    }
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pullRefresh() async {
    setState(() {
      listData.clear();
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: clrPrimary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: const [],
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Lapinhar",
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.2575,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: clrPrimary,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500));
          setState(() {
            isProcess = true;
            listData.clear();
            _pullRefresh();
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: settingPage(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.001),
                  child: GestureDetector(
                    onTap: () {},
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.8,
                      minChildSize: 0.2,
                      maxChildSize: 0.95,
                      builder: (_, controller) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.remove,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Pencarian",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              const Divider(
                                thickness: 2,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: controller,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  dropdownColor: Colors.white,
                                                  decoration: InputDecoration(
                                                    hoverColor: clrPrimary,
                                                    hintText: 'Jenis Laporan',
                                                    label: Row(
                                                      children: [
                                                        Text(
                                                          "Jenis Laporan",
                                                          style: TextStyle(
                                                              color: _focusNodes[
                                                                          0]
                                                                      .hasFocus
                                                                  ? clrPrimary
                                                                  : Colors
                                                                      .grey),
                                                        ),
                                                        const Text(
                                                          " *",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  3.0),
                                                        ),
                                                      ],
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    // border: InputBorder.none,
                                                  ),
                                                  style: const TextStyle(
                                                      color: Colors
                                                          .black), // Set text color to white
                                                  items:
                                                      listDataJenis.map((item) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: item['namaSatker']
                                                          .toString(),
                                                      child: Text(
                                                        item['namaSatker']
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      dropdownValue = newValue!;
                                                      ctrlJenis.text = newValue;
                                                    });
                                                    print(
                                                        'Selected kodeSatker: $dropdownValue');
                                                  },
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  validator: (value) {
                                                    if (value == null) {
                                                      return 'Pilih Satker Terlebih Dahulu!';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          focusNode: _focusNodes[1],
                                          controller: ctrlNoSurat,
                                          // key: _formKey,
                                          decoration: InputDecoration(
                                            hoverColor: clrPrimary,
                                            hintText: 'No Surat',
                                            label: Row(
                                              children: [
                                                Text(
                                                  "No Surat",
                                                  style: TextStyle(
                                                      color: _focusNodes[0]
                                                              .hasFocus
                                                          ? clrPrimary
                                                          : Colors.grey),
                                                ),
                                                const Text(
                                                  " *",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            // focusedBorder: const UnderlineInputBorder(
                                            //   borderRadius: BorderRadius.all(
                                            //     Radius.circular(10),
                                            //   ),
                                            // ),
                                            // enabledBorder: const UnderlineInputBorder(
                                            //   borderRadius: BorderRadius.all(
                                            //     Radius.circular(10),
                                            //   ),
                                            //   borderSide: BorderSide(color: Colors.grey),
                                            // ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            // border: InputBorder.none,
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Informasi Yang Diperoleh!';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          focusNode: _focusNodes[2],
                                          controller: ctrlInformasi,
                                          // key: _formKey,
                                          decoration: InputDecoration(
                                            hoverColor: clrPrimary,
                                            hintText:
                                                'Informasi Yang Diperoleh',
                                            label: Row(
                                              children: [
                                                Text(
                                                  "Informasi Yang Diperoleh",
                                                  style: TextStyle(
                                                      color: _focusNodes[0]
                                                              .hasFocus
                                                          ? clrPrimary
                                                          : Colors.grey),
                                                ),
                                                const Text(
                                                  " *",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Informasi Yang Diperoleh!';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          focusNode: _focusNodes[3],
                                          controller: ctrlSumber,
                                          // key: _formKey,
                                          decoration: InputDecoration(
                                            hoverColor: clrPrimary,
                                            hintText: 'Sumber Informasi',
                                            label: Row(
                                              children: [
                                                Text(
                                                  "Sumber Informasi",
                                                  style: TextStyle(
                                                      color: _focusNodes[0]
                                                              .hasFocus
                                                          ? clrPrimary
                                                          : Colors.grey),
                                                ),
                                                const Text(
                                                  " *",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Pilih Sumber Informasi Dahulu!';
                                            }
                                            return null;
                                          },
                                          onTap: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2022),
                                              lastDate: DateTime(2024),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    colorScheme:
                                                        const ColorScheme.light(
                                                      primary: clrPrimary,
                                                      onPrimary: Colors.white,
                                                      onSurface: Colors.black,
                                                    ),
                                                    textButtonTheme:
                                                        TextButtonThemeData(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            clrPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (pickedDate != null) {
                                              String formattedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(pickedDate);

                                              setState(
                                                () {
                                                  ctrlSumber.text =
                                                      formattedDate;
                                                  print(ctrlSumber.text
                                                      .toString());
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          focusNode: _focusNodes[4],
                                          controller: ctrlTrend,
                                          decoration: InputDecoration(
                                            hoverColor: clrPrimary,
                                            hintText:
                                                'Masukkan Trend Perkembangan',
                                            label: Row(
                                              children: [
                                                Text(
                                                  "Trend Perkembangan",
                                                  style: TextStyle(
                                                      color: _focusNodes[0]
                                                              .hasFocus
                                                          ? clrPrimary
                                                          : Colors.grey),
                                                ),
                                                const Text(
                                                  " *",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Pilih Trend Perkembangan Dahulu!';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          focusNode: _focusNodes[5],
                                          controller: ctrlPendapat,
                                          decoration: InputDecoration(
                                            hoverColor: clrPrimary,
                                            hintText: 'Masukkan Pendapat',
                                            label: Row(
                                              children: [
                                                Text(
                                                  "Pendapat",
                                                  style: TextStyle(
                                                      color: _focusNodes[0]
                                                              .hasFocus
                                                          ? clrPrimary
                                                          : Colors.grey),
                                                ),
                                                const Text(
                                                  " *",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            // border: InputBorder.none,
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Pendapat Saran!';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          focusNode: _focusNodes[6],
                                          controller: ctrlSaran,
                                          decoration: InputDecoration(
                                            hoverColor: clrPrimary,
                                            hintText: 'Masukkan Saran',
                                            label: Row(
                                              children: [
                                                Text(
                                                  "Saran",
                                                  style: TextStyle(
                                                      color: _focusNodes[0]
                                                              .hasFocus
                                                          ? clrPrimary
                                                          : Colors.grey),
                                                ),
                                                const Text(
                                                  " *",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Saran!';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: TextFormField(
                                          focusNode: _focusNodes[7],
                                          controller: ctrlGambar,
                                          decoration: InputDecoration(
                                            hoverColor: clrPrimary,
                                            hintText: 'Pilih Gambar',
                                            label: Row(
                                              children: [
                                                Text(
                                                  "Gambar",
                                                  style: TextStyle(
                                                      color: _focusNodes[0]
                                                              .hasFocus
                                                          ? clrPrimary
                                                          : Colors.grey),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          onTap: () {
                                            showOptions();
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Gambar!';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          updateData();
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20.0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          decoration: BoxDecoration(
                                            color: clrPrimary,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "Buat",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 25.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: clrPrimary,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget settingPage() {
    if (listData.isNotEmpty) {
      return ListView.separated(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) {
          var row = listData[index];

          String timestamp = row['created_at'];
          DateTime dateTime = DateTime.parse(timestamp);

          // Misalkan format yang diinginkan adalah "dd-MM-yyyy HH:mm:ss"
          String formattedDate =
              DateFormat("dd-MM-yyyy_HH-mm-ss").format(dateTime);

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PDFHomeLapinharPage(
                          lapinsusCreated: formattedDate,
                          lapinsusId: row['id'].toString(),
                          data: listData),
                    ),
                  );
                },
                child: NotificationCardWidget(
                  isOnline: false,
                  message: 'Nomor Surat',
                  count: '',
                  time: row['no_surat'] ?? "",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        },
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        itemCount: listData.isEmpty ? 0 : listData.length,
      );
    } else {
      return loaderDialog(context);
    }
  }
}
