import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/job_controller.dart';
import 'package:pioneerhub_app/models/job.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:pioneerhub_app/views/job/job_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class MyJobApplicationsPage extends StatefulWidget {
  const MyJobApplicationsPage({Key? key}) : super(key: key);

  @override
  _MyJobApplicationsPageState createState() => _MyJobApplicationsPageState();
}

class _MyJobApplicationsPageState extends State<MyJobApplicationsPage> {
  final JobController _jobController = JobController(apiService: ApiService());
  List<JobApplication> _applications = [];
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
      final applications = await _jobController.getMyApplications();
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
        title: Text('My Job Applications'),
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
            'You haven\'t applied to any jobs',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
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
                  final job = await _jobController.viewJob(application.jobId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobDetailPage(job: job)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading job details: $e')),
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
                                application.jobTitle ?? 'Untitled Job',
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
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                                  SizedBox(width: 4),
                                  Text(
                                    'Applied on ${_formatDate(application.appliedAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Add CV and Cover Letter preview buttons
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  children: [
                                    if (application.cv != null && application.cv!.isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () => _openFilePreview(application.cv!, 'CV'),
                                        icon: Icon(Icons.document_scanner, size: 16),
                                        label: Text('View CV'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.indigo,
                                          side: BorderSide(color: Colors.indigo.shade300),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    if (application.cv != null && application.cv!.isNotEmpty && 
                                       application.coverLetter != null && application.coverLetter!.isNotEmpty)
                                      SizedBox(width: 8),
                                    if (application.coverLetter != null && application.coverLetter!.isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () => _openFilePreview(application.coverLetter!, 'Cover Letter'),
                                        icon: Icon(Icons.description, size: 16),
                                        label: Text('View Cover Letter'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.deepPurple,
                                          side: BorderSide(color: Colors.deepPurple.shade300),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                  ],
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
      case 'selected':
      case 'accepted':
        badgeColor = Colors.green;
        iconData = Icons.check_circle;
        statusText = 'Selected';
        break;
      case 'rejected':
        badgeColor = Colors.red;
        iconData = Icons.cancel;
        statusText = 'Rejected';
        break;
      case 'interview':
        badgeColor = Colors.blue;
        iconData = Icons.people;
        statusText = 'Interview';
        break;
      case 'reviewed':
        badgeColor = Colors.amber;
        iconData = Icons.visibility;
        statusText = 'Reviewed';
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

  // Method to open file preview in browser
  void _openFilePreview(String filePath, String fileType) async {
    final ApiService apiService = ApiService();
    final fullUrl = '${apiService.baseUrl}$filePath';
    
    try {
      final Uri uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $fileType: $fullUrl')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening $fileType: $e')),
      );
    }
  }
}