import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/life_engine.dart';
import 'ui/grid.dart';
import 'ui/toolbar.dart';
import 'ui/workshop_browser.dart';
import 'services/pattern_service.dart';

const supabaseUrl = 'https://kkmrfxrgmxcqzuecvyif.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Supabase seulement si la clé est fournie
  if (supabaseKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }
  
  runApp(const CellForgeApp());
}

class CellForgeApp extends StatelessWidget {
  const CellForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CellForge',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const GameOfLifeScreen(),
    );
  }
}

class GameOfLifeScreen extends StatefulWidget {
  const GameOfLifeScreen({super.key});

  @override
  State<GameOfLifeScreen> createState() => _GameOfLifeScreenState();
}

class _GameOfLifeScreenState extends State<GameOfLifeScreen> {
  late LifeEngine _engine;
  bool _showBuiltInPatterns = false;

  @override
  void initState() {
    super.initState();
    _engine = LifeEngine(width: 80, height: 50);
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧬 CellForge'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [
          IconButton(
            onPressed: _showBuiltInPatternsDialog,
            icon: const Icon(Icons.apps),
            tooltip: 'Patterns intégrés',
          ),
          IconButton(
            onPressed: _openWorkshop,
            icon: const Icon(Icons.cloud),
            tooltip: 'Workshop en ligne',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      LifeToolbar(engine: _engine),
                      const SizedBox(height: 8),
                      if (_showBuiltInPatterns) _buildBuiltInPatterns(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LifeGrid(engine: _engine),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                LifeToolbar(engine: _engine),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LifeGrid(engine: _engine),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildBuiltInPatterns() {
    final patterns = PatternService.getBuiltInPatterns();
    
    return Expanded(
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.apps, size: 20),
                  const SizedBox(width: 8),
                  const Text('Patterns classiques'),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showBuiltInPatterns = false;
                      });
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: patterns.length,
                itemBuilder: (context, index) {
                  final pattern = patterns[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.grid_on, size: 20),
                    title: Text(pattern.name),
                    subtitle: Text('Par ${pattern.author}'),
                    onTap: () => _loadPattern(pattern),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuiltInPatternsDialog() {
    setState(() {
      _showBuiltInPatterns = !_showBuiltInPatterns;
    });
  }

  void _loadPattern(PatternModel pattern) {
    _engine.loadPattern(pattern.data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pattern "${pattern.name}" chargé'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openWorkshop() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkshopBrowser(engine: _engine),
      ),
    );
  }
}