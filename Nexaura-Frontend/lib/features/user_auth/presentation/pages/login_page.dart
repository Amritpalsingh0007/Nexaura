import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nexaura/features/user_auth/authentication/firebase_auth_services.dart';
import 'package:nexaura/features/user_auth/presentation/pages/forgot_password_page.dart';
import 'package:nexaura/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:nexaura/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:nexaura/global/common/custom_scaffold.dart';
import 'package:nexaura/global/common/toast.dart';

import '../../../../theme/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                flex: 2,
                child: SizedBox(
                  height: 10,
                ),
              ),
              Expanded(
                flex: 9,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome back',
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
                          FormContainerWidget(
                            labelText: "Password",
                            controller: _passwordController,
                            hintText: "Enter Password",
                            isPasswordField: true,
                            validator: (passwd) {
                              if (!RegExp(
                                      r'''^[\w!"#$%&'()*+,\-./:;<=>?@[\]^_`{|}~]{8,}$''')
                                  .hasMatch(passwd ?? "")) {
                                return "Password should be at least 8 characters long";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 1,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPasswordPage()));
                                },
                                child: Text(
                                  'Forget password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                _signIn();
                              },
                              child: Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: lightColorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: _isSigning
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'Log in with',
                                  style: TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 25.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              _signInWithGoogle();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black45,
                                      offset: Offset(
                                        1.0,
                                        1.0,
                                      ), //Offset
                                      blurRadius: 1.5,
                                      spreadRadius: 0.5,
                                    ), //BoxShadow
                                    BoxShadow(
                                      color: Colors.white,
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 0.0,
                                      spreadRadius: 0.0,
                                    ), //BoxShadow
                                  ]),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/google.svg',
                                      semanticsLabel: 'google logo',
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    const Text(
                                      "Log in with Google",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 25.0,
                          ),
                          // don't have an account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (e) => const SignUpPage(),
                                      ),
                                      (route) => false);
                                },
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) {
      showToast(message: "Invalid credentials!");
      return;
    }
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      showToast(message: "User is successfully signed in");
      Navigator.pushNamed(context, "/home");
    }
  }

  _signInWithGoogle() async {
    final GoogleSignIn googleSignin = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignin.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      showToast(message: "some error occured $e");
    }
  }
}
