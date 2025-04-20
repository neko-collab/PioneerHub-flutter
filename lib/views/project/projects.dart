import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:pioneerhub_app/controllers/project_controller.dart';
import 'package:pioneerhub_app/models/project.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/views/project/project_detail.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _loggedInUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreatingProject = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _searchController.addListener(_onSearchChanged);
    
    // Fetch projects when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProjects();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadUserData() async {
    var box = Hive.box('authBox');
    var userJson = box.get('user');
    if (userJson != null) {
      setState(() {
        _loggedInUser = User.fromJson(Map<String, dynamic>.from(userJson));
      });
    }
  }

  Future<void> _refreshProjects() async {
    final projectController = Provider.of<ProjectController>(context, listen: false);
    await projectController.fetchProjects();
    await projectController.fetchUserProjects();
    await projectController.fetchCollaboratingProjects();
  }

  List<Project> _getFilteredProjects(List<Project> projects) {
    if (_searchQuery.isEmpty) return projects;
    
    return projects.where((project) {
      return project.title.toLowerCase().contains(_searchQuery) ||
             project.description.toLowerCase().contains(_searchQuery) ||
             (project.submitterName?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  void _showCreateProjectDialog() {
    _titleController.clear();
    _descriptionController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Project'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isCreatingProject ? null : _createProject,
            child: _isCreatingProject
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createProject() async {
    if (_formKey.currentState?.validate() != true) return;
    
    setState(() {
      _isCreatingProject = true;
    });
    
    try {
      final projectController = Provider.of<ProjectController>(context, listen: false);
      final title = _titleController.text;
      final description = _descriptionController.text;
      
      final newProject = await projectController.createProject(title, description);
      
      if (newProject != null) {
        // Close the dialog
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project created successfully')),
        );
        
        // Reload projects
        _refreshProjects();
        
        // Switch to My Projects tab
        _tabController.animateTo(1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(projectController.error ?? 'Failed to create project')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating project: $e')),
      );
    } finally {
      setState(() {
        _isCreatingProject = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Projects'),
            Tab(text: 'My Projects'),
            Tab(text: 'Collaborations'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateProjectDialog,
            tooltip: 'Create Project',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllProjectsTab(),
                _buildMyProjectsTab(),
                _buildCollaborationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllProjectsTab() {
    return Consumer<ProjectController>(
      builder: (context, projectController, child) {
        if (projectController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (projectController.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading projects',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                SizedBox(height: 8),
                Text(projectController.error!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshProjects,
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final filteredProjects = _getFilteredProjects(projectController.projects);

        if (filteredProjects.isEmpty) {
          return Center(
            child: _searchQuery.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No projects yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showCreateProjectDialog,
                        child: Text('Create a Project'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No matching projects found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProjects,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              return _buildProjectCard(project);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyProjectsTab() {
    return Consumer<ProjectController>(
      builder: (context, projectController, child) {
        if (projectController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (projectController.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading your projects',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                SizedBox(height: 8),
                Text(projectController.error!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshProjects,
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final filteredProjects = _getFilteredProjects(projectController.userProjects);

        if (filteredProjects.isEmpty) {
          return Center(
            child: _searchQuery.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'You haven\'t created any projects yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showCreateProjectDialog,
                        child: Text('Create a Project'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No matching projects found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProjects,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              return _buildProjectCard(project);
            },
          ),
        );
      },
    );
  }

  Widget _buildCollaborationsTab() {
    return Consumer<ProjectController>(
      builder: (context, projectController, child) {
        if (projectController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (projectController.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading collaborations',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                SizedBox(height: 8),
                Text(projectController.error!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshProjects,
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final filteredProjects = _getFilteredProjects(projectController.collaboratingProjects);

        if (filteredProjects.isEmpty) {
          return Center(
            child: _searchQuery.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'You\'re not collaborating on any projects yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _tabController.animateTo(0); // Switch to All Projects tab
                        },
                        child: Text('Browse Projects'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No matching collaborations found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshProjects,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredProjects.length,
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              return _buildProjectCard(project);
            },
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    bool isOwner = _loggedInUser != null && project.submittedBy == _loggedInUser!.id;
    bool isCollaborator = false;
    String collaborationStatus = '';
    
    if (project.collaborators != null && _loggedInUser != null) {
      final userCollaboration = project.collaborators!.firstWhere(
        (c) => c.id == _loggedInUser!.id,
        orElse: () => Collaborator(id: -1, name: '', email: '', status: ''),
      );
      
      if (userCollaboration.id != -1) {
        isCollaborator = userCollaboration.status == 'approved';
        collaborationStatus = userCollaboration.status;
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailPage(projectId: project.id),
            ),
          ).then((_) => _refreshProjects());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      project.title[0].toUpperCase(),
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
                          project.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project.submitterName ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(project.createdAt),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isOwner || isCollaborator || collaborationStatus.isNotEmpty)
                    _buildStatusBadge(isOwner, isCollaborator, collaborationStatus),
                ],
              ),
              SizedBox(height: 12),
              Text(
                project.description,
                style: TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.indigo),
                      SizedBox(width: 4),
                      Text(
                        '${project.collaboratorCount} collaborator${project.collaboratorCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.indigo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailPage(projectId: project.id),
                        ),
                      ).then((_) => _refreshProjects());
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.indigo),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOwner, bool isCollaborator, String status) {
    if (isOwner) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Owner',
          style: TextStyle(
            fontSize: 12,
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isCollaborator) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Collaborator',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (status == 'pending') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Pending',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (status == 'rejected') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Rejected',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    
    return SizedBox.shrink();
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