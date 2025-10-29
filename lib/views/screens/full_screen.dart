import 'package:flutter/material.dart';

class FullScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const FullScreen({super.key, required this.post, required postDoc});

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  @override
  Widget build(BuildContext context) {
    final String description = widget.post['description'] ?? 'No description';
    final String user = widget.post['user'] ?? 'Anonymous';
    final String imageUrl =
        widget.post['imageUrl'] ?? 'https://via.placeholder.com/400';
    return Scaffold(
      appBar: AppBar(title: Text(user)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
