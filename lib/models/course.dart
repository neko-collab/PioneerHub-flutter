class Course {
  final int id;
  final String title;
  final String description;
  final double price;
  final int instructorId;
  final bool isTrending;
  final String createdAt;
  final String instructorName;
  final String instructorEmail;
  final int studentCount;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.instructorId,
    required this.isTrending,
    required this.createdAt,
    required this.instructorName,
    required this.instructorEmail,
    required this.studentCount,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      instructorId: json['instructor_id'],
      isTrending: json['is_trending'] == 1,
      createdAt: json['created_at'],
      instructorName: json['instructor_name'],
      instructorEmail: json['instructor_email'],
      studentCount: json['student_count'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'instructor_id': instructorId,
      'is_trending': isTrending ? 1 : 0,
      'created_at': createdAt,
      'instructor_name': instructorName,
      'instructor_email': instructorEmail,
      'student_count': studentCount,
    };
  }
}