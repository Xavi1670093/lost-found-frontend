import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    // --- CAMBIO CLAVE: Quitamos el Scaffold y la AppBar ---
    // Devolvemos directamente el ListView para que se integre en la MainNavigationPage
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Usamos el color del tema definido por Xavi
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
        Text(
          t.preview,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Lista de objetos (RF07 - Feed básico)
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

// Widget auxiliar para las tarjetas de objetos
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
          // Icono estándar de inventario (cumple RNF01: Usabilidad)
          child: Icon(Icons.inventory_2_outlined),
        ),
        title: Text(title),
        subtitle: Text('$location · $date'),
        // El icono de la derecha indica que se puede entrar al detalle (RF10)
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}