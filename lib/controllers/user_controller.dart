import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pioneerhub_app/models/user.dart';
import 'package:pioneerhub_app/services/api_service.dart';

class UserController with ChangeNotifier {
  final ApiService apiService;
  List<User> users = [];

  UserController({required this.apiService});

  Future<void> fetchUsers() async {
    final response = await apiService.get('/users');
    final List<dynamic> data = jsonDecode(response.body);
    users = data.map((json) => User.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await apiService.post('/users', user.toJson());
    fetchUsers();
  }

  Future<void> updateUser(User user) async {
    await apiService.put('/users/${user.id}', user.toJson());
    fetchUsers();
  }

  Future<void> deleteUser(int id) async {
    await apiService.delete('/users/$id');
    fetchUsers();
  }
}