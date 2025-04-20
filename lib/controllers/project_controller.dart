import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pioneerhub_app/models/project.dart';
import 'package:pioneerhub_app/services/api_service.dart';

class ProjectController extends ChangeNotifier {
  final ApiService apiService;
  
  List<Project> _projects = [];
  List<Project> _userProjects = [];
  List<Project> _collaboratingProjects = [];
  Project? _currentProject;
  
  bool _isLoading = false;
  String? _error;

  ProjectController({required this.apiService});

  // Getters
  List<Project> get projects => _projects;
  List<Project> get userProjects => _userProjects;
  List<Project> get collaboratingProjects => _collaboratingProjects;
  Project? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all projects
  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.get('/projects.php');
      final data = json.decode(response.body);
      print(data);
      if (data['status'] == 'success') {
        _projects = List<Project>.from(
          data['data'].map((x) => Project.fromJson(x))
        );
      } else {
        _error = data['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get a specific project
  Future<Project?> fetchProjectDetails(int projectId) async {
    _isLoading = true;
    _error = null;
    _currentProject = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'viewProject',
        'id': projectId,
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        _currentProject = Project.fromJson(data['data']);
        return _currentProject;
      } else {
        _error = data['message'];
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new project
  Future<Project?> createProject(String title, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'addProject',
        'title': title,
        'description': description,
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        final newProject = Project.fromJson(data['data']);
        _userProjects.insert(0, newProject);
        return newProject;
      } else {
        _error = data['message'];
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing project
  Future<Project?> updateProject(int projectId, {String? title, String? description}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> requestData = {
        'action': 'editProject',
        'id': projectId,
      };

      if (title != null) requestData['title'] = title;
      if (description != null) requestData['description'] = description;

      final response = await apiService.post('/projects.php', requestData);
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        final updatedProject = Project.fromJson(data['data']);
        
        // Update in lists if present
        _updateProjectInLists(updatedProject);
        
        // Update current project if it's the same
        if (_currentProject != null && _currentProject!.id == projectId) {
          _currentProject = updatedProject;
        }
        
        return updatedProject;
      } else {
        _error = data['message'];
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a project
  Future<bool> deleteProject(int projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'deleteProject',
        'id': projectId,
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        // Remove from lists if present
        _removeProjectFromLists(projectId);
        
        // Clear current project if it's the same
        if (_currentProject != null && _currentProject!.id == projectId) {
          _currentProject = null;
        }
        
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request collaboration on a project
  Future<bool> requestCollaboration(int projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'requestCollaboration',
        'project_id': projectId,
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // List collaboration requests for a project
  Future<List<Collaborator>> fetchCollaborationRequests(int projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'listCollaborationRequests',
        'project_id': projectId,
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        return List<Collaborator>.from(
          data['data'].map((x) => Collaborator.fromJson(x))
        );
      } else {
        _error = data['message'];
        return [];
      }
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Respond to a collaboration request
  Future<bool> respondToCollaborationRequest(int requestId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'respondToCollaborationRequest',
        'request_id': requestId,
        'status': status,
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        // If this is the current project being viewed, refresh it to show updated collaborators
        if (_currentProject != null) {
          await fetchProjectDetails(_currentProject!.id);
        }
        return true;
      } else {
        _error = data['message'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user's projects (ones they created)
  Future<void> fetchUserProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'listUserProjects',
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        _userProjects = List<Project>.from(
          data['data'].map((x) => Project.fromJson(x))
        );
      } else {
        _error = data['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get projects user is collaborating on
  Future<void> fetchCollaboratingProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/projects.php', {
        'action': 'listCollaboratingProjects',
      });
      
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        _collaboratingProjects = List<Project>.from(
          data['data'].map((x) => Project.fromJson(x))
        );
      } else {
        _error = data['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to update project in all lists
  void _updateProjectInLists(Project updatedProject) {
    // Update in all projects list
    final allIndex = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (allIndex != -1) {
      _projects[allIndex] = updatedProject;
    }
    
    // Update in user projects
    final userIndex = _userProjects.indexWhere((p) => p.id == updatedProject.id);
    if (userIndex != -1) {
      _userProjects[userIndex] = updatedProject;
    }
    
    // Update in collaborating projects
    final collabIndex = _collaboratingProjects.indexWhere((p) => p.id == updatedProject.id);
    if (collabIndex != -1) {
      _collaboratingProjects[collabIndex] = updatedProject;
    }
  }

  // Helper method to remove project from all lists
  void _removeProjectFromLists(int projectId) {
    _projects.removeWhere((p) => p.id == projectId);
    _userProjects.removeWhere((p) => p.id == projectId);
    _collaboratingProjects.removeWhere((p) => p.id == projectId);
  }

  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}