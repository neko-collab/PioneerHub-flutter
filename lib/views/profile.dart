import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/auth/login.dart';
import 'package:pioneerhub_app/views/course/courses.dart';
import 'package:pioneerhub_app/views/course/instructor_courses_view.dart';
import 'package:pioneerhub_app/views/internship/internships.dart';
import 'package:pioneerhub_app/views/job/jobs.dart';
import 'package:pioneerhub_app/views/profile/change_password_page.dart';
import 'package:pioneerhub_app/views/profile/edit_profile.dart';
import 'package:pioneerhub_app/views/project/projects.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AuthController _authController;
  User? _loggedInUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(apiService: ApiService());
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      _loggedInUser = await _authController.getLoggedInUser();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _authController.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void _navigateToApplications(BuildContext context, int tabIndex, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    ).then((_) {
      // You can perform any refresh logic here if needed
    });
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'instructor':
        return Colors.blue;
      case 'employer':
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  String _getRoleDisplay(String role) {
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.indigo))
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.indigo.shade800, Colors.indigo.shade500],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -20,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -50,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _loggedInUser == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Please log in to view your profile',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildProfileHeader(),
                        SizedBox(height: 24),
                        _buildSectionTitle('Account Settings'),
                        _buildSettingTile(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                        _buildSettingTile(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(user: _loggedInUser!),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        _buildSectionTitle('My Applications'),
                        _buildApplicationTile(
                          icon: Icons.work_outline,
                          title: 'My Internship Applications',
                          color: Colors.blue,
                          onTap: () {
                            if (_loggedInUser!.role == 'user') {
                              _navigateToApplications(context, 1, InternshipsPage());
                            }
                          },
                        ),
                        _buildApplicationTile(
                          icon: Icons.business_center_outlined,
                          title: 'My Job Applications',
                          color: Colors.green,
                          onTap: () {
                            if (_loggedInUser!.role == 'user') {
                              _navigateToApplications(context, 1, JobsPage());
                            }
                          },
                        ),
                        _buildApplicationTile(
                          icon: Icons.school_outlined,
                          title: 'My Enrolled Courses',
                          color: Colors.orange,
                          onTap: () {
                            _navigateToApplications(context, 2, CoursesPage());
                          },
                        ),
                        if (_loggedInUser!.role == 'user')
                          _buildApplicationTile(
                            icon: Icons.build_outlined,
                            title: 'My Projects',
                            color: Colors.purple,
                            onTap: () {
                              _navigateToApplications(context, 1, ProjectsPage());
                            },
                          ),
                        if (_loggedInUser!.role == 'instructor')
                          _buildApplicationTile(
                            icon: Icons.menu_book_outlined,
                            title: 'My Teaching Courses',
                            color: Colors.blue,
                            onTap: () {
                              _navigateToApplications(context, 1, InstructorCoursesView());
                            },
                          ),
                        SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.red.shade200),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 8),
                                Text(
                                  "Logout",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
              ),
            ],
          ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.indigo.shade100,
            child: Text(
              _loggedInUser!.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loggedInUser!.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _loggedInUser!.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(_loggedInUser!.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getRoleColor(_loggedInUser!.role).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getRoleDisplay(_loggedInUser!.role),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRoleColor(_loggedInUser!.role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo.shade800,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.indigo),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildApplicationTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}