import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final Map<dynamic, dynamic> post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final isLost = post['type'] == 'lost';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(post['title'] ?? 'Detalle')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor de Imagen (Placeholder hasta que tengáis Storage)
            Container(
              height: 250,
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              child: Icon(Icons.image, size: 100, color: theme.colorScheme.primary),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(isLost ? "PERDIDO" : "ENCONTRADO"),
                        backgroundColor: isLost ? Colors.red.shade100 : Colors.green.shade100,
                      ),
                      const SizedBox(width: 10),
                      Chip(label: Text(post['category']?.toString().toUpperCase() ?? "OTROS")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(post['title'] ?? '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(post['description'] ?? 'Sin descripción', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text("Ubicación"),
                    subtitle: Text(post['location'] ?? "UAB - Campus"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text("Publicado el"),
                    subtitle: Text(DateTime.fromMillisecondsSinceEpoch(post['created_at'] ?? 0).toString().split(' ')[0]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}