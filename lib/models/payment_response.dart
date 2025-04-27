class CoursePaymentResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String? courseId;

  CoursePaymentResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.courseId,
  });

  factory CoursePaymentResponse.fromJson(Map<String, dynamic> json) {
    return CoursePaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown response',
      transactionId: json['transaction_id'],
      courseId: json['course_id'],
    );
  }
}
