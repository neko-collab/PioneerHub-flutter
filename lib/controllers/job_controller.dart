import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pioneerhub_app/models/job.dart';
import 'package:pioneerhub_app/services/api_service.dart';

class JobController {
  final ApiService apiService;

  JobController({required this.apiService});

  Future<List<Job>> listJobs() async {
    try {
      final response = await apiService.get('/jobs.php');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to list jobs: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to list jobs: $e');
    }
  }

  Future<Job> viewJob(int id) async {
    try {
      final response = await apiService.post('/jobs.php', {
        'action': 'viewJob',
        'id': id,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Job.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to view job: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to view job: $e');
    }
  }

  Future<void> applyJob(int jobId, {File? cvFile, String? coverLetter}) async {
    try {
      var box = Hive.box('authBox');
      String? token = box.get('token');
      
      if (token == null) {
        throw Exception('User not logged in');
      }
      
      if (cvFile != null) {
        // Handle file upload
        var uri = Uri.parse('${apiService.baseUrl}/jobs.php');
        
        var request = http.MultipartRequest('POST', uri);
        
        // Add authorization header
        request.headers['authorization'] = 'Bearer $token';
        
        // Add form fields
        request.fields['action'] = 'applyJob';
        request.fields['job_id'] = jobId.toString();
        if (coverLetter != null) {
          request.fields['cover_letter'] = coverLetter;
        }
        
        // Add file
        var stream = http.ByteStream(cvFile.openRead());
        var length = await cvFile.length();
        var multipartFile = http.MultipartFile(
          'cv', 
          stream, 
          length,
          filename: cvFile.path.split('/').last
        );
        request.files.add(multipartFile);
        // Send request
        var response = await request.send();
        
        if (response.statusCode != 200) {
          final responseBody = await response.stream.bytesToString();
          final errorData = jsonDecode(responseBody);
          throw Exception('Failed to apply for job: ${errorData['message']}');
        }
      } else {
        // Simple application without CV
        final response = await apiService.post('/jobs.php', {
          'action': 'applyJob',
          'job_id': jobId,
          if (coverLetter != null) 'cover_letter': coverLetter,
        });
        print(response.body);
        if (response.statusCode != 200) {
          final errorData = jsonDecode(response.body);
          throw Exception('Failed to apply for job: ${errorData['message']}');
        }
      }
    } catch (e) {
      throw Exception('Failed to apply for job: $e');
    }
  }

  Future<List<Map<String, dynamic>>> jobApplications(int jobId) async {
    try {
      final response = await apiService.post('/jobs.php', {
        'action': 'jobApplications',
        'job_id': jobId,
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
      final response = await apiService.post('/jobs.php', {
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

  Future<List<JobApplication>> getMyApplications() async {
    try {
      final response = await apiService.post('/jobs.php', {
        'action': 'myApplications',
      });
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['data'] as List)
            .map((application) => JobApplication.fromJson(application))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to fetch my applications: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to fetch my applications: $e');
    }
  }
}