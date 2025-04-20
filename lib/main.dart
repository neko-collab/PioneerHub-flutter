import 'package:flutter/material.dart';
import 'package:pioneerhub_app/models/pioneerhub_info.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/views/auth/change_password.dart';
import 'package:pioneerhub_app/views/auth/checkotp.dart';
import 'package:pioneerhub_app/views/auth/forgot_password.dart';
import 'package:pioneerhub_app/views/auth/login.dart';
import 'package:pioneerhub_app/views/auth/register-admin.dart';
import 'package:pioneerhub_app/views/auth/register-employer.dart';
import 'package:pioneerhub_app/views/auth/register-instructor.dart';
import 'package:pioneerhub_app/views/auth/register-select.dart';
import 'package:pioneerhub_app/views/auth/register.dart';
import 'package:pioneerhub_app/views/course/course_detail.dart';
import 'package:pioneerhub_app/views/course/courses.dart';
import 'package:pioneerhub_app/views/home.dart';
import 'package:pioneerhub_app/views/internship/internship-detail.dart';
import 'package:pioneerhub_app/views/internship/internships.dart';
import 'package:pioneerhub_app/views/internship/my-applications.dart';
import 'package:pioneerhub_app/views/job/job_detail.dart';
import 'package:pioneerhub_app/views/job/jobs.dart';
import 'package:pioneerhub_app/views/job/my_job_applications.dart';
import 'package:pioneerhub_app/views/profile.dart';
import 'package:pioneerhub_app/views/project/projects.dart';
import 'package:pioneerhub_app/views/project/project_detail.dart';
import 'package:provider/provider.dart';
import 'package:pioneerhub_app/controllers/user_controller.dart';
import 'package:pioneerhub_app/controllers/project_controller.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PioneerHubInfoAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('authBox');
  await Hive.openBox('pioneerHubInfoBox');
  runApp(PioneerApp());
}

class PioneerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserController(apiService: ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectController(apiService: ApiService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PioneerHub',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        initialRoute: '/',
        routes: {
          // Auth routes
          '/': (context) => LoginPage(),
          '/register': (context) => SignUpPage(),
          '/register-select': (context) => RegisterSelectPage(),
          '/register-instructor': (context) => RegisterInstructorPage(),
          '/register-employer': (context) => RegisterEmployerPage(),
          '/register-admin': (context) => RegisterAdminPage(),
          '/forgot_password': (context) => ForgotPasswordPage(),

          // Main app routes
          '/home': (context) => MainScreen(),
          '/profile': (context) => ProfilePage(),

          // Course routes
          '/courses': (context) => CoursesPage(),
          
          // Internship routes
          '/internships': (context) => InternshipsPage(),
          '/my-applications': (context) => MyApplicationsPage(),
          
          // Job routes
          '/jobs': (context) => JobsPage(),
          '/my-job-applications': (context) => MyJobApplicationsPage(),
        },
        // Use onGenerateRoute for routes that need parameters
        onGenerateRoute: (settings) {
          if (settings.name == '/course-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CourseDetailPage(
                course: args['course'],
              ),
            );
          } else if (settings.name == '/internship-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => InternshipDetailPage(
                internship: args['internship'],
              ),
            );
          } else if (settings.name == '/change_password') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ChangePasswordPage(
                email: args['email'],
                otp: args['otp'],
              ),
            );
          } else if (settings.name == '/checkotp') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                email: args['email'],
              ),
            );
          } else if (settings.name == '/job-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => JobDetailPage(
                job: args['job'],
              ),
            );
          } else if (settings.name == '/project-detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ProjectDetailPage(
                projectId: args['projectId'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    CoursesPage(),
    InternshipsPage(),
    JobsPage(),
    ProjectsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Add this line for more than 3 items
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Internships',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;

  PlaceholderWidget(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
