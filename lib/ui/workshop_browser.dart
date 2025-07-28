import 'package:flutter/material.dart';
import '../services/pattern_service.dart';
import '../services/auth_service.dart';
import '../core/engine/life_engine_controller.dart';
import 'auth/auth_screen.dart';

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
  final AuthService _authService = AuthService();
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
          if (_authService.isAuthenticated) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _authService.userName ?? 'Utilisateur',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _signOut,
                  child: const Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Se déconnecter'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton.icon(
              onPressed: _showAuthScreen,
              icon: const Icon(Icons.login),
              label: const Text('Connexion'),
            ),
          ],
          IconButton(
            onPressed: _loadPatterns,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _authService.isAuthenticated ? _showUploadDialog : _showAuthScreen,
        tooltip: _authService.isAuthenticated ? 'Partager un pattern' : 'Connexion requise',
        icon: Icon(_authService.isAuthenticated ? Icons.upload : Icons.login),
        label: Text(_authService.isAuthenticated ? 'Publier' : 'Se connecter'),
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
    if (!_authService.isAuthenticated) {
      _showAuthScreen();
      return;
    }

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.upload),
            const SizedBox(width: 8),
            const Text('Publier votre pattern'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Publié par: ${_authService.userName}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du pattern *',
                  hintText: 'Ex: Glider, Oscillateur symétrique...',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Décrivez votre pattern...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Votre pattern actuel sera partagé avec la communauté',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => _uploadPattern(
              nameController.text.trim(),
              descriptionController.text.trim().isEmpty 
                ? null 
                : descriptionController.text.trim(),
            ),
            child: const Text('Publier'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPattern(String name, String? description) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom du pattern est requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_authService.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour publier'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    try {
      final pattern = widget.engine.exportPattern();
      
      // Utiliser le nom d'utilisateur authentifié comme auteur
      final author = _authService.userName ?? _authService.userEmail;
      
      await _patternService.uploadPattern(name, author, pattern, description: description);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pattern "$name" publié avec succès !'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Voir',
              onPressed: _loadPatterns,
            ),
          ),
        );
      }
      
      _loadPatterns();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la publication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAuthScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthScreen(
          onAuthSuccess: () {
            setState(() {}); // Rafraîchir l'UI après connexion
          },
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        setState(() {}); // Rafraîchir l'UI après déconnexion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnecté avec succès'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
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