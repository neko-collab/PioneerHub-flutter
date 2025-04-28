import 'package:hive/hive.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'dart:convert';

class AuthController {
  final ApiService apiService;

  AuthController({required this.apiService});

  Future<User?> login(String email, String password) async {
    try {
      final response = await apiService.post('/auth.php', {
        'action': 'login',
        'email': email,
        'password': password,
      });

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
      
      final data = responseData['data'];
      final token = data['token'];
      final user = User.fromJson(data['user']);

      // Save token to Hive
      var box = Hive.box('authBox');
      await box.put('token', token);
      await box.put('user', user.toJson());

      return user;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<User?> register(String name, String email, String password, {String role = 'user'}) async {
    try {
      final response = await apiService.post('/auth.php', {
        'action': 'register',
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
      
      final data = responseData['data'];
      final token = data['token'];
      final user = User.fromJson(data['user']);

      // Save token to Hive
      var box = Hive.box('authBox');
      await box.put('token', token);
      await box.put('user', user.toJson());

      return user;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<User?> registerInstructor(
    String name, 
    String email, 
    String password, 
    String bio, 
    String qualifications, 
    {String expertiseAreas = '', int yearsExperience = 0}
  ) async {
    try {
      final response = await apiService.post('/auth.php', {
        'action': 'registerInstructor',
        'name': name,
        'email': email,
        'password': password,
        'bio': bio,
        'qualification': qualifications,
        'specialization': expertiseAreas,
        'experience_years': yearsExperience,
      });

      final responseData = jsonDecode(response.body);
      print(responseData);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
      
      // Check if data and token exist
      if (responseData['data'] != null && responseData['data']['token'] != null) {
        final data = responseData['data'];
        final token = data['token'];
        final user = User.fromJson(data['user']);

        // Save token to Hive
        var box = Hive.box('authBox');
        await box.put('token', token);
        await box.put('user', user.toJson());

        return user;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to register as instructor: $e');
    }
  }

  Future<User?> registerEmployer(
    String name, 
    String email, 
    String password, 
    String companyName, 
    String industry,
    {String companySize = '', 
     String companyWebsite = '', 
     String companyLocation = '', 
     String companyDescription = ''}
  ) async {
    try {
      final response = await apiService.post('/auth.php', {
        'action': 'registerEmployer',
        'name': name,
        'email': email,
        'password': password,
        'company_name': companyName,
        'industry': industry,
        'company_size': companySize,
        'company_website': companyWebsite,
        'company_location': companyLocation,
        'company_description': companyDescription,
      });

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
      
      // Check if data and token exist
      if (responseData['data'] != null && responseData['data']['token'] != null) {
        final data = responseData['data'];
        final token = data['token'];
        final user = User.fromJson(data['user']);

        // Save token to Hive
        var box = Hive.box('authBox');
        await box.put('token', token);
        await box.put('user', user.toJson());

        return user;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to register as employer: $e');
    }
  }

  Future<User?> registerAdmin(
    String name, 
    String email, 
    String password, 
    String accessReason,
    {int? grantedBy, String accessLevel = 'standard'}
  ) async {
    try {
      final Map<String, dynamic> requestData = {
        'action': 'registerAdmin',
        'name': name,
        'email': email,
        'password': password,
        'access_reason': accessReason,
        'access_level': accessLevel,
      };

      // Only add grantedBy if it's not null
      if (grantedBy != null) {
        requestData['granted_by'] = grantedBy;
      }

      final response = await apiService.post('/auth.php', requestData);

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
      
      // Check if data and token exist
      if (responseData['data'] != null && responseData['data']['token'] != null) {
        final data = responseData['data'];
        final token = data['token'];
        final user = User.fromJson(data['user']);

        // Save token to Hive
        var box = Hive.box('authBox');
        await box.put('token', token);
        await box.put('user', user.toJson());

        return user;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to register as admin: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await apiService.post('/auth.php', {
        'action': 'forgotPassword',
        'email': email,
      });

      final responseData = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    try {
      final response = await apiService.post('/auth.php', {
        'action': 'verifyOTP',
        'email': email,
        'otp': otp,
      });

      final responseData = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<void> changePassword(String email, String otp, String newPassword) async {
    try {
      final response = await apiService.post('/auth.php', {
        'action': 'changePassword',
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      });

      final responseData = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
  
  Future<User?> updateProfileDetails(Map<String, dynamic> userData) async {
    try {
      final response = await apiService.post('/profile.php', {
        'action': 'updateProfile',
        ...userData,
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
      
      // Update the stored user data
      if (responseData['data'] != null) {
        final user = User.fromJson(responseData['data']);
        var box = Hive.box('authBox');
        await box.put('user', user.toJson());
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changeUserPassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      final response = await apiService.post('/profile.php', {
        'action': 'changePassword',
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    var box = Hive.box('authBox');
    return box.get('token') != null;
  }

  Future<User?> getLoggedInUser() async {
    var box = Hive.box('authBox');
    var userJson = box.get('user');
    if (userJson != null) {
      return User.fromJson(Map<String, dynamic>.from(userJson));
    }
    return null;
  }

  Future<void> logout() async {
    try {
      var box = Hive.box('authBox');
      String? token = box.get('token');
      
      if (token != null) {
        // Clear local storage regardless of server response
      await box.clear();
      }
      
      
    } catch (e) {
      // Even if server request fails, clear local storage
      var box = Hive.box('authBox');
      await box.clear();
      throw Exception('Error during logout: $e');
    }
  }

  bool isInstructor() {
    var box = Hive.box('authBox');
    var user = box.get('user');
    if (user != null) {
      return user['role'] == 'instructor';
    }
    return false;
  }
  
  Future<String?> getAuthToken() async {
    var box = Hive.box('authBox');
    return box.get('token') as String?;
  }

  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      final response = await apiService.get('/profile.php?id=${Hive.box('authBox').get('user')['id']}', token: await getAuthToken());
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(responseData['message']);
      }
      
      return responseData['data'];
    } catch (e) {
      throw Exception('Failed to fetch profile data: $e');
    }
  }
}