import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/controllers/course_controller.dart';
import 'package:pioneerhub_app/models/course.dart';
import 'package:pioneerhub_app/models/payment_response.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/course/course_students_view.dart';
import 'package:pioneerhub_app/views/instructor/instructor_detail.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final CourseController _courseController = CourseController(apiService: ApiService());
  final AuthController _authController = AuthController(apiService: ApiService());
  bool _isLoading = false;
  bool _isRegistered = false;
  bool _isInstructor = false;
  bool _isCurrentInstructorsCourse = false;
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _loadLoggedInUser();
    _checkUserRole();
  }

  Future<void> _loadLoggedInUser() async {
    var box = Hive.box('authBox');
    var userJson = box.get('user');
    if (userJson != null) {
      setState(() {
        _loggedInUser = User.fromJson(Map<String, dynamic>.from(userJson));
      });
    }
  }

  void _checkUserRole() async {
    setState(() {
      _isInstructor = _authController.isInstructor();
    });

    // Check if current instructor is the course instructor
    if (_isInstructor) {
      final user = await _authController.getLoggedInUser();
      if (user != null && user.id == widget.course.instructorId) {
        setState(() {
          _isCurrentInstructorsCourse = true;
        });
      }
    }
  }

  Future<void> _registerForCourse() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return PaymentMethodSheet(
          course: widget.course,
          onPaymentSuccess: () {
            setState(() {
              _isRegistered = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully registered for ${widget.course.title}'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  void _viewCourseStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseStudentsView(
          courseId: widget.course.id,
          courseName: widget.course.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.course.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\Rs. ${widget.course.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '${widget.course.studentCount} students',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Instructor section with "View Students" button for instructors
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instructor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
                                child: Text(
                                  widget.course.instructorName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.course.instructorName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      widget.course.instructorEmail,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isInstructor && _isCurrentInstructorsCourse)
                                ElevatedButton.icon(
                                  icon: Icon(Icons.people, size: 16),
                                  label: Text('View Students'),
                                  onPressed: _viewCourseStudents,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  Text(
                    'About this course',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.course.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Show warning for instructors
                  if (_isInstructor && !_isCurrentInstructorsCourse)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.yellow.shade700),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'As an instructor, you cannot enroll in courses, but you can only view student lists for courses you teach.',
                              style: TextStyle(color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: 32),
                  
                  if (!_isRegistered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerForCourse,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Pay & Register for Course',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Registered for this course',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodSheet extends StatefulWidget {
  final Course course;
  final VoidCallback onPaymentSuccess;

  const PaymentMethodSheet({
    Key? key,
    required this.course,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  _PaymentMethodSheetState createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  final CourseController _courseController = CourseController(apiService: ApiService());
  bool _isLoading = false;
  int _selectedPaymentMethod = 0; // 0 for Khalti, 1 for COD, 2 for Credit/Debit Card

  void _handlePayment() async {
    if (_selectedPaymentMethod == 0) {
      _handleKhaltiPayment();
    } else if (_selectedPaymentMethod == 1) {
      _handleCODPayment();
    } else {
      _handleCardPayment();
    }
  }

  void _handleKhaltiPayment() {
    final config = PaymentConfig(
      amount: (widget.course.price * 100).toInt(), // Converting to paisa (smallest unit)
      productIdentity: widget.course.id.toString(),
      productName: widget.course.title,
      productUrl: "https://pioneerhub.com/courses/${widget.course.id}",
    );

    KhaltiScope.of(context).pay(
      config: config,
      preferences: [
        PaymentPreference.khalti,
      ],
      onSuccess: (PaymentSuccessModel success) {
        _processKhaltiPayment(success);
      },
      onFailure: (PaymentFailureModel failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      onCancel: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }

  void _processKhaltiPayment(PaymentSuccessModel success) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Process payment with Khalti payment token
      final paymentResponse = await _courseController.processKhaltiPayment(
        widget.course.id,
        success.token,
        success.idx,
      );
      
      if (paymentResponse.success) {
        // Call the success callback
        widget.onPaymentSuccess();
        
        // First close the bottom sheet
        Navigator.of(context, rootNavigator: true).pop();
        
        // Then navigate to home and show success message
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          
          // Add a slight delay for snackbar to appear after navigation
          Future.delayed(Duration(milliseconds: 300), () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment successful! You are now registered for the course.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: ${paymentResponse.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process payment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleCODPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cash on Delivery is not available for course registration'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleCardPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Credit/Debit Card payment method coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Course: ${widget.course.title}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            'Price: Rs. ${widget.course.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 20),
          _buildPaymentOption(
            0,
            'Khalti Digital Wallet',
            'Pay securely using Khalti',
            'assets/images/khaltilogo.png',
          ),
       
          _buildPaymentOption(
            2,
            'Credit/Debit Card',
            'Pay with Visa, MasterCard, etc.',
            'assets/images/visa.png',
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      'Proceed to Payment',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, String subtitle, String imageAsset) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPaymentMethod == index
                ? Colors.indigo
                : Colors.grey.shade300,
            width: _selectedPaymentMethod == index ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(
              imageAsset,
              width: 40,
              height: 40,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: index,
              groupValue: _selectedPaymentMethod,
              activeColor: Colors.indigo,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value as int;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}