import 'package:flutter/material.dart';
import 'package:flutter_webrtc_mifone/main.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/mipbx.png",
                width: 130,
                height: 130,
              ),
              const Padding(padding: EdgeInsets.only(top: 24)),
              const Text(
                'MiFone',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              const Padding(padding: EdgeInsets.only(top: 4)),
              const Text(
                'Powerred by MITEK',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const Padding(padding: EdgeInsets.only(top: 12)),
              Text(
                'Version: v1.5.4',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 16)),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                      color: colorMain,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 16)),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Terms Of Use',
                  style: TextStyle(
                      color: colorMain,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
