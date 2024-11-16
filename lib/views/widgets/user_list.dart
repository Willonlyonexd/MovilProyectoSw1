import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final List<String> users;

  const UserList({Key? key, this.users = const ['Usuario 1', 'Usuario 2', 'Usuario 3']})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            users[index],
            style: const TextStyle(color: Colors.white),
          ),
          trailing: Icon(Icons.music_note, color: Colors.purple[200]),
        );
      },
    );
  }
}
