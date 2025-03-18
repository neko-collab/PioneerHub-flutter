import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/course_controller.dart';
import 'package:pioneerhub_app/models/course.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/course/course_detail.dart';

class MyCoursesPage extends StatefulWidget {
  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  final CourseController _courseController = CourseController(apiService: ApiService());
  List<Course> _enrolledCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final courses = await _courseController.myEnrolledCourses();
      
      setState(() {
        _enrolledCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load enrolled courses: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Courses'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _enrolledCourses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'You haven\'t enrolled in any courses yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Browse Courses'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchEnrolledCourses,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: _enrolledCourses.length,
                      itemBuilder: (context, index) {
                        final course = _enrolledCourses[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailPage(course: course),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.indigo.shade100,
                                    child: Text(
                                      course.title[0].toUpperCase(),
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                                    ),
                                  ),
                                  title: Text(
                                    course.title,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Instructor: ${course.instructorName}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Description:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        course.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Enrolled',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CourseDetailPage(course: course),
                                            ),
                                          );
                                        },
                                        child: Text('View Details'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}