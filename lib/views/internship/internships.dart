import 'package:flutter/material.dart';
import 'package:pioneerhub_app/controllers/internship_controller.dart';
import 'package:pioneerhub_app/models/internship.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/views/internship/internship-detail.dart';
import 'package:pioneerhub_app/views/internship/my-applications.dart';

class InternshipsPage extends StatefulWidget {
  @override
  _InternshipsPageState createState() => _InternshipsPageState();
}

class _InternshipsPageState extends State<InternshipsPage> {
  final InternshipController _internshipController = InternshipController(apiService: ApiService());
  List<Internship> _internships = [];
  List<Internship> _filteredInternships = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchInternships();
    _searchController.addListener(_filterInternships);
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

  Future<void> _fetchInternships() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final internships = await _internshipController.listInternships();
      
      setState(() {
        _internships = internships;
        _filteredInternships = internships;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load internships: $e')),
      );
    }
  }

  void _filterInternships() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredInternships = _internships.where((internship) {
        return internship.title.toLowerCase().contains(query) ||
               internship.description.toLowerCase().contains(query) ||
               internship.company.toLowerCase().contains(query) ||
               internship.location.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internships'),
        actions: [
          if (_loggedInUser != null && _loggedInUser!.role == 'user')
            IconButton(
              icon: Icon(Icons.assignment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApplicationsPage()),
                ).then((_) => _fetchInternships());
              },
              tooltip: 'My Applications',
            ),
          if (_loggedInUser != null && (_loggedInUser!.role == 'employer' || _loggedInUser!.role == 'admin'))
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Navigate to add internship page
                // This is a placeholder and should be implemented in a separate file
              },
              tooltip: 'Add Internship',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Internships',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : _filteredInternships.isEmpty
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
                                'No internships found',
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
                          onRefresh: _fetchInternships,
                          child: ListView.builder(
                            itemCount: _filteredInternships.length,
                            itemBuilder: (context, index) {
                              final internship = _filteredInternships[index];
                              return _buildInternshipCard(internship);
                            },
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternshipCard(Internship internship) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InternshipDetailPage(internship: internship),
            ),
          ).then((_) => _fetchInternships());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: _getInternshipTypeColor(internship.internshipType),
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
                        backgroundColor: _getInternshipTypeColor(internship.internshipType).withOpacity(0.2),
                        child: Icon(
                          Icons.business,
                          size: 30,
                          color: _getInternshipTypeColor(internship.internshipType),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              internship.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              internship.company,
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
                                    internship.location,
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
                          color: _getInternshipTypeColor(internship.internshipType),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getInternshipTypeText(internship.internshipType),
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
                    internship.description,
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
                            _formatDate(internship.createdAt),
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
                                builder: (context) => InternshipDetailPage(internship: internship),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getInternshipTypeColor(internship.internshipType),
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

  Color _getInternshipTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.orange;
      case 'remote':
        return Colors.blue;
      case 'hybrid':
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }

  String _getInternshipTypeText(String type) {
    return type.toUpperCase();
  }

  String _formatDate(String dateString) {
    // Format date from 2025-02-15 18:47:59 to a more readable format
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