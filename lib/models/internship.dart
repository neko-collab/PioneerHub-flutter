class Internship {
  final int id;
  final String title;
  final String description;
  final String company;
  final String location;
  final String internshipType;
  final int postedBy;
  final String createdAt;
  final String? employerName;
  final String? employerEmail;

  Internship({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.internshipType,
    required this.postedBy,
    required this.createdAt,
    this.employerName,
    this.employerEmail,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      company: json['company'],
      location: json['location'],
      internshipType: json['internship_type'],
      postedBy: json['posted_by'],
      createdAt: json['created_at'],
      employerName: json['employer_name'],
      employerEmail: json['employer_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'company': company,
      'location': location,
      'internship_type': internshipType,
      'posted_by': postedBy,
      'created_at': createdAt,
      'employer_name': employerName,
      'employer_email': employerEmail,
    };
  }
}

class InternshipApplication {
  final int id;
  final int? userId;  // Changed to nullable
  final int internshipId;
  final String appliedAt;
  final String status;
  final String? userName;
  final String? userEmail;
  final String? internshipTitle;
  final String? company;
  final String? location;       // Added location
  final String? internshipType; // Added internshipType
  final String? cv;

  InternshipApplication({
    required this.id,
    this.userId,  // Changed to optional
    required this.internshipId,
    required this.appliedAt,
    required this.status,
    this.userName,
    this.userEmail,
    this.internshipTitle,
    this.company,
    this.location,       // Added to constructor
    this.internshipType, // Added to constructor
    this.cv,
  });

  factory InternshipApplication.fromJson(Map<String, dynamic> json) {
    print(json);
    return InternshipApplication(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      userId: json['user_id'] != null ? (json['user_id'] is String ? int.parse(json['user_id']) : json['user_id']) : null,
      internshipId: json['internship_id'] != null 
          ? (json['internship_id'] is String ? int.parse(json['internship_id']) : json['internship_id']) 
          : 0, // Default value if missing
      appliedAt: json['applied_at'] ?? '',
      status: json['status'] ?? 'pending',
      userName: json['name'],
      userEmail: json['email'],
      internshipTitle: json['title'],
      company: json['company'],
      location: json['location'],       // Parse location from JSON
      internshipType: json['internship_type'], // Parse internshipType from JSON
      cv: json['cv'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'internship_id': internshipId,
      'applied_at': appliedAt,
      'status': status,
      'name': userName,
      'email': userEmail,
      'title': internshipTitle,
      'company': company,
      'location': location,
      'internship_type': internshipType,
      'cv': cv,
    };
  }
}