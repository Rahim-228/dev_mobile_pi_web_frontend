import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/place.dart';
import '../models/category.dart';

class EditPlaceScreen extends StatefulWidget {
  final Place place;
  const EditPlaceScreen({super.key, required this.place});

  @override
  State<EditPlaceScreen> createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends State<EditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _mapsController;

  List<Category> _categories = [];
  int? _selectedCategoryId;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.place.nameFr);
    _descriptionController = TextEditingController(text: widget.place.descriptionFr ?? '');
    _mapsController = TextEditingController(text: widget.place.googleMapsUrl ?? '');
    _selectedCategoryId = widget.place.categoryId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await ApiService.getCategories();
    if (mounted) setState(() => _categories = cats.where((c) => c.id >= 1 && c.id <= 6).toList());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() { _imageBytes = bytes; _imageName = file.name; });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final nom = _nomController.text.trim();
    final desc = _descriptionController.text.trim();

    final place = Place(
      id: widget.place.id,
      categoryId: _selectedCategoryId ?? widget.place.categoryId,
      nameFr: nom,
      nameAr: nom,
      nameEn: nom,
      descriptionFr: desc.isEmpty ? null : desc,
      descriptionAr: desc.isEmpty ? null : desc,
      descriptionEn: desc.isEmpty ? null : desc,
      googleMapsUrl: _mapsController.text.trim().isEmpty ? null : _mapsController.text.trim(),
    );

    final result = await ApiService.updatePlace(widget.place.id, place, imageBytes: _imageBytes, imageName: _imageName);
    if (mounted) {
      setState(() => _loading = false);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Lieu modifié avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: ${ApiService.lastError ?? "Échec"}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le lieu', style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity)
                        : (widget.place.image != null
                            ? Image.network('http://localhost:3000${widget.place.image}', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, _, _) => _imagePlaceholder())
                            : _imagePlaceholder()),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.category),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameFr))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du lieu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.place),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Le nom est requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.description),
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mapsController,
                decoration: InputDecoration(
                  labelText: 'Lien Google Maps',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.map),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF00695C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Enregistrer les modifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text('Cliquez pour changer l\'image', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
      ],
    );
  }
}
