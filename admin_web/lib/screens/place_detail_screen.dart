import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api_service.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  Future<String> _getCategoryName() async {
    final categories = await ApiService.getCategories();
    final cat = categories.where((c) => c.id == place.categoryId).firstOrNull;
    return cat?.nameFr ?? 'Catégorie #${place.categoryId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.nameFr, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF004D40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (place.image != null && place.image!.isNotEmpty)
              ClipRRect(
                child: Image.network(
                  '${ApiService.imageBaseUrl}${place.image}',
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 280,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.teal.shade50,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.teal.shade200),
                      const SizedBox(height: 8),
                      Text('Aucune image', style: TextStyle(color: Colors.teal.shade300, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.nameFr, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: _getCategoryName(),
                    builder: (context, snapshot) {
                      return Chip(
                        avatar: const Icon(Icons.category, size: 18),
                        label: Text(snapshot.data ?? 'Chargement...', style: const TextStyle(fontSize: 14)),
                        backgroundColor: Colors.teal.shade50,
                        side: BorderSide.none,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  if (place.descriptionFr != null && place.descriptionFr!.isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.teal)),
                    const SizedBox(height: 8),
                    Text(place.descriptionFr!, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                    const SizedBox(height: 20),
                  ],
                  if (place.googleMapsUrl != null && place.googleMapsUrl!.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.map, color: Colors.teal.shade700),
                        const SizedBox(width: 8),
                        const Text('Google Maps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        place.googleMapsUrl!,
                        style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  _infoRow(Icons.translate, 'Arabe', place.nameAr),
                  if (place.nameEn != place.nameFr) _infoRow(Icons.language, 'Anglais', place.nameEn),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text('$label :', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
