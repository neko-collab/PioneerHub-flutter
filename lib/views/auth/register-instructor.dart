import 'package:flutter/material.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/views/auth/login.dart';

class RegisterInstructorPage extends StatefulWidget {
  @override
  _RegisterInstructorPageState createState() => _RegisterInstructorPageState();
}

class _RegisterInstructorPageState extends State<RegisterInstructorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController qualificationsController = TextEditingController();
  final TextEditingController expertiseAreasController = TextEditingController();
  final TextEditingController yearsExperienceController = TextEditingController();
  bool notvisible = true;
  bool isLoading = false;
  
  final AuthController authController = AuthController(apiService: ApiService());

  void registerInstructor() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      int yearsExperience = 0;
      try {
        yearsExperience = int.parse(yearsExperienceController.text.trim());
      } catch (e) {
        // Default to 0 if parsing fails
      }

      final user = await authController.registerInstructor(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        bioController.text.trim(),
        qualificationsController.text.trim(),
        expertiseAreas: expertiseAreasController.text.trim(),
        yearsExperience: yearsExperience,
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
                      "Register as Instructor",
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
                          controller: bioController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.description_outlined, color: Colors.grey),
                            labelText: 'Bio (brief introduction)',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your bio';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: qualificationsController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.school_outlined, color: Colors.grey),
                            labelText: 'Qualifications',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your qualifications';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: expertiseAreasController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.category_outlined, color: Colors.grey),
                            labelText: 'Expertise Areas (e.g., Python, JavaScript)',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your areas of expertise';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: yearsExperienceController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.work_outline, color: Colors.grey),
                            labelText: 'Years of Experience',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter your years of experience';
                            try {
                              int years = int.parse(value);
                              if (years < 0) return 'Years cannot be negative';
                            } catch (e) {
                              return 'Please enter a valid number';
                            }
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
                    onPressed: isLoading ? null : registerInstructor,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up as Instructor", style: TextStyle(fontSize: 15)),
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