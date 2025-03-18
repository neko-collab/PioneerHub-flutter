import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/controllers/pioneerhub_info_controller.dart';
import 'package:pioneerhub_app/controllers/course_controller.dart';
import 'package:pioneerhub_app/models/pioneerhub_info.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/models/course.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/course/course_detail.dart';
import 'package:pioneerhub_app/views/course/my-courses.dart';
import 'package:pioneerhub_app/views/course/courses.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthController _authController;
  late PioneerHubInfoController _pioneerHubInfoController;
  late CourseController _courseController;
  User? _loggedInUser;
  PioneerHubInfo? _pioneerHubInfo;
  List<Course> _trendingCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(apiService: ApiService());
    _pioneerHubInfoController = PioneerHubInfoController(apiService: ApiService());
    _courseController = CourseController(apiService: ApiService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load user data
      _loggedInUser = await _authController.getLoggedInUser();
      
      // Load platform info
      await _pioneerHubInfoController.fetchAndSavePioneerHubInfo();
      var box = Hive.box('pioneerHubInfoBox');
      var infoList = box.get('pioneerHubInfo') as List<dynamic>?;
      if (infoList != null && infoList.isNotEmpty) {
        _pioneerHubInfo = infoList.first as PioneerHubInfo;
      }
      
      // Load trending courses
      _trendingCourses = await _courseController.listTrendingCourses();
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_loggedInUser != null)
                          _buildUserCard(),
                        
                        const SizedBox(height: 24),
                        Text(
                          "Platform Statistics",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_pioneerHubInfo != null)
                          _buildPlatformStats(),
                          
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Trending Courses",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.indigo,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => CoursesPage())
                                );
                              },
                              child: Text("See All"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildTrendingCourses(),
                        
                        const SizedBox(height: 24),
                        Text(
                          "Quick Actions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade800, Colors.indigo.shade500],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              Text(
                _pioneerHubInfo?.name ?? "PioneerHub",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _pioneerHubInfo?.description ?? "Loading platform information...",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                _loggedInUser!.name[0].toUpperCase(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _loggedInUser!.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(_loggedInUser!.email),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(_loggedInUser!.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleDisplay(_loggedInUser!.role),
                      style: TextStyle(
                        color: _getRoleColor(_loggedInUser!.role),
                        fontWeight: FontWeight.w500,
                      ),
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
    // Capitalize first letter of role
    return role[0].toUpperCase() + role.substring(1);
  }

  Widget _buildPlatformStats() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(Icons.book_outlined, "Courses", _pioneerHubInfo!.courses.toString()),
            SizedBox(width: 16),
            _buildStatCard(Icons.work_outlined, "Internships", _pioneerHubInfo!.internships.toString()),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(Icons.build_outlined, "Projects", _pioneerHubInfo!.projects.toString()),
            SizedBox(width: 16),
            _buildStatCard(Icons.person_outlined, "Instructors", _pioneerHubInfo!.instructors.toString()),
          ],
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              _buildDetailItem(Icons.location_on_outlined, "Address", _pioneerHubInfo!.address),
              Divider(height: 1, indent: 56),
              _buildDetailItem(Icons.phone_outlined, "Phone", _pioneerHubInfo!.phone),
              Divider(height: 1, indent: 56),
              _buildDetailItem(Icons.web_outlined, "Website", _pioneerHubInfo!.website),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.indigo),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCourses() {
    if (_trendingCourses.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No trending courses available",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingCourses.length,
        itemBuilder: (context, index) {
          final course = _trendingCourses[index];
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailPage(course: course),
                    ),
                  ).then((_) => _loadData());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(
                                  course.title[0].toUpperCase(),
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_up, size: 12, color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text(
                                      'Trending',
                                      style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            course.title,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            course.description,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs. ${course.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.people, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    '${course.studentCount}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'By ${course.instructorName}',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionCard(
          Icons.school,
          "My Courses",
          "View courses you've enrolled in",
          () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => MyCoursesPage())
          ),
        ),
        SizedBox(height: 12),
        _buildActionCard(
          Icons.search,
          "Browse All Courses",
          "Discover new learning opportunities",
          () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => CoursesPage())
          ),
        ),
        SizedBox(height: 12),
        if (_loggedInUser?.role == 'instructor')
          _buildActionCard(
            Icons.add_circle_outline,
            "Create a Course",
            "Start teaching your expertise",
            () {
              // Navigate to course creation page
            },
          ),
        if (_loggedInUser?.role == 'employer')
          _buildActionCard(
            Icons.work_outline,
            "Post an Internship",
            "Find talented students for your company",
            () {
              // Navigate to internship posting page
            },
          ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.indigo),
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
                      subtitle,
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