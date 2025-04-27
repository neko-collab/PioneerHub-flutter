import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/models/course.dart';
import 'package:pioneerhub_app/models/payment_response.dart';
import 'dart:convert';
import 'package:hive/hive.dart';

class CourseController {
  final ApiService apiService;

  CourseController({required this.apiService});

  Future<void> addCourse(String title, String description, double price, int instructorId, {bool isTrending = false}) async {
    try {
     
      
      
      final response = await apiService.post('/courses.php', {
        'action': 'addCourse',
        'title': title,
        'description': description,
        'price': price.toString(),
        'instructor_id': instructorId,
        'is_trending': isTrending ? 1 : 0,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to add course: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to add course: $e');
    }
  }

  Future<void> editCourse(int id, String title, String description, double price, int instructorId, {bool isTrending = false}) async {
    try {
     
      
      
      final response = await apiService.post('/courses.php', {
        'action': 'editCourse',
        'id': id,
        'title': title,
        'description': description,
        'price': price.toString(),
        'instructor_id': instructorId,
        'is_trending': isTrending ? 1 : 0,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to edit course: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to edit course: $e');
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
     
      
      
      final response = await apiService.post('/courses.php', {
        'action': 'deleteCourse',
        'id': id,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to delete course: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  Future<Course> viewCourse(int id) async {
    try {
      final response = await apiService.get('/courses.php?action=viewCourse&id=$id');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Course.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to view course: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to view course: $e');
    }
  }

  Future<List<Course>> listCourses() async {
    try {
      final response = await apiService.get('/courses.php');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((course) => Course.fromJson(course))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list courses: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list courses: $e');
    }
  }

  Future<List<Course>> listTrendingCourses() async {
    try {
      final response = await apiService.get('/courses.php?trending=true');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((course) => Course.fromJson(course))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list trending courses: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list trending courses: $e');
    }
  }

  Future<InstructorCoursesResponse> instructorsCourses(int instructorId) async {
    try {
      final response = await apiService.post('/courses.php', {
        'action': 'instructorsCourses',
        'instructor_id': instructorId,
      });
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return InstructorCoursesResponse.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list instructor\'s courses: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list instructor\'s courses: $e');
    }
  }

  Future<void> registerCourse(int courseId) async {
    try {
     
      final response = await apiService.post('/courses.php', {
        'action': 'registerCourse',
        'course_id': courseId,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to register for course: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to register for course: $e');
    }
  }
  
  Future<List<Course>> myEnrolledCourses() async {
    try {
      
      final response = await apiService.post('/courses.php', {
        'action': 'myEnrolledCourses',
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((course) => Course.fromJson(course))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list enrolled courses: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list enrolled courses: $e');
    }
  }

  Future<List<CourseStudent>> courseUsers(int courseId) async {
    try {
      final response = await apiService.post('/courses.php', {
        'action': 'courseUsers',
        'course_id': courseId,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((user) => CourseStudent.fromJson(user))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list course users: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list course users: $e');
    }
  }

  Future<void> toggleVerification(int registrationId, bool verified) async {
    try {
     
      
      
      final response = await apiService.post('/courses.php', {
        'action': 'toggleVerification',
        'registration_id': registrationId,
        'verified': verified ? 1 : 0,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to update verification status: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  Future<CoursePaymentResponse> processKhaltiPayment(int courseId, String token, String transactionId) async {
    try {
      final response = await apiService.post('/courses.php', {
        'action': 'processKhaltiPayment',
        'course_id': courseId,
        'token': token,
        'transaction_id': transactionId,
        'user_id': Hive.box('authBox').get('user')['id'],
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        responseData['success'] = true; // Ensure success is true for the response
        return CoursePaymentResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to process payment: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }
}