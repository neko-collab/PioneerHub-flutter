import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({required this.title, super.key});

  // Fields in a Widget subclass are always marked "final".

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.blue[500]),
      // Row is a horizontal, linear layout.
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: (){
              print('Menu button clicked');
            } // null disables the button
          ),
          // Expanded expands its child
          // to fill the available space.
          Expanded(child: title),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: (){
              //display search bar
              print('Search button clicked');

            },
          ),
        ],
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      // Column is a vertical, linear layout.
      child: Column(
        children: [
          MyAppBar(

            title: Text(
              'Example title',
              style:
                  Theme.of(context) //
                  .primaryTextTheme.titleLarge,
            ),
          ),
          const Expanded(child: Center(child: Text('Hello, world!'))),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
                  debugShowCheckedModeBanner: false,
      title: 'My app', // used by the OS task switcher
      home: SafeArea(child: MyScaffold()),
    ),
  );
}