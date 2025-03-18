import 'package:hive/hive.dart';

part 'pioneerhub_info.g.dart';

@HiveType(typeId: 0)
class PioneerHubInfo {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String logo;
  @HiveField(4)
  final String address;
  @HiveField(5)
  final String phone;
  @HiveField(6)
  final String website;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final String createdAt;
  @HiveField(9)
  final String updatedAt;

  @HiveField(10)
  final int courses;

  @HiveField(11)
  final int internships;

  @HiveField(12)
  final int projects;

  @HiveField(13)
  final int instructors;

  PioneerHubInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.logo,
    required this.address,
    required this.phone,
    required this.website,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.courses,
    required this.internships,
    required this.projects,
    required this.instructors,
  });

  factory PioneerHubInfo.fromJson(Map<String, dynamic> json) {
    return PioneerHubInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      logo: json['logo'],
      address: json['address'],
      phone: json['phone'],
      website: json['website'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      courses: json['courses'],
      internships: json['internships'],
      projects: json['projects'],
      instructors: json['instructors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'logo': logo,
      'address': address,
      'phone': phone,
      'website': website,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}