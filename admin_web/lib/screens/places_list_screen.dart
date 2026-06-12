import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/place.dart';
import '../models/category.dart';
import 'add_place_screen.dart';
import 'edit_place_screen.dart';
import 'place_detail_screen.dart';

class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({super.key});

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  List<Place> _places = [];
  List<Category> _categories = [];
  int? _filterCategoryId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final cats = await ApiService.getCategories();
    final places = await ApiService.getPlaces(categoryId: _filterCategoryId);
    if (mounted) {
      setState(() {
        _categories = cats;
        _places = places;
        _loading = false;
      });
    }
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
      _loadData();
    }
  }

  Color _categoryColor(int categoryId) {
    const colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red, Colors.teal];
    return colors[(categoryId - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlaceScreen()));
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: DropdownButtonFormField<int?>(
                      initialValue: _filterCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Filtrer par catégorie',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        prefixIcon: Icon(Icons.filter_list, color: Colors.teal),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Toutes les catégories', style: TextStyle(fontWeight: FontWeight.w500))),
                        ..._categories.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nameFr),
                        )),
                      ],
                      onChanged: (v) {
                        setState(() => _filterCategoryId = v);
                        _loadData();
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: _places.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text('Aucun lieu trouvé', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                            itemCount: _places.length,
                            itemBuilder: (context, index) {
                              final place = _places[index];
                              final catColor = _categoryColor(place.categoryId);
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: SizedBox(
                                            width: 64,
                                            height: 64,
                                            child: place.image != null
                                                ? Image.network('http://localhost:3000${place.image}', fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholderIcon(catColor))
                                                : _placeholderIcon(catColor),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(place.nameFr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: catColor.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  place.categoryNameFr ?? '',
                                                  style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                          tooltip: 'Modifier',
                                          onPressed: () async {
                                            await Navigator.push(context, MaterialPageRoute(builder: (_) => EditPlaceScreen(place: place)));
                                            _loadData();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                          tooltip: 'Supprimer',
                                          onPressed: () => _deletePlace(place),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _placeholderIcon(Color color) {
    return Container(
      color: color.withValues(alpha: 0.1),
      child: Icon(Icons.place, size: 32, color: color),
    );
  }
}
