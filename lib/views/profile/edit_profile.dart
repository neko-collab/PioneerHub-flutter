import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  
  // Role-specific controllers
  // For Instructor
  late TextEditingController _bioController;
  late TextEditingController _qualificationsController;
  late TextEditingController _expertiseAreasController;
  late TextEditingController _yearsExperienceController;
  
  // For Employer
  late TextEditingController _companyNameController;
  late TextEditingController _industryController;
  late TextEditingController _companySizeController;
  late TextEditingController _companyWebsiteController;
  late TextEditingController _companyLocationController;
  late TextEditingController _companyDescriptionController;

  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController(apiService: ApiService());
  bool _isLoading = false;
  String? _errorMessage;
  late User _currentUser;
  Map<String, dynamic>? _instructorData;
  Map<String, dynamic>? _employerData;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    
    // Initialize basic controllers
    _nameController = TextEditingController(text: _currentUser.name);
    _emailController = TextEditingController(text: _currentUser.email);
    
    // Initialize role-specific controllers with empty values initially
    // For Instructor
    _bioController = TextEditingController();
    _qualificationsController = TextEditingController();
    _expertiseAreasController = TextEditingController();
    _yearsExperienceController = TextEditingController();
    
    // For Employer
    _companyNameController = TextEditingController();
    _industryController = TextEditingController();
    _companySizeController = TextEditingController();
    _companyWebsiteController = TextEditingController();
    _companyLocationController = TextEditingController();
    _companyDescriptionController = TextEditingController();
    
    // Fetch additional user data
    _fetchUserData();
  }
  
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUserData = true;
    });
    
    try {
      // We use the profile endpoint to get complete user data
      final response = await _authController.getProfileData();
      
      if (response != null) {
        if (_currentUser.role == 'instructor') {
          setState(() {
            // Match the exact field names from the API response
            _bioController.text = response['bio'] ?? '';
            _qualificationsController.text = response['qualification'] ?? '';
            _expertiseAreasController.text = response['specialization'] ?? '';
            _yearsExperienceController.text = (response['experience_years'] ?? '').toString();
            _instructorData = response;
          });
        } else if (_currentUser.role == 'employer') {
          if (response['company_name'] != null) {
            setState(() {
              _companyNameController.text = response['company_name'] ?? '';
              _industryController.text = response['industry'] ?? '';
              _companySizeController.text = response['company_size'] ?? '';
              _companyWebsiteController.text = response['company_website'] ?? '';
              _companyLocationController.text = response['company_location'] ?? '';
              _companyDescriptionController.text = response['company_description'] ?? '';
              _employerData = response;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile data. Some fields may be empty.'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose basic controllers
    _nameController.dispose();
    _emailController.dispose();
    
    // Dispose role-specific controllers
    // For Instructor
    _bioController.dispose();
    _qualificationsController.dispose();
    _expertiseAreasController.dispose();
    _yearsExperienceController.dispose();
    
    // For Employer
    _companyNameController.dispose();
    _industryController.dispose();
    _companySizeController.dispose();
    _companyWebsiteController.dispose();
    _companyLocationController.dispose();
    _companyDescriptionController.dispose();
    
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Build the update data map based on user role
      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      };
      
      // Add role-specific data
      if (_currentUser.role == 'instructor') {
        updateData['instructor'] = {
          'bio': _bioController.text.trim(),
          'qualification': _qualificationsController.text.trim(),
          'specialization': _expertiseAreasController.text.trim(),
          'experience_years': int.tryParse(_yearsExperienceController.text.trim()) ?? 0,
        };
      } else if (_currentUser.role == 'employer') {
        updateData['employer'] = {
          'company_name': _companyNameController.text.trim(),
          'industry': _industryController.text.trim(),
          'company_size': _companySizeController.text.trim(),
          'company_website': _companyWebsiteController.text.trim(),
          'company_location': _companyLocationController.text.trim(),
          'company_description': _companyDescriptionController.text.trim(),
        };
      }

      final updatedUser = await _authController.updateProfileDetails(updateData);

      if (updatedUser != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Pass back true to indicate successful update
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.indigo),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.indigo))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Decorative header
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo.shade800, Colors.indigo.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Profile Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Update your personal information below',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Basic Information
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    
                    // Conditional role-specific fields
                    if (_currentUser.role == 'instructor') _buildInstructorFields(),
                    if (_currentUser.role == 'employer') _buildEmployerFields(),
                    
                    SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInstructorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructor Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        SizedBox(height: 16),
        
        // Bio field
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Bio',
            prefixIcon: Icon(Icons.person_pin_outlined, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Qualifications field
        TextFormField(
          controller: _qualificationsController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Qualifications',
            prefixIcon: Icon(Icons.school_outlined, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Expertise areas field
        TextFormField(
          controller: _expertiseAreasController,
          decoration: InputDecoration(
            labelText: 'Areas of Expertise',
            prefixIcon: Icon(Icons.lightbulb_outline, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
          
        ),
        SizedBox(height: 16),
        
        // Years of experience field
        TextFormField(
          controller: _yearsExperienceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Years of Experience',
            prefixIcon: Icon(Icons.access_time, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmployerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        SizedBox(height: 16),
        
        // Company name field
        TextFormField(
          controller: _companyNameController,
          decoration: InputDecoration(
            labelText: 'Company Name',
            prefixIcon: Icon(Icons.business, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Industry field
        TextFormField(
          controller: _industryController,
          decoration: InputDecoration(
            labelText: 'Industry',
            prefixIcon: Icon(Icons.category_outlined, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Company size field
        TextFormField(
          controller: _companySizeController,
          decoration: InputDecoration(
            labelText: 'Company Size',
            prefixIcon: Icon(Icons.people_outline, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Company website field
        TextFormField(
          controller: _companyWebsiteController,
          decoration: InputDecoration(
            labelText: 'Company Website',
            prefixIcon: Icon(Icons.language, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Company location field
        TextFormField(
          controller: _companyLocationController,
          decoration: InputDecoration(
            labelText: 'Company Location',
            prefixIcon: Icon(Icons.location_on_outlined, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Company description field
        TextFormField(
          controller: _companyDescriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Company Description',
            prefixIcon: Icon(Icons.description_outlined, color: Colors.indigo),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}