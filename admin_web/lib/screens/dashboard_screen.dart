import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalPlaces = 0;
  int _totalCategories = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final places = await ApiService.getPlaces();
    final categories = await ApiService.getCategories();
    if (mounted) {
      setState(() {
        _totalPlaces = places.length;
        _totalCategories = categories.length;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tableau de bord', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.place, label: 'Lieux', value: _totalPlaces.toString(), color: Colors.teal, sublabel: 'total des lieux touristiques')),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(icon: Icons.category, label: 'Catégories', value: _totalCategories.toString(), color: Colors.orange, sublabel: 'catégories actives')),
            ],
          ),
          const SizedBox(height: 32),
          Text('Aperçu rapide', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _quickStatRow(Icons.add_circle_outline, 'Créer un lieu', 'Ajoutez un nouveau lieu touristique', Colors.teal),
                  const Divider(),
                  _quickStatRow(Icons.edit_outlined, 'Modifier un lieu', 'Mettez à jour les informations', Colors.blue),
                  const Divider(),
                  _quickStatRow(Icons.sync, 'Synchronisation', 'Les données sont mises à jour toutes les 15s sur mobile', Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStatRow(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String sublabel;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(sublabel, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
