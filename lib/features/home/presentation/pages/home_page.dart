import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilost_found/shared/widgets/custom_card.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:unilost_found/core/services/custom_cache_manager.dart';
import 'post_detail_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:geolocator/geolocator.dart';
import 'package:unilost_found/core/services/permission_service.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/widgets/notification_bell.dart';
import 'package:unilost_found/shared/utils/category_utils.dart';
import 'package:unilost_found/shared/utils/center_utils.dart';
import 'package:unilost_found/shared/utils/image_utils.dart';

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
  late TextEditingController _searchController;
  late MapController _mapController;
  late final Widget _lostMarkerWidget;
  late final Widget _foundMarkerWidget;

  String _sortBy = 'recent'; // 'recent' o 'distance'
  List<Map<dynamic, dynamic>>? _distancePosts;
  bool _isLoadingDistance = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mapController = MapController();
    _lostMarkerWidget = _buildMarkerWidget(Colors.orange.shade700, Icons.search_rounded);
    _foundMarkerWidget = _buildMarkerWidget(Colors.green.shade700, Icons.inventory_2_rounded);
    _loadUserCenter();
  }

  Widget _buildMarkerWidget(Color color, IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCenter() async {
    if (user == null) return;
    final snapshot = await FirebaseDatabase.instance.ref('users/${user!.uid}/center_id').get();
    if (mounted) {
      setState(() {
        centerId = CenterUtils.normalizeCenterId(snapshot.value);
      });
    }
  }

  bool _matchesCategory(String backendCategory, String selectedLabel, AppStrings t) {
    if (selectedLabel.isEmpty) return true;
    // Comparamos el label localizado de la categoría del post con el label seleccionado
    final categoryLabel = CategoryUtils.getCategoryLabel(backendCategory, t);
    return categoryLabel == selectedLabel;
  }

  Future<void> _centerOnUserLocation() async {
    final t = AppStrings.of(context);
    final hasPermission = await PermissionService.requestLocation();
    if (!hasPermission) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _mapController.move(
        osm.LatLng(position.latitude, position.longitude),
        15.0,
      );
    } catch (e) {
      if (mounted) AppNotifications.showError(context, t.locationError);
    }
  }

  void _handleSortChanged(String value) {
    if (value == 'recent') {
      setState(() {
        _sortBy = 'recent';
      });
    } else {
      _handleSortByDistance();
    }
  }

  Future<void> _handleSortByDistance() async {
    final t = AppStrings.of(context);
    setState(() {
      _isLoadingDistance = true;
      _sortBy = 'distance';
    });

    final hasPermission = await PermissionService.requestLocation();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _sortBy = 'recent';
          _isLoadingDistance = false;
        });
        AppNotifications.showError(context, t.locationPermissionDenied);
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final callable = FirebaseFunctions.instance.httpsCallable('getFilteredFeed');
      final response = await callable.call({
        'center_id': CenterUtils.normalizeCenterId(centerId),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'sortBy': 'distance',
      });

      final List<Map<dynamic, dynamic>> parsedPosts = [];
      if (response.data != null) {
        final data = response.data;
        if (data is List) {
          for (var item in data) {
            if (item is Map) {
              parsedPosts.add(Map<dynamic, dynamic>.from(item));
            }
          }
        } else if (data is Map) {
          final listData = data['feed'] ?? data['posts'];
          if (listData is List) {
            for (var item in listData) {
              if (item is Map) {
                parsedPosts.add(Map<dynamic, dynamic>.from(item));
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _distancePosts = parsedPosts;
          _isLoadingDistance = false;
        });
      }
    } catch (e) {
      debugPrint("ULF_DEBUG: Error in getFilteredFeed: $e");
      if (mounted) {
        setState(() {
          _sortBy = 'recent';
          _isLoadingDistance = false;
        });
        AppNotifications.showError(context, t.locationError);
      }
    }
  }

  void _centerOnCampus() {
    _mapController.move(
      const osm.LatLng(41.5000, 2.1075),
      15.0,
    );
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
          bool isLoading = centerId == null ||
              (_sortBy == 'recent' && snapshot.connectionState == ConnectionState.waiting) ||
              (_sortBy == 'distance' && _isLoadingDistance);

          if (_sortBy == 'recent') {
            if (snapshot.hasError) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          '${t.errorUnexpected}: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (!isLoading) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                hasNoPosts = true;
              } else {
                for (final child in snapshot.data!.snapshot.children) {
                  final value = Map<dynamic, dynamic>.from(child.value as Map);
                  value['id'] = child.key;
                  bool categoryMatch = _matchesCategory(value['category']?.toString() ?? '', _selectedCategoryLabel, t);
                  bool searchMatch = (value['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (value['description'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());

                  if (value['is_deleted'] != true &&
                      (value['status'] == 'active' || value['status'] == 'matched') &&
                      categoryMatch &&
                      searchMatch) {
                    postsList.add(value);
                  }
                }
                // Ordenar por fecha: más recientes primero
                postsList.sort((a, b) => (b['created_at'] ?? 0).compareTo(a['created_at'] ?? 0));
                
                if (postsList.isEmpty) hasNoPosts = true;
              }
            }
          } else {
            // _sortBy == 'distance'
            if (!isLoading) {
              if (_distancePosts == null || _distancePosts!.isEmpty) {
                hasNoPosts = true;
              } else {
                for (final value in _distancePosts!) {
                  bool categoryMatch = _matchesCategory(value['category']?.toString() ?? '', _selectedCategoryLabel, t);
                  bool searchMatch = (value['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (value['description'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());

                  if (value['is_deleted'] != true &&
                      (value['status'] == 'active' || value['status'] == 'matched') &&
                      categoryMatch &&
                      searchMatch) {
                    postsList.add(value);
                  }
                }
                if (postsList.isEmpty) hasNoPosts = true;
              }
            }
          }

          return CustomScrollView(
            slivers: [
              // Header with Search
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: false,
                expandedHeight: 180,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: theme.colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    t.appName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 96),
                  expandedTitleScale: 1.2,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                          theme.colorScheme.surface,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                actions: const [
                  NotificationBell(),
                  SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: t.searchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                        children: CategoryUtils.categories.map((cat) {
                          return _buildCategoryChip(CategoryUtils.getCategoryLabel(cat, t));
                        }).toList(),
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
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: const osm.LatLng(41.5000, 2.1075),
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                ),
                                cameraConstraint: CameraConstraint.contain(
                                  bounds: LatLngBounds(
                                    const osm.LatLng(41.480, 2.085),
                                    const osm.LatLng(41.520, 2.130),
                                  ),
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.lostfound',
                                ),
                                MarkerLayer(
                                  markers: postsList.map((post) {
                                    final coords = post['coords'] as Map<dynamic, dynamic>?;
                                    final double lat = double.tryParse(coords?['lat'].toString() ?? '0.0') ?? 0.0;
                                    final double lng = double.tryParse(coords?['lng'].toString() ?? '0.0') ?? 0.0;

                                    return Marker(
                                      point: osm.LatLng(lat, lng),
                                      width: 30,
                                      height: 30,
                                      child: post['type'] == 'lost'
                                          ? _lostMarkerWidget
                                          : _foundMarkerWidget,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FloatingActionButton.small(
                                    heroTag: 'campus_center_fab',
                                    onPressed: _centerOnCampus,
                                    backgroundColor: theme.colorScheme.surface,
                                    foregroundColor: theme.colorScheme.primary,
                                    child: const Icon(Icons.account_balance_rounded),
                                  ),
                                  const SizedBox(height: 8),
                                  FloatingActionButton.small(
                                    heroTag: 'center_map_fab',
                                    onPressed: _centerOnUserLocation,
                                    backgroundColor: theme.colorScheme.surface,
                                    foregroundColor: theme.colorScheme.primary,
                                    child: const Icon(Icons.my_location_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _sortBy == 'distance' ? t.proximitySort : t.recentObjects,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            icon: Icon(Icons.sort_rounded, color: theme.colorScheme.primary),
                            items: [
                              DropdownMenuItem(
                                value: 'recent',
                                child: Text(t.recentSort),
                              ),
                              DropdownMenuItem(
                                value: 'distance',
                                child: Text(t.proximitySort),
                              ),
                            ],
                            onChanged: (String? value) {
                              if (value != null) {
                                _handleSortChanged(value);
                              }
                            },
                          ),
                        ],
                      ),
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
                      child: Text(postsList.isEmpty && _searchQuery.isNotEmpty ? t.noObjectsFound : t.noObjectsIn(centerId?.toUpperCase() ?? t.uabAcronym)),
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
    final imageUrl = ImageUtils.postImageUrlFrom(post);

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
          // Area de Imagen/Icono con Badge
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: 'post_image_${post['id']}',
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            cacheManager: CustomCacheManager.instance,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              final thumbnailUrl = ImageUtils.postThumbnailUrlFrom(post);
                              if (thumbnailUrl != null && thumbnailUrl != imageUrl) {
                                return CachedNetworkImage(
                                  imageUrl: thumbnailUrl,
                                  cacheManager: CustomCacheManager.instance,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const SkeletonLoader(
                                    width: double.infinity,
                                    height: double.infinity,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                  ),
                                  errorWidget: (context, url, error) => const SkeletonLoader(
                                    width: double.infinity,
                                    height: double.infinity,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                  ),
                                );
                              }
                              return const SkeletonLoader(
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              );
                            },
                            errorWidget: (context, url, error) => _buildIconFallback(theme),
                          ),
                        )
                      : _buildIconFallback(theme),
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
                          color: Colors.black.withValues(alpha: 0.1),
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
                if (post['status'] == 'matched')
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade800,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          t.possibleMatchBadge.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Area de Informacion
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
                    Icon(Icons.location_on_rounded,
                        size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post['location'] ?? t.campusUab,
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

  Widget _buildIconFallback(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Center(
        child: Icon(
          CategoryUtils.getCategoryIcon(post['category']?.toString()),
          size: 44,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
