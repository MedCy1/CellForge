import 'package:flutter/material.dart';
import '../services/pattern_service.dart';
import '../core/engine/life_engine_controller.dart';

class WorkshopBrowser extends StatefulWidget {
  final LifeEngineController engine;
  
  const WorkshopBrowser({
    super.key,
    required this.engine,
  });

  @override
  State<WorkshopBrowser> createState() => _WorkshopBrowserState();
}

class _WorkshopBrowserState extends State<WorkshopBrowser> {
  final PatternService _patternService = PatternService();
  List<PatternModel> _patterns = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final patterns = await _patternService.getPatterns();
      if (mounted) {
        setState(() {
          _patterns = patterns;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop - Patterns partagés'),
        actions: [
          IconButton(
            onPressed: _loadPatterns,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        tooltip: 'Partager un pattern',
        child: const Icon(Icons.upload),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatterns,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_patterns.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun pattern disponible',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Soyez le premier à partager un pattern !',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _patterns.length,
      itemBuilder: (context, index) {
        final pattern = _patterns[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.grid_on),
            title: Text(pattern.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pattern.author != null) Text('Par: ${pattern.author}'),
                Text(
                  'Créé le: ${_formatDate(pattern.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _loadPattern(pattern),
                  icon: const Icon(Icons.download),
                  tooltip: 'Charger ce pattern',
                ),
                IconButton(
                  onPressed: () => _showPatternDetails(pattern),
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Détails',
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _loadPattern(PatternModel pattern) {
    try {
      widget.engine.loadPattern(pattern.data);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pattern "${pattern.name}" chargé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPatternDetails(PatternModel pattern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pattern.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pattern.author != null) Text('Auteur: ${pattern.author}'),
            Text('Créé le: ${_formatDate(pattern.createdAt)}'),
            const SizedBox(height: 16),
            Text('Taille: ${pattern.data[0].length}×${pattern.data.length}'),
            Text('Cellules vivantes: ${_countAliveCells(pattern.data)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadPattern(pattern);
            },
            child: const Text('Charger'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    final nameController = TextEditingController();
    final authorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager votre pattern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du pattern',
                hintText: 'Ex: Glider, Oscillateur...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: 'Votre nom (optionnel)',
                hintText: 'Ex: John Doe',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => _uploadPattern(
              nameController.text.trim(),
              authorController.text.trim().isEmpty 
                ? null 
                : authorController.text.trim(),
            ),
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPattern(String name, String? author) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom du pattern est requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    try {
      final pattern = widget.engine.exportPattern();
      await _patternService.uploadPattern(name, author, pattern);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pattern partagé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      _loadPatterns();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _countAliveCells(List<List<bool>> data) {
    int count = 0;
    for (var row in data) {
      for (var cell in row) {
        if (cell) count++;
      }
    }
    return count;
  }
}