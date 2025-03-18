import 'dart:convert';

class Project {
  final int id;
  final String title;
  final String description;
  final int submittedBy;
  final String createdAt;
  final String? submitterName;
  final String? submitterEmail;
  final int collaboratorCount;
  final List<Collaborator>? collaborators;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.submittedBy,
    required this.createdAt,
    this.submitterName,
    this.submitterEmail,
    this.collaboratorCount = 0,
    this.collaborators,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    List<Collaborator>? collaboratorList;
    if (json['collaborators'] != null) {
      collaboratorList = List<Collaborator>.from(
        (json['collaborators'] as List).map((x) => Collaborator.fromJson(x)),
      );
    }

    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      submittedBy: json['submitted_by'],
      createdAt: json['created_at'],
      submitterName: json['submitter_name'],
      submitterEmail: json['submitter_email'],
      collaboratorCount: json['collaborator_count'] ?? 0,
      collaborators: collaboratorList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'submitted_by': submittedBy,
      'created_at': createdAt,
      'submitter_name': submitterName,
      'submitter_email': submitterEmail,
      'collaborator_count': collaboratorCount,
      'collaborators': collaborators?.map((x) => x.toJson()).toList(),
    };
  }

  // Create a copy with updated fields
  Project copyWith({
    int? id,
    String? title,
    String? description,
    int? submittedBy,
    String? createdAt,
    String? submitterName,
    String? submitterEmail,
    int? collaboratorCount,
    List<Collaborator>? collaborators,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      submittedBy: submittedBy ?? this.submittedBy,
      createdAt: createdAt ?? this.createdAt,
      submitterName: submitterName ?? this.submitterName,
      submitterEmail: submitterEmail ?? this.submitterEmail,
      collaboratorCount: collaboratorCount ?? this.collaboratorCount,
      collaborators: collaborators ?? this.collaborators,
    );
  }
}

class Collaborator {
  final int id;
  final String name;
  final String email;
  final String status;
  final int? requestId;
  final String? requestedAt;

  Collaborator({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.requestId,
    this.requestedAt,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      status: json['status'],
      requestId: json['request_id'],
      requestedAt: json['requested_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'request_id': requestId,
      'requested_at': requestedAt,
    };
  }
}