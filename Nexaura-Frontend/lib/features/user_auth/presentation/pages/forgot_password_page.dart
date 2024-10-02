import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexaura/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:nexaura/global/common/custom_scaffold.dart';
import 'package:nexaura/global/common/toast.dart';
import 'package:nexaura/theme/theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _passwdResetKey = GlobalKey<FormState>();
  bool isReset = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    if (!_passwdResetKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isReset = true;
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showToast(message: "Verification link sent");
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        showToast(message: "User not Found");
      } else {
        showToast(message: "${e.code} : ${e.message.toString()}");
      }
    } finally {
      setState(() {
        isReset = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            const Expanded(
                flex: 1,
                child: SizedBox(
                  height: 10.0,
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
                      key: _passwdResetKey,
                      child: Column(
                        children: [
                          Text(
                            'Forgot Password',
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
                            controller: _emailController,
                            hintText: "Enter Email",
                            isPasswordField: false,
                            validator: (email) {
                              RegExp emailReg = RegExp(
                                  r'^[\w\.-]+@([\w]+-?[\w]+)+\.[a-z]{2,3}(\.[a-z]{2,3})?$');
                              if (!emailReg.hasMatch(email ?? "")) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: passwordReset,
                              child: Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: lightColorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: isReset
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Reset Password",
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
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    ));
  }
}
