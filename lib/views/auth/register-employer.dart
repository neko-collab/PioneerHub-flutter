import 'package:flutter/material.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/views/auth/login.dart';

class RegisterEmployerPage extends StatefulWidget {
  @override
  _RegisterEmployerPageState createState() => _RegisterEmployerPageState();
}

class _RegisterEmployerPageState extends State<RegisterEmployerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController companySizeController = TextEditingController();
  final TextEditingController companyWebsiteController = TextEditingController();
  final TextEditingController companyLocationController = TextEditingController();
  final TextEditingController companyDescriptionController = TextEditingController();
  bool notvisible = true;
  bool isLoading = false;
  
  final AuthController authController = AuthController(apiService: ApiService());

  void registerEmployer() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final user = await authController.registerEmployer(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        companyNameController.text.trim(),
        industryController.text.trim(),
        companySize: companySizeController.text.trim(),
        companyWebsite: companyWebsiteController.text.trim(),
        companyLocation: companyLocationController.text.trim(),
        companyDescription: companyDescriptionController.text.trim(),
      );
      
      if (user != null) {
        // Registration was successful and user was automatically logged in
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Registration was successful but requires admin approval
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Your account will be reviewed by an admin.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Image.asset('assets/images/signup.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Register as Employer",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w800,
                      ),
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
                        TextFormField(
                          controller: companyNameController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.business, color: Colors.grey),
                            labelText: 'Company Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your company name';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: industryController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.category_outlined, color: Colors.grey),
                            labelText: 'Industry',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your industry';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: companySizeController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.people_outline, color: Colors.grey),
                            labelText: 'Company Size (e.g., 10-50)',
                          ),
                        ),
                        TextFormField(
                          controller: companyWebsiteController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.web, color: Colors.grey),
                            labelText: 'Company Website',
                          ),
                        ),
                        TextFormField(
                          controller: companyLocationController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.location_on_outlined, color: Colors.grey),
                            labelText: 'Company Location',
                          ),
                        ),
                        TextFormField(
                          controller: companyDescriptionController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.description_outlined, color: Colors.grey),
                            labelText: 'Company Description',
                          ),
                          maxLines: 3,
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
                    onPressed: isLoading ? null : registerEmployer,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up as Employer", style: TextStyle(fontSize: 15)),
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