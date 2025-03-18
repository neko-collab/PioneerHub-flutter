import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/internship_controller.dart';
import 'package:pioneerhub_app/models/internship.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/internship/internship-detail.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({Key? key}) : super(key: key);

  @override
  _MyApplicationsPageState createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  final InternshipController _internshipController = InternshipController(apiService: ApiService());
  List<InternshipApplication> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final applications = await _internshipController.getMyApplications();
      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading applications: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Applications'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? _buildEmptyState()
              : _buildApplicationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You haven\'t applied to any internships',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Explore Internships'),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return RefreshIndicator(
      onRefresh: _loadApplications,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          final application = _applications[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                try {
                  final internship = await _internshipController.viewInternship(application.internshipId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InternshipDetailPage(internship: internship)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading internship details: $e')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              application.company != null && application.company!.isNotEmpty
                                  ? application.company![0].toUpperCase()
                                  : 'C',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.internshipTitle ?? 'Untitled Internship',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                application.company ?? 'Unknown Company',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildStatusBadge(application.status),
                              SizedBox(height: 8),
                              Text(
                                'Applied on ${_formatDate(application.appliedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData iconData;
    String statusText;

    switch (status.toLowerCase()) {
      case 'approved':
        badgeColor = Colors.green;
        iconData = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'rejected':
        badgeColor = Colors.red;
        iconData = Icons.cancel;
        statusText = 'Rejected';
        break;
      case 'pending':
      default:
        badgeColor = Colors.orange;
        iconData = Icons.hourglass_empty;
        statusText = 'Pending';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: badgeColor),
          SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}