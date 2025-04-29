import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/project_controller.dart';
import 'package:pioneerhub_app/models/project.dart';
import 'package:pioneerhub_app/models/user.dart';

class ProjectDetailPage extends StatefulWidget {
  final int projectId;
  
  const ProjectDetailPage({Key? key, required this.projectId}) : super(key: key);

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  Project? _project;
  User? _loggedInUser;
  bool _hasRequestedCollaboration = false;
  bool _isLoading = false;
  bool _isOwner = false;
  List<Collaborator> _collaborationRequests = [];
  bool _loadingRequests = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Use addPostFrameCallback to delay loading project details until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjectDetails();
    });
  }

  Future<void> _loadUserData() async {
    var box = Hive.box('authBox');
    var userJson = box.get('user');
    if (userJson != null) {
      setState(() {
        _loggedInUser = User.fromJson(Map<String, dynamic>.from(userJson));
      });
      
      // After loading user data, load collaboration requests if the user is the owner
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_project != null && _project!.submittedBy == _loggedInUser?.id) {
          _loadCollaborationRequests();
        }
      });
    }
  }

  Future<void> _loadProjectDetails() async {
    final projectController = Provider.of<ProjectController>(context, listen: false);
    
    try {
      // Add debug information
      print('Loading project details for ID: ${widget.projectId}');
      
      final project = await projectController.fetchProjectDetails(widget.projectId);
      
      if (project != null) {
        setState(() {
          _project = project;
          
          // Check if user is the owner
          if (_loggedInUser != null) {
            _isOwner = project.submittedBy == _loggedInUser!.id;
            print('Current user is owner: $_isOwner');
            
            // Check if user has already requested collaboration
            if (project.collaborators != null) {
              _hasRequestedCollaboration = project.collaborators!.any(
                (collaborator) => collaborator.id == _loggedInUser!.id
              );
              print('Has requested collaboration: $_hasRequestedCollaboration');
            }
          }
        });
        
        // Load collaboration requests if the user is the owner
        if (_isOwner) {
          _loadCollaborationRequests();
        }
      } else {
        // Handle error case
        print('Project controller returned null - Error: ${projectController.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading project: ${projectController.error ?? "Unknown error"}')),
        );
      }
    } catch (e) {
      print('Exception in _loadProjectDetails: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading project details: $e')),
      );
    }
  }

  Future<void> _loadCollaborationRequests() async {
    if (!_isOwner || _project == null) return;
    
    setState(() {
      _loadingRequests = true;
    });
    
    final projectController = Provider.of<ProjectController>(context, listen: false);
    
    try {
      print('Loading collaboration requests for project ID: ${_project!.id}');
      final requests = await projectController.fetchCollaborationRequests(_project!.id);
      print('Loaded ${requests.length} collaboration requests');
      
      setState(() {
        _collaborationRequests = requests;
        _loadingRequests = false;
      });
    } catch (e) {
      print('Error loading collaboration requests: $e');
      setState(() {
        _loadingRequests = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading collaboration requests: $e')),
      );
    }
  }

  Future<void> _requestCollaboration() async {
    if (_project == null || _loggedInUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final projectController = Provider.of<ProjectController>(context, listen: false);
    
    try {
      final success = await projectController.requestCollaboration(_project!.id);
      
      if (success) {
        setState(() {
          _hasRequestedCollaboration = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Collaboration request sent successfully')),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(projectController.error ?? 'Failed to request collaboration')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting collaboration: $e')),
      );
    }
  }

  Future<void> _respondToRequest(int requestId, String status) async {
    setState(() {
      _isLoading = true;
    });
    
    final projectController = Provider.of<ProjectController>(context, listen: false);
    
    try {
      final success = await projectController.respondToCollaborationRequest(requestId, status);
      
      if (success) {
        // Reload collaboration requests
        _loadCollaborationRequests();
        // Reload project details to get updated collaborators
        _loadProjectDetails();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $status successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(projectController.error ?? 'Failed to respond to request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error responding to request: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectController = Provider.of<ProjectController>(context);
    
    if (projectController.isLoading && _project == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Project Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_project == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Project Details')),
        body: Center(
          child: Text('Project not found or error loading project'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        actions: _isOwner ? [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit project page
              // You can implement this later
            },
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectHeader(),
            SizedBox(height: 24),
            _buildDescriptionSection(),
            SizedBox(height: 24),
            _buildOwnerSection(),
            SizedBox(height: 24),
            _buildCollaboratorsSection(),
            SizedBox(height: 24),
            if (_isOwner) _buildCollaborationRequestsSection(),
            if (!_isOwner && !_hasRequestedCollaboration) _buildActionButton(),
            if (!_isOwner && _hasRequestedCollaboration) _buildCollaborationStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _project!.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'Created on ${_formatDate(_project!.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 12),
          Text(
            _project!.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Owner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  (_project!.submitterName ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.indigo,
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
                      _project!.submitterName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_project!.submitterEmail != null)
                      Text(
                        _project!.submitterEmail!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (_isOwner)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsSection() {
    final approvedCollaborators = _project!.collaborators?.where((c) => c.status == 'approved').toList() ?? [];
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collaborators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Text(
                '${approvedCollaborators.length} people',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (approvedCollaborators.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No collaborators yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: approvedCollaborators.length,
              itemBuilder: (context, index) {
                final collaborator = approvedCollaborators[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          collaborator.name[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.indigo,
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
                              collaborator.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              collaborator.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loggedInUser != null && collaborator.id == _loggedInUser!.id)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'You',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCollaborationRequestsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collaboration Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 12),
          if (_loadingRequests)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_collaborationRequests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No pending collaboration requests',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _collaborationRequests.length,
              itemBuilder: (context, index) {
                final request = _collaborationRequests[index];
                // Only show pending requests in this section
                if (request.status != 'pending') return SizedBox.shrink();
                
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.indigo.shade50,
                              child: Text(
                                request.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.indigo,
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
                                    request.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    request.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Requested on: ${_formatDate(request.requestedAt ?? "")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _isLoading ? null : () => _respondToRequest(request.requestId!, 'rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: Text('Reject'),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : () => _respondToRequest(request.requestId!, 'approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: Text('Approve'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _requestCollaboration,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              'Request to Collaborate',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildCollaborationStatus() {
    // Find the user's collaboration status
    final userCollaboration = _project!.collaborators?.firstWhere(
      (c) => c.id == _loggedInUser!.id,
      orElse: () => Collaborator(
        id: -1, 
        name: '', 
        email: '', 
        status: 'unknown'
      ),
    );
    
    if (userCollaboration == null) return SizedBox.shrink();
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (userCollaboration.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'You are a collaborator on this project';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Your collaboration request was rejected';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Your collaboration request is pending';
        break;
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
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