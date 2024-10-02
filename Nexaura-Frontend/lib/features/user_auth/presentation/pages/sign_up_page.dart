import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nexaura/features/user_auth/authentication/firebase_auth_services.dart';
import 'package:nexaura/features/user_auth/presentation/pages/login_page.dart';
import 'package:nexaura/features/user_auth/presentation/pages/otp_verfication.dart';
import 'package:nexaura/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:nexaura/global/common/custom_scaffold.dart';
import 'package:nexaura/global/common/toast.dart';
import 'package:nexaura/theme/theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isSigningUp = false;
  final _formSignUpKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                ),
              ),
              Expanded(
                  flex: 7,
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
                        key: _formSignUpKey,
                        child: Column(
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: lightColorScheme.primary,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
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
                              height: 10,
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
                              height: 10,
                            ),
                            FormContainerWidget(
                              labelText: "Confirm Password",
                              controller: _confirmPasswordController,
                              hintText: "Confirm Password",
                              isPasswordField: true,
                              validator: (passwd) {
                                if (_confirmPasswordController.text.trim() !=
                                    _passwordController.text.trim()) {
                                  return "Password mismatch";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                _signUp();
                              },
                              child: Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: lightColorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: isSigningUp
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Sign Up",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
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
                                    'Sign up with',
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
                              onTap: _signInWithGoogle,
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
                                        "Sign up with Google",
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account?"),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage()),
                                          (route) => false);
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                          color: lightColorScheme.primary,
                                          fontWeight: FontWeight.bold),
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (!_formSignUpKey.currentState!.validate()) {
      showToast(message: "Invalid credentials");
      return;
    }
    setState(() {
      isSigningUp = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    bool res = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (route) => OtpVerfication(email: email))) ??
        false;
    if (!res) {
      showToast(message: "OTP verfication failed");
      return;
    }
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      isSigningUp = false;
    });
    if (user != null) {
      showToast(message: "User is successfully created");
      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: "Some error happend");
    }
  }

  _signInWithGoogle() async {
    final GoogleSignIn googleSignin = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
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

        await firebaseAuth.signInWithCredential(credential);
        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      showToast(message: "some error occured $e");
    }
  }
}
