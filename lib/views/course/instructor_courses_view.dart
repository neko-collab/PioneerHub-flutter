import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/course_controller.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/models/course.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/views/course/course_students_view.dart';

class InstructorCoursesView extends StatefulWidget {
  const InstructorCoursesView({Key? key}) : super(key: key);

  @override
  State<InstructorCoursesView> createState() => _InstructorCoursesViewState();
}

class _InstructorCoursesViewState extends State<InstructorCoursesView> {
  late CourseController _courseController;
  late AuthController _authController;
  Future<InstructorCoursesResponse>? _instructorCoursesFuture;
  int? _instructorId;
  bool _isLoading = true;
  bool _isInstructor = false;

  @override
  void initState() {
    super.initState();
    _courseController = CourseController(apiService: ApiService());
    _authController = AuthController(apiService: ApiService());
    _checkInstructorAndLoadData();
  }

  Future<void> _checkInstructorAndLoadData() async {
    setState(() {
      _isLoading = true;
      _isInstructor = _authController.isInstructor();
    });

    if (!_isInstructor) {
      setState(() {
        _isLoading = false;
      });
      // Show error that user is not an instructor
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be an instructor to access this page')),
        );
        Navigator.pop(context); // Return to previous screen
      });
      return;
    }

    await _loadInstructorId();
  }

  Future<void> _loadInstructorId() async {
    final box = await Hive.openBox('authBox');
    final userData = box.get('user');
    
    if (userData != null && userData['id'] != null) {
      setState(() {
        _instructorId = userData['id'];
        _isLoading = false;
      });
      _loadInstructorCourses();
    } else {
      setState(() {
        _isLoading = false;
      });
      // Show error that user is not logged in or not an instructor
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found or not an instructor')),
      );
    }
  }

  Future<void> _loadInstructorCourses() async {
    if (_instructorId != null) {
      setState(() {
        _instructorCoursesFuture = _courseController.instructorsCourses(_instructorId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Teaching Courses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _instructorId == null || !_isInstructor
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 70, color: Colors.indigo.withOpacity(0.7)),
                        const SizedBox(height: 16),
                        const Text(
                          'Please login as an instructor to view your courses',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInstructorCourses,
                  color: Colors.indigo,
                  child: _buildCoursesList(),
                ),
    );
  }

  Widget _buildCoursesList() {
    return FutureBuilder<InstructorCoursesResponse>(
      future: _instructorCoursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.indigo));
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: Colors.red.withOpacity(0.7)),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadInstructorCourses,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.courses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 70, color: Colors.indigo.withOpacity(0.7)),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first course using the + button below',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          final courses = snapshot.data!.courses;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => CourseStudentsView(courseId: course.id, courseName: course.title),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            size: 40,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    course.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    'Rs. ${course.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.blue.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${course.studentCount} Students',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                               
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.people, size: 16, color: Colors.white,),
                                  label: const Text('Students'),
                                  onPressed: () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context) => CourseStudentsView(courseId: course.id, courseName: course.title),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}