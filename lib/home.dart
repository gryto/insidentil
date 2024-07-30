import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:insidentil/screen/lapinhar/page.dart';
import '../src/preference.dart';
import 'screen/lapinsus/page.dart';
import 'screen/profile/page.dart';
import 'src/api.dart';
import 'src/constant.dart';
import 'src/toast.dart';
import 'src/utils.dart';
import 'package:http/http.dart' as http;

class MainTabBar extends StatefulWidget {
  final id;
  // final page;
  const MainTabBar({
    Key? key,
    required this.id,
    //  required this.page
  }) : super(key: key);

  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  SharedPref sharedPref = SharedPref();
  bool isProcess = false;
  int pageIndex = 0;
  String fullName = "";
  String division = "";
  String typeUser = "";
  String path = "";
  String accessToken = "";
  String dateString = "";
  late final Function(int) callback;
  String message = "";
  List<Map<String, dynamic>> listData = [];
  List listDataHistoryMonth = [];
  List listDataHistoryWeek = [];
  List listDataHistoryDay = [];
  String messagess = "";
  List<Widget> pages = <Widget>[]; // Declare pages here

  String fullname = "";
  late int userId = 0;

  var offset = 0;
  var limit = 10;

  @override
  void initState() {
    getData(widget.id);
    super.initState();
  }

  getData(id) async {
    pages = [
      // ChatRoomPage(senderId: userId.toString(), data: listDataHistoryDay, image: path),
    ];
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.detailUser;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});

      if (response.statusCode == 200) {
        setState(() {
          var content = json.decode(response.body);

          fullname = content['data']['fullname'];
          division = content['data']['getrole']['name'];
          listData.add(content['data']);
          userId = content['data']['id'];
          path = content['data']['image'];
          pages = [
            // ChatRoomPage(senderId: userId.toString(), data: listDataHistoryDay, image: path),
          ];
        });
      } else {
        toastShort(context, message);
      }
    } catch (e) {
      toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        backgroundColor: clrPrimary,
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Center(
            child: Text(
              'Home',
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.2575,
                letterSpacing: 1,
                color: Colors.white,
              ),
              selectionColor: pageIndex == 2
                  ? Theme.of(context).primaryColor
                  : clrBackground,
            ),
          ),

          // GestureDetector(
          //   onTap: () {},
          //   child: const Icon(
          //     Icons.notifications,
          //     color: clrBackground,
          //   ),
          // ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 105,
                    decoration: const BoxDecoration(
                      color: clrPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 0, right: 0, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SELAMAT DATANG!",
                                style: SafeGoogleFont(
                                  'SF Pro Text',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2575,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                              // const Text(
                              //   "SELAMAT DATANG!",
                              //   style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 20,
                              //       fontWeight: FontWeight.w700),
                              // ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SettingLogic(id: widget.id),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullname,
                                      style: SafeGoogleFont(
                                        'SF Pro Text',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2575,
                                        letterSpacing: 1,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      division,
                                      style: SafeGoogleFont(
                                        'SF Pro Text',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2575,
                                        letterSpacing: 1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LapinharPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 5, left: 0, right: 0, bottom: 5),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(70),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 204, 232, 255)),
                                    child: const Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "LAPINHAR",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            "Laporan Informasi Harian",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: clrPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LapinsusPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 5, left: 0, right: 0, bottom: 5),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(70),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 204, 232, 255)),
                                    child: const Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "LAPINSUS",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            "Laporan Informasi Khusus",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: clrPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 55,
              ),
            ],
          ),
        ),
      ),
    );
  }

  lastMonth({required final data}) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        if (index < 5) {
          var row = data[index];

          return GestureDetector(
            child: ListTile(
              title: Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                row['message'] ?? "-",
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: pageIndex == 1 ? clrPrimary : clrBackground,
                ),
              ),
              onTap: () {},
            ),
          );
        }
        return null;
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: data.isEmpty ? 0 : data.length,
    );
  }

  lastWeek({required final data}) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        if (index < 5) {
          var row = data[index];

          return GestureDetector(
            child: ListTile(
              title: Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                row['message'] ?? "-",
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: pageIndex == 1 ? clrPrimary : clrBackground,
                ),
              ),
              onTap: () {},
            ),
          );
        }
        return null;
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: data.isEmpty ? 0 : data.length,
    );
  }

  lastDay({required final data}) {
    int startIndex = data.length > 5 ? data.length - 5 : 0;
    int itemCount = data.length > 5 ? 5 : data.length;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        var row = data[startIndex + index];

        return GestureDetector(
          child: ListTile(
            title: Text(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              row['message'] ?? "-",
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2575,
                letterSpacing: 1,
                color: pageIndex == 1 ? clrPrimary : clrBackground,
              ),
            ),
            onTap: () {},
          ),
        );
        // }
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: itemCount,
    );
  }
}
