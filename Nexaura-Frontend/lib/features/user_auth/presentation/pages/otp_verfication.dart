import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexaura/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:nexaura/global/common/custom_scaffold.dart';
import 'package:nexaura/global/common/toast.dart';
import 'package:nexaura/theme/theme.dart';

class OtpVerfication extends StatefulWidget {
  final String email;
  const OtpVerfication({super.key, required this.email});

  @override
  State<OtpVerfication> createState() => _OtpVerficationState();
}

class _OtpVerficationState extends State<OtpVerfication> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pin1 = TextEditingController();
  final TextEditingController _pin2 = TextEditingController();
  final TextEditingController _pin3 = TextEditingController();
  final TextEditingController _pin4 = TextEditingController();
  final _otpFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    EmailOTP.config(
        appName: "Nexaura",
        appEmail: "admin@nexaura.in",
        otpLength: 4,
        otpType: OTPType.numeric,
        expiry: 120000,
        emailTheme: EmailTheme.v2);
    _emailController.text = widget.email;
    _sendOtp();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pin1.dispose();
    _pin2.dispose();
    _pin3.dispose();
    _pin4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
                flex: 1,
                child: SizedBox(
                  height: 10,
                )),
            Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0))),
                  child: SingleChildScrollView(
                    child: Form(
                        key: _otpFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'OTP Verification',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: lightColorScheme.primary,
                              ),
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                            FormContainerWidget(
                              labelText: "Email",
                              enable: false,
                              controller: _emailController,
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _otpFeild(1, _pin1),
                                _otpFeild(2, _pin2),
                                _otpFeild(3, _pin3),
                                _otpFeild(4, _pin4),
                              ],
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: _otpVerfication,
                                child: Container(
                                  width: double.infinity,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: lightColorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Verfy OTP",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                ))
          ],
        ),
      ),
    ));
  }

  Widget _otpFeild(int i, TextEditingController controller) {
    return SizedBox(
      width: 64,
      height: 68,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Enter otp";
          }
          return null;
        },
        onChanged: (value) {
          if (value.isEmpty && i != 1) {
            FocusScope.of(context).previousFocus();
          }
          if (value.length == 1 && i != 4) {
            FocusScope.of(context).nextFocus();
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          hintStyle: const TextStyle(
            color: Colors.black26,
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black12, // Default border color
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black12, // Default border color
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _sendOtp() async {
    bool res = await EmailOTP.sendOTP(email: _emailController.text.trim());
    if (res) {
      showToast(message: "OTP sent");
    } else {
      showToast(message: "Unable to sent OTP");
    }
  }

  void _otpVerfication() {
    setState(() {
      isLoading = true;
    });
    if (!(_otpFormKey.currentState!.validate())) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (!EmailOTP.verifyOTP(
        otp: _pin1.text + _pin2.text + _pin3.text + _pin4.text)) {
      showToast(message: "Invalid OTP");
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context, true);
  }
}
