import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/controllers/pioneerhub_info_controller.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/models/pioneerhub_info.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthController _authController;
  PioneerHubInfo? _pioneerHubInfo;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(apiService: ApiService());
    _loadPioneerHubInfo();
    _checkIfLoggedIn();
  }

  Future<void> _loadPioneerHubInfo() async {
    var pihController = PioneerHubInfoController(apiService: ApiService());
    await pihController.fetchAndSavePioneerHubInfo();

    var box = Hive.box('pioneerHubInfoBox');
    var infoList = box.get('pioneerHubInfo') as List<dynamic>?;
    if (infoList != null && infoList.isNotEmpty) {
      setState(() {
        _pioneerHubInfo = infoList.first as PioneerHubInfo;
      });
    }
  }

  Future<void> _checkIfLoggedIn() async {
    var user = await _authController.getLoggedInUser();
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pioneerHubInfoName = _pioneerHubInfo?.name ?? 'Pioneer Hub Space';
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.asset('assets/images/login.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text("Login on Pioneer Hub Space",
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.indigo,
                            fontWeight: FontWeight.w800,
                            )),
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.alternate_email_outlined, color: Colors.grey),
                            labelText: 'Enter your email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock_outline_rounded, color: Colors.grey),
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                        child: const Text('Forgot Password?',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.indigo)),
                        onTap: () {
                          Navigator.pushNamed(context, '/forgot_password');
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await _authController.login(_emailController.text, _passwordController.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful')));
                          Navigator.pushReplacementNamed(context, '/home');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Center(child: Text("Login", style: TextStyle(fontSize: 14))),
                  ),
                  const SizedBox(height: 15),
                  Stack(
                    children: [
                      const Divider(thickness: 1),
                      Center(
                        child: Container(
                          color: Colors.white,
                          width: 70,
                          child: const Center(
                            child: Text("OR", style: TextStyle(fontSize: 20, backgroundColor: Colors.white)),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New to the App? ",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)),
                      GestureDetector(
                        child: const Text("Register",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo)),
                        onTap: () {
                          Navigator.pushNamed(context, '/register-select');
                        },
                      )
                    ],
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}