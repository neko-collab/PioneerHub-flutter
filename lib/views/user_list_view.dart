// filepath: lib/views/user_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pioneerhub_app/controllers/user_controller.dart';

class UserListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: Consumer<UserController>(
        builder: (context, controller, child) {
          if (controller.users.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => controller.deleteUser(user.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add user logic
        },
        child: Icon(Icons.add),
      ),
    );
  }
}