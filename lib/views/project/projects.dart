import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pioneerhub_app/controllers/project_controller.dart';
import 'package:pioneerhub_app/controllers/auth_controller.dart';
import 'package:pioneerhub_app/models/project.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:intl/intl.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _fetchProjectData();
  }

  Future<void> _loadUserData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    currentUser = await authController.getLoggedInUser();
  }

  Future<void> _fetchProjectData() async {
    setState(() {
      isLoading = true;
    });
    
    final projectController = Provider.of<ProjectController>(context, listen: false);
    
    // Load all different project lists
    await projectController.fetchProjects();
    await projectController.fetchUserProjects();
    await projectController.fetchCollaboratingProjects();
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All Projects'),
            Tab(text: 'My Projects'),
            Tab(text: 'Collaborating'),
          ],
        ),
      ),
      body: Consumer<ProjectController>(
        builder: (context, projectController, child) {
          if (isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildProjectList(
                projects: projectController.projects,
                emptyMessage: 'No projects available',
                onRefresh: () async => await projectController.fetchProjects(),
              ),
              _buildProjectList(
                projects: projectController.userProjects,
                emptyMessage: 'You haven\'t created any projects yet',
                onRefresh: () async => await projectController.fetchUserProjects(),
              ),
              _buildProjectList(
                projects: projectController.collaboratingProjects,
                emptyMessage: 'You\'re not collaborating on any projects yet',
                onRefresh: () async => await projectController.fetchCollaboratingProjects(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildProjectList({
    required List<Project> projects,
    required String emptyMessage,
    required Future<void> Function() onRefresh,
  }) {
    if (projects.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return _buildProjectCard(project);
        },
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final formattedDate = _formatDate(project.createdAt);
    final isOwner = currentUser != null && currentUser!.id.toString() == project.submittedBy.toString();

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context, 
            '/project-detail',
            arguments: {'projectId': project.id},
          ).then((_) => _fetchProjectData());
        },
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
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Created by ${project.submitterName ?? "Unknown"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    Container(
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
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                project.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${project.collaboratorCount} Collaborator${project.collaboratorCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Create New Project'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project description';
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isSubmitting = true;
                          });

                          try {
                            final projectController =
                                Provider.of<ProjectController>(context, listen: false);
                            
                            final project = await projectController.createProject(
                              titleController.text,
                              descriptionController.text,
                            );

                            Navigator.pop(context);
                            
                            if (project != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Project created successfully')),
                              );
                              _fetchProjectData();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to create project: $e')),
                            );
                          }
                        }
                      },
                child: isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}