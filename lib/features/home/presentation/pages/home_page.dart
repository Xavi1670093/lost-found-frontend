import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🔹 Banner bienvenida
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.welcome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(t.welcomeDescription),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 🔹 Título preview
        Text(
          t.preview,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // 🔹 Filtros por categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(label: t.keys),
              _CategoryChip(label: t.wallets),
              _CategoryChip(label: t.devices),
              _CategoryChip(label: t.phones),
              _CategoryChip(label: t.clothes),
              _CategoryChip(label: t.bottles),
              _CategoryChip(label: t.others),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Lista de objetos (mock)
        const _FakeObjectCard(
          title: 'Mochila negra',
          location: 'Facultad de Ingeniería',
          date: 'Hoy',
        ),
        const _FakeObjectCard(
          title: 'Llaves con llavero rojo',
          location: 'Biblioteca',
          date: 'Ayer',
        ),
        const _FakeObjectCard(
          title: 'Cartera marrón',
          location: 'Plaza Cívica',
          date: 'Hace 2 días',
        ),
      ],
    );
  }
}

/// 🔹 Chip de categoría
class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: false,
        onSelected: (_) {
          // TODO: lógica de filtrado futura
        },
      ),
    );
  }
}

/// 🔹 Card de objeto mock
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