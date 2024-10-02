import 'package:flutter/material.dart';
import 'package:nexaura/global/common/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  final String? message;
  const WelcomeScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(microseconds: 500));
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                              text: 'Welcome to Nexaura\n',
                              style: TextStyle(
                                fontSize: 33.0,
                                fontWeight: FontWeight.w600,
                              )),
                          TextSpan(
                              text: message ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                // height: 0,
                              ))
                        ],
                      )),
                ),
              )),
        ],
      ),
    );
  }
}
