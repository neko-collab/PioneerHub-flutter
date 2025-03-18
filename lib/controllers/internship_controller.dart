import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/models/internship.dart';
import 'dart:convert';
import 'package:hive/hive.dart';

class InternshipController {
  final ApiService apiService;

  InternshipController({required this.apiService});

  Future<List<Internship>> listInternships() async {
    try {
      final response = await apiService.get('/internship.php');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((internship) => Internship.fromJson(internship))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list internships: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list internships: $e');
    }
  }

  Future<Internship> viewInternship(int id) async {
    try {

      final response = await apiService.post('/internship.php', {
        'action': 'viewInternship',
        'id': id,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Internship.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to view internship: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to view internship: $e');
    }
  }

  Future<void> addInternship(String title, String description, String company, String location, String internshipType) async {
    try {
      final response = await apiService.post('/internship.php', {
        'action': 'addInternship',
        'title': title,
        'description': description,
        'company': company,
        'location': location,
        'internship_type': internshipType,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to add internship: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to add internship: $e');
    }
  }

  Future<void> editInternship(int id, {String? title, String? description, String? company, String? location, String? internshipType}) async {
    try {
      final Map<String, dynamic> requestData = {
        'action': 'editInternship',
        'id': id,
      };
      
      if (title != null) requestData['title'] = title;
      if (description != null) requestData['description'] = description;
      if (company != null) requestData['company'] = company;
      if (location != null) requestData['location'] = location;
      if (internshipType != null) requestData['internship_type'] = internshipType;
      
      final response = await apiService.post('/internship.php', requestData);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to edit internship: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to edit internship: $e');
    }
  }

  Future<void> deleteInternship(int id) async {
    try {
     final response = await apiService.post('/internship.php', {
        'action': 'deleteInternship',
        'id': id,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to delete internship: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to delete internship: $e');
    }
  }

  Future<void> applyInternship(int internshipId) async {
    try {
      var box = Hive.box('authBox');
      String? token = box.get('token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }
      
      final response = await apiService.post('/internship.php', {
        'action': 'applyInternship',
        'internship_id': internshipId,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to apply for internship: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to apply for internship: $e');
    }
  }

  Future<List<Map<String, dynamic>>> internshipApplications(int internshipId) async {
    try {
       
      final response = await apiService.post('/internship.php', {
        'action': 'internshipApplications',
        'internship_id': internshipId,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to fetch applications: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to fetch applications: $e');
    }
  }

  Future<void> toggleApplicationStatus(int applicationId, String status) async {
    try {
         
      final response = await apiService.post('/internship.php', {
        'action': 'toggleApplicationStatus',
        'application_id': applicationId,
        'status': status,
      });

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to update application status: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }

  Future<List<InternshipApplication>> myApplications() async {
    try {
           
      final response = await apiService.post('/internship.php', {
        'action': 'myApplications',
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((application) => InternshipApplication.fromJson(application))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to fetch my applications: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to fetch my applications: $e');
    }
  }

  getMyApplications() {}
}