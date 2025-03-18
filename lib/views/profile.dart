import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/auth/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AuthController _authController;
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(apiService: ApiService());
    _loadUser();
  }

  Future<void> _loadUser() async {
    _loggedInUser = await _authController.getLoggedInUser();
    setState(() {});
  }

  Future<void> _logout() async {
    await _authController.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loggedInUser == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _loggedInUser!.name,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(_loggedInUser!.email),
                          SizedBox(height: 8),
                          Text(_loggedInUser!.role),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Logout", style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
      ),
    );
  }
}