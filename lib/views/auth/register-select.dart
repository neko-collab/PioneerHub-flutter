import 'package:flutter/material.dart';
import 'package:pioneerhub_app/views/auth/login.dart';
import 'package:pioneerhub_app/views/auth/register.dart';
import 'package:pioneerhub_app/views/auth/register-instructor.dart';


class RegisterSelectPage extends StatelessWidget {
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
                      "Choose Registration Type",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildRegistrationOption(
                    context,
                    "Student",
                    Icons.school,
                    "Register as a student to enroll in courses",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage())),
                  ),
                  const SizedBox(height: 15),
                  _buildRegistrationOption(
                    context,
                    "Instructor",
                    Icons.person_2,
                    "Register as an instructor to teach courses",
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterInstructorPage())),
                  ),
                  const SizedBox(height: 25),
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
                        const Text("Already have an account? ",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)),
                        GestureDetector(
                          child: const Text("Login",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo)),
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationOption(
      BuildContext context, String title, IconData iconData, String description, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(iconData, size: 40, color: Colors.indigo),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }
}