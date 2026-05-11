import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/custom_card.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'post_detail_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  String? centerId;
  String _selectedCategoryLabel = "";
  String _searchQuery = "";

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
        centerId = snapshot.value?.toString().toLowerCase() ?? "uab";
      });
    }
  }

  bool _matchesCategory(String backendCategory, String selectedLabel, AppStrings t) {
    if (selectedLabel.isEmpty) return true;
    if (selectedLabel == t.keys && backendCategory == "keys") return true;
    if (selectedLabel == t.wallets && backendCategory == "wallet") return true;
    if (selectedLabel == t.devices && backendCategory == "devices") return true;
    if (selectedLabel == t.clothes && backendCategory == "clothing") return true;
    if (selectedLabel == t.others && backendCategory == "other") return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref('posts')
            .orderByChild('center_id')
            .equalTo(centerId)
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          // Pre-procesamos los datos de los posts si están disponibles
          List<Map<dynamic, dynamic>> postsList = [];
          bool hasNoPosts = false;
          bool isLoading = centerId == null || snapshot.connectionState == ConnectionState.waiting;

          if (!isLoading) {
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              hasNoPosts = true;
            } else {
              for (final child in snapshot.data!.snapshot.children) {
                final value = Map<dynamic, dynamic>.from(child.value as Map);
                value['id'] = child.key;
                bool categoryMatch = _matchesCategory(value['category']?.toString() ?? '', _selectedCategoryLabel, t);
                bool searchMatch = (value['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());

                if (value['is_deleted'] == false && value['status'] == 'active' && categoryMatch && searchMatch) {
                  postsList.add(value);
                }
              }
              if (postsList.isEmpty) hasNoPosts = true;
            }
          }

          return CustomScrollView(
            slivers: [
              // Header with Search
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(
                  t.appName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () {
                      // TODO: Implementar notificaciones
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: t.searchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune_rounded),
                          onPressed: () {},
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                ),
              ),

              // Categories and Map
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.welcome,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.welcomeDescription,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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

                    // Map Preview
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(t.preview, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: StreamBuilder<DatabaseEvent>(
                            stream: FirebaseDatabase.instance.ref('posts').onValue,
                            builder: (context, snapshot) {
                              List<Marker> markers = [];
                              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                                for (final child in snapshot.data!.snapshot.children) {
                                  try {
                                    final value = Map<dynamic, dynamic>.from(child.value as Map);
                                    value['id'] = child.key;
                                    final coords = value['coords'] as Map<dynamic, dynamic>?;
                                    if (coords == null) continue;
                                    
                                    final double lat = double.tryParse(coords['lat'].toString()) ?? 0.0;
                                    final double lng = double.tryParse(coords['lng'].toString()) ?? 0.0;

                                    markers.add(
                                      Marker(
                                        point: osm.LatLng(lat, lng),
                                        width: 40,
                                        height: 40,
                                        child: Icon(
                                          value['type'] == 'lost' ? Icons.location_on_rounded : Icons.location_on_rounded,
                                          color: value['type'] == 'lost' ? Colors.orange : Colors.green,
                                          size: 30,
                                        ),
                                      ),
                                    );
                                  } catch (_) {}
                                }
                              }
                              return FlutterMap(
                                options: const MapOptions(
                                  initialCenter: osm.LatLng(41.5000, 2.1075),
                                  initialZoom: 14,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.lostfound',
                                  ),
                                  MarkerLayer(markers: markers),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(t.recentObjects, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Posts Grid
              if (isLoading)
                SkeletonLoader.postGrid()
              else if (hasNoPosts)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(postsList.isEmpty && _searchQuery.isNotEmpty ? t.noObjectsFound : "${t.noObjectsIn} $centerId"),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _RealObjectCard(post: postsList[index]),
                      childCount: postsList.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
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
            _selectedCategoryLabel = selected ? label : "";
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
      ),
    );
  }
}

class _RealObjectCard extends StatelessWidget {
  final Map<dynamic, dynamic> post;
  const _RealObjectCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final isLost = post['type'] == 'lost';
    final theme = Theme.of(context);

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
        );
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Icon Area with Badge
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: 'post_image_${post['id']}',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer.withOpacity(0.4),
                          theme.colorScheme.primaryContainer.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(post['category']?.toString()),
                        size: 44,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLost ? Colors.orange.shade800 : Colors.green.shade800,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isLost ? t.lostStatus : t.foundStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'] ?? t.defaultItemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: theme.colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post['location'] ?? 'UAB',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'keys': return Icons.vpn_key_rounded;
      case 'wallet': return Icons.account_balance_wallet_rounded;
      case 'devices': return Icons.devices_rounded;
      case 'clothing': return Icons.checkroom_rounded;
      default: return Icons.inventory_2_rounded;
    }
  }
}
