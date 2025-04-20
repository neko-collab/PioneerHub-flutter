import 'package:pioneerhub_app/models/course.dart';

class Instructor {
  final int id;
  final String name;
  final String email;
  final String? profilePic;
  final String createdAt;
  final String? specialization;
  final String? bio;
  final String? qualification;
  final int? experienceYears;
  final List<Course> courses;

  Instructor({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
    required this.createdAt,
    this.specialization,
    this.bio,
    this.qualification,
    this.experienceYears,
    required this.courses,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    List<Course> coursesList = [];
    if (json['courses'] != null) {
      coursesList = List<Course>.from(
        (json['courses'] as List).map((course) => Course.fromJson(course))
      );
    }

    return Instructor(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePic: json['profile_pic'],
      createdAt: json['created_at'],
      specialization: json['specialization'],
      bio: json['bio'],
      qualification: json['qualification'],
      experienceYears: json['experience_years'] != null ? json['experience_years'] : null,
      courses: coursesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_pic': profilePic,
      'created_at': createdAt,
      'specialization': specialization,
      'bio': bio,
      'qualification': qualification,
      'experience_years': experienceYears,
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }
}