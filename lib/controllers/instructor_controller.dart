import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/models/instructor.dart';
import 'dart:convert';

class InstructorController {
  final ApiService apiService;

  InstructorController({required this.apiService});

  Future<Instructor> getInstructorDetails(int instructorId) async {
    try {
      final response = await apiService.post('/instructor.php', {
        'action': 'getInstructorDetails',
        'id': instructorId,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Instructor.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to get instructor details: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to get instructor details: $e');
    }
  }

  Future<List<Instructor>> getAllInstructors() async {
    try {
      final response = await apiService.get('/instructors.php');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<Instructor>.from(
          (responseData['data'] as List).map((data) => Instructor.fromJson(data))
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list instructors: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list instructors: $e');
    }
  }

  Future<void> updateInstructorProfile(String specialization, String bio, String qualification, int experienceYears) async {
    try {
      final response = await apiService.post('/instructors.php', {
        'action': 'updateProfile',
        'specialization': specialization,
        'bio': bio,
        'qualification': qualification,
        'experience_years': experienceYears,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to update instructor profile: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to update instructor profile: $e');
    }
  }
}