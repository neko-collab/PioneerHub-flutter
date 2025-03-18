import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/controllers/pioneerhub_info_controller.dart';
import 'package:pioneerhub_app/models/pioneerhub_info.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/auth/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PioneerHubInfo? _pioneerHubInfo;

  bool notvisible = true;
  bool isLoading = false;

  final ApiService apiService = ApiService();
  final AuthController authController;

  _SignUpPage() : authController = AuthController(apiService: ApiService());

    @override
  void initState() {
    super.initState();
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
    var user = await authController.getLoggedInUser();
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
  void createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final user = await authController.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please log in.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

   

  @override
  Widget build(BuildContext context) {
    final pioneerHubInfoName = _pioneerHubInfo?.name ?? 'PioneerHub';
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              height: size.height / 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.asset('assets/images/signup.jpg'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
              child: Column(
                children: [
                   Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Register on $pioneerHubInfoName',
                      style: TextStyle(fontSize: 18, color: Colors.indigo, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person_outline, color: Colors.grey),
                            labelText: 'Full Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your name';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.alternate_email_outlined, color: Colors.grey),
                            labelText: 'Email ID',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your email';
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: notvisible,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  notvisible = !notvisible;
                                });
                              },
                              icon: Icon(notvisible ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your password';
                            if (value.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                        child: const Text(
                          'By signing up, you agree to our Terms & conditions and Privacy Policy',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : createUser,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up", style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Joined us before? ",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                        GestureDetector(
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                        ),
                      ],
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