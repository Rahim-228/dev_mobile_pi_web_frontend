import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/place.dart';
import 'add_place_screen.dart';
import 'edit_place_screen.dart';
import 'place_detail_screen.dart';

class CategoryPlacesScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPlacesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPlacesScreen> createState() => _CategoryPlacesScreenState();
}

class _CategoryPlacesScreenState extends State<CategoryPlacesScreen> {
  List<Place> _places = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() => _loading = true);
    final places = await ApiService.getPlaces(categoryId: widget.categoryId);
    if (mounted) setState(() { _places = places; _loading = false; });
  }

  Future<void> _deletePlace(Place place) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le lieu'),
        content: Text('Supprimer définitivement "${place.nameFr}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deletePlace(place.id);
      _loadPlaces();
    }
  }

  Color _categoryColor(int categoryId) {
    const colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red, Colors.teal];
    return colors[(categoryId - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(widget.categoryId);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlaceScreen()));
          _loadPlaces();
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPlaces,
              child: _places.isEmpty
                  ? ListView(children: [
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('Aucun lieu dans cette catégorie', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: _places.length,
                      itemBuilder: (context, index) {
                        final place = _places[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (place.image != null && place.image!.isNotEmpty)
                                  Image.network(
                                    'http://localhost:3000${place.image}',
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(height: 160, color: Colors.grey[200]),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(place.nameFr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, size: 20),
                                            onSelected: (v) async {
                                              if (v == 'edit') {
                                                await Navigator.push(context, MaterialPageRoute(builder: (_) => EditPlaceScreen(place: place)));
                                                _loadPlaces();
                                              } else if (v == 'delete') {
                                                _deletePlace(place);
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, color: Colors.blue), title: Text('Modifier'))),
                                              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Supprimer'))),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (place.descriptionFr != null && place.descriptionFr!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(place.descriptionFr!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
