import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido a ULF',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aquí aparecerán próximamente los objetos perdidos y encontrados del campus.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Vista previa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _FakeObjectCard(
            title: 'Mochila negra',
            location: 'Facultad de Ingeniería',
            date: 'Hoy',
          ),
          _FakeObjectCard(
            title: 'Llaves con llavero rojo',
            location: 'Biblioteca',
            date: 'Ayer',
          ),
          _FakeObjectCard(
            title: 'Cartera marrón',
            location: 'Plaza Cívica',
            date: 'Hace 2 días',
          ),
        ],
      ),
    );
  }
}

class _FakeObjectCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;

  const _FakeObjectCard({
    required this.title,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.inventory_2_outlined),
        ),
        title: Text(title),
        subtitle: Text('$location · $date'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}