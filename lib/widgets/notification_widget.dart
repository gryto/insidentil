import 'package:flutter/material.dart';
import '../src/utils.dart';
import 'spacer/spacer_custom.dart';

class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    super.key,
    required this.isOnline,
    required this.message,
    required this.count,
    required this.time,
  });

  final bool isOnline;
  final String message;
  final String count;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x21000000),
              offset: Offset(0, 2),
              blurRadius: 24,
            ),
          ],
        ),
        child: Row(
          children: [
            const CustomWidthSpacer(
              size: 0.03,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2575,
                      letterSpacing: 0.6000000238,
                      color: Colors.black87,
                    ),
                  ),
                  const CustomWidthSpacer(
                    size: 0.03,
                  ),
                  const CustomHeightSpacer(
                    size: 0.003,
                  ),
                  Text(
                    time,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.2575,
                      letterSpacing: 0.6000000238,
                      color: const Color(0xff77838f),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
