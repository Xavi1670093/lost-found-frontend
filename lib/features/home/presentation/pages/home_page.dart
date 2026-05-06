import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/localization/app_strings.dart';
import 'post_detail_page.dart'; // <--- IMPORTA LA NUEVA PÁGINA

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  String? centerId;
  String _selectedCategoryLabel = "";

  @override
  void initState() {
    super.initState();
    _loadUserCenter();
  }

  Future<void> _loadUserCenter() async {
    if (user == null) return;
    final snapshot = await FirebaseDatabase.instance.ref('users/${user!.uid}/center_id').get();
    if (mounted) {
      setState(() {
        centerId = snapshot.value?.toString() ?? "uab";
      });
    }
  }

  // 🚀 LÓGICA DE FILTRADO: Mapea UI Labels con Backend Enums
  bool _matchesCategory(String backendCategory, String selectedLabel, AppStrings t) {
    // Si no hay nada seleccionado (o es la primera carga), mostramos todo
    if (selectedLabel.isEmpty) return true;

    if (selectedLabel == t.keys && backendCategory == "keys") return true;
    if (selectedLabel == t.wallets && backendCategory == "wallet") return true;
    if (selectedLabel == t.devices && backendCategory == "devices") return true;
    if (selectedLabel == t.clothes && backendCategory == "clothing") return true;
    if (selectedLabel == t.phones && backendCategory == "phones") return true; // Si añadís phones
    if (selectedLabel == t.others && backendCategory == "other") return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner bienvenida
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.welcome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(t.welcomeDescription),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Text(t.preview, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        // Filtros por categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip(t.keys),
              _buildCategoryChip(t.wallets),
              _buildCategoryChip(t.devices),
              _buildCategoryChip(t.clothes),
              _buildCategoryChip(t.others),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (centerId == null)
          const Center(child: CircularProgressIndicator())
        else
          StreamBuilder(
            stream: FirebaseDatabase.instance.ref('posts')
                .orderByChild('center_id')
                .equalTo(centerId)
                .onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("No hay objetos todavía en $centerId")));
              }

              final Map<dynamic, dynamic> postsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              final List<Map<dynamic, dynamic>> postsList = [];

              postsMap.forEach((key, value) {
                // 🔍 APLICAMOS EL FILTRO AQUÍ
                bool categoryMatch = _matchesCategory(value['category'] ?? '', _selectedCategoryLabel, t);

                if (value['is_deleted'] == false && value['status'] == 'active' && categoryMatch) {
                  postsList.add(value);
                }
              });

              if (postsList.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay objetos en esta categoría.")));

              return Column(
                children: postsList.map((post) => _RealObjectCard(post: post)).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCategoryLabel == label,
        onSelected: (bool selected) {
          setState(() {
            // Si pulsas el mismo, se deselecciona y muestra todo
            _selectedCategoryLabel = selected ? label : "";
          });
        },
      ),
    );
  }
}

class _RealObjectCard extends StatelessWidget {
  final Map<dynamic, dynamic> post;
  const _RealObjectCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isLost = post['type'] == 'lost';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLost ? Colors.red.shade50 : Colors.green.shade50,
          child: Icon(isLost ? Icons.search : Icons.inventory_2_outlined, color: isLost ? Colors.red : Colors.green),
        ),
        title: Text(post['title'] ?? 'Objeto'),
        subtitle: Text('${post['location'] ?? 'UAB'} · ${post['category']}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // 🚀 NAVEGACIÓN REAL A DETALLES
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
          );
        },
      ),
    );
  }
}