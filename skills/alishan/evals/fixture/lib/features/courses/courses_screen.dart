import 'package:flutter/material.dart';

class Course {
  Course(this.id, this.title, this.thumbnailUrl);
  final String id;
  final String title;
  final String thumbnailUrl;
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, required this.courses});
  final List<Course> courses;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String filter = '';

  @override
  Widget build(BuildContext context) {
    final visible = widget.courses.where((c) => c.title.toLowerCase().contains(filter.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(onChanged: (v) => setState(() => filter = v)),
            ...visible.map(
              (c) => Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(blurRadius: 24, spreadRadius: 4, color: Color(0x33000000))],
                ),
                child: Row(
                  children: [
                    Image.network(c.thumbnailUrl, width: 64, height: 64, fit: BoxFit.cover),
                    const SizedBox(width: 12),
                    Text(c.title, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
