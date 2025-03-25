import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/course_controller.dart';
import 'package:pioneerhub_app/models/course.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final CourseController _courseController = CourseController(apiService: ApiService());
  bool _isEnrolled = false;
  bool _isEnrolling = false;
  User? _loggedInUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadLoggedInUser();
    await _checkEnrollmentStatus();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLoggedInUser() async {
    var box = Hive.box('authBox');
    var userJson = box.get('user');
    if (userJson != null) {
      setState(() {
        _loggedInUser = User.fromJson(Map<String, dynamic>.from(userJson));
      });
    }
  }

  Future<void> _checkEnrollmentStatus() async {
    try {
      if (_loggedInUser == null) return;
      
      // Fetch enrolled courses for the user
      final enrolledCourses = await _courseController.myEnrolledCourses();
      
      // Check if this course is in the enrolled list
      final isEnrolled = enrolledCourses.any((course) => course.id == widget.course.id);
      
      setState(() {
        _isEnrolled = isEnrolled;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking enrollment status: $e')),
      );
    }
  }

  Future<void> _enrollInCourse() async {
    if (_isEnrolled) return;
    
    setState(() {
      _isEnrolling = true;
    });
    
    try {
      await _courseController.registerCourse(widget.course.id);
      setState(() {
        _isEnrolled = true;
        _isEnrolling = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully enrolled in ${widget.course.title}')),
      );
    } catch (e) {
      setState(() {
        _isEnrolling = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enroll: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Padding(padding: EdgeInsets.all(0), child: Text(
                  widget.course.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                ),),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.indigo.shade300,
                            Colors.indigo.shade800,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -50,
                      top: -20,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -50,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildInfoChip(Icons.person, widget.course.instructorName),
                        SizedBox(width: 8),
                        _buildInfoChip(Icons.people, '${widget.course.studentCount} students'),
                        SizedBox(width: 8),
                        if (widget.course.isTrending)
                          _buildInfoChip(Icons.trending_up, 'Trending', Colors.orange),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    Text(
                      'Rs. ${widget.course.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Text(
                      widget.course.description,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildSectionTitle('Instructor'),
                    Card(
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
                                widget.course.instructorName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.course.instructorName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.course.instructorEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 80), // Space for the button
                  ],
                ),
              ),
            ),
          ],
        ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: _loggedInUser == null
            ? ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Login to Enroll', style: TextStyle(fontSize: 16)),
              )
            : _isEnrolled
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Already Enrolled', style: TextStyle(fontSize: 16, color: Colors.white)),
                  )
                : ElevatedButton(
                    onPressed: _isEnrolling ? null : _enrollInCourse,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isEnrolling
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Enroll Now - \$${widget.course.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, [Color color = Colors.indigo]) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: TextStyle(
        color: Colors.white
      ),),
      backgroundColor: color.withValues(
        alpha: 50,
      ),
      labelStyle: TextStyle(color: color),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}