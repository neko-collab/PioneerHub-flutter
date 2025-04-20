import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/job_controller.dart';
import 'package:pioneerhub_app/models/job.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/views/job/job_detail.dart';
import 'package:pioneerhub_app/views/job/my_job_applications.dart';

class JobsPage extends StatefulWidget {
  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> with SingleTickerProviderStateMixin {
  final JobController _jobController = JobController(apiService: ApiService());
  late TabController _tabController;
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
    _fetchJobs();
    _searchController.addListener(_filterJobs);
  }

  Future<void> _loadUser() async {
    var box = Hive.box('authBox');
    var userJson = box.get('user');
    if (userJson != null) {
      setState(() {
        _loggedInUser = User.fromJson(Map<String, dynamic>.from(userJson));
      });
    }
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final jobs = await _jobController.listJobs();
      
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load jobs: $e')),
      );
    }
  }

  void _filterJobs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobs = _jobs.where((job) {
        return job.title.toLowerCase().contains(query) ||
               job.description.toLowerCase().contains(query) ||
               job.company.toLowerCase().contains(query) ||
               job.location.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        bottom: _loggedInUser?.role == 'user' 
          ? TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Browse'),
                Tab(text: 'My Applications'),
              ],
            )
          : null,
        actions: [
          if (_loggedInUser != null && (_loggedInUser!.role == 'employer' || _loggedInUser!.role == 'admin'))
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Navigate to add job page
              },
              tooltip: 'Add Job',
            ),
        ],
      ),
      body: _loggedInUser?.role == 'user'
        ? TabBarView(
            controller: _tabController,
            children: [
              _buildJobsTab(),
              MyJobApplicationsPage(),
            ],
          )
        : _buildJobsTab(),
    );
  }

  Widget _buildJobsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Jobs',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16),
          _isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : _filteredJobs.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No jobs found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchJobs,
                        child: ListView.builder(
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            return _buildJobCard(job);
                          },
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailPage(job: job),
            ),
          ).then((_) => _fetchJobs());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: _getJobTypeColor(job.jobType),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _getJobTypeColor(job.jobType).withOpacity(0.2),
                        child: Icon(
                          Icons.business,
                          size: 30,
                          color: _getJobTypeColor(job.jobType),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              job.company,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job.location,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getJobTypeColor(job.jobType),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getJobTypeText(job.jobType),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    job.description,
                    style: TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            _formatDate(job.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      if (_loggedInUser?.role == 'user')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetailPage(job: job),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getJobTypeColor(job.jobType),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('View Details'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getJobTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full-time':
        return Colors.green;
      case 'part-time':
        return Colors.orange;
      case 'contract':
        return Colors.blue;
      case 'freelance':
        return Colors.purple;
      case 'remote':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }

  String _getJobTypeText(String type) {
    return type.toUpperCase();
  }

  String _formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}