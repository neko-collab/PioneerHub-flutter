class Job {
  final int id;
  final String title;
  final String description;
  final String company;
  final String location;
  final String jobType;
  final int postedBy;
  final String createdAt;
  final String? employerName;
  final String? employerEmail;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.location,
    required this.jobType,
    required this.postedBy,
    required this.createdAt,
    this.employerName,
    this.employerEmail,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      title: json['title'],
      description: json['description'],
      company: json['company'],
      location: json['location'],
      jobType: json['job_type'],
      postedBy: json['posted_by'] is String ? int.parse(json['posted_by']) : json['posted_by'],
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
      'job_type': jobType,
      'posted_by': postedBy,
      'created_at': createdAt,
      'employer_name': employerName,
      'employer_email': employerEmail,
    };
  }
}

class JobApplication {
  final int id;
  final int? userId;
  final int jobId;
  final String appliedAt;
  final String status;
  final String? userName;
  final String? userEmail;
  final String? jobTitle;
  final String? company;
  final String? location;
  final String? jobType;
  final String? cv;
  final String? coverLetter;

  JobApplication({
    required this.id,
    this.userId,
    required this.jobId,
    required this.appliedAt,
    required this.status,
    this.userName,
    this.userEmail,
    this.jobTitle,
    this.company,
    this.location,
    this.jobType,
    this.cv,
    this.coverLetter,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      userId: json['user_id'] != null ? (json['user_id'] is String ? int.parse(json['user_id']) : json['user_id']) : null,
      jobId: json['job_id'] != null 
          ? (json['job_id'] is String ? int.parse(json['job_id']) : json['job_id']) 
          : 0,
      appliedAt: json['applied_at'] ?? '',
      status: json['status'] ?? 'pending',
      userName: json['name'],
      userEmail: json['email'],
      jobTitle: json['title'],
      company: json['company'],
      location: json['location'],
      jobType: json['job_type'],
      cv: json['cv'],
      coverLetter: json['cover_letter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'job_id': jobId,
      'applied_at': appliedAt,
      'status': status,
      'name': userName,
      'email': userEmail,
      'title': jobTitle,
      'company': company,
      'location': location,
      'job_type': jobType,
      'cv': cv,
      'cover_letter': coverLetter,
    };
  }
}