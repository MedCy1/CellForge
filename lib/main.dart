import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/game/presentation/game_controller.dart';
import 'features/game/presentation/widgets/game_app_bar.dart';
import 'features/game/presentation/widgets/built_in_patterns_panel.dart';
import 'ui/grid.dart';
import 'ui/toolbar.dart';
import 'ui/workshop_browser.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const supabaseKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Supabase seulement si l'URL et la clé sont fournies
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
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
  late GameController _gameController;

  @override
  void initState() {
    super.initState();
    _gameController = GameController();
    
    // Écouter les changements du contrôleur pour les notifications
    _gameController.addListener(_onGameControllerChanged);
  }

  void _onGameControllerChanged() {
    // Gérer les notifications comme les changements de moteur
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _gameController.removeListener(_onGameControllerChanged);
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        onPatternsPressed: _gameController.toggleBuiltInPatterns,
        onWorkshopPressed: _openWorkshop,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          if (isWide) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainerLowest,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Panneau latéral avec design amélioré
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        LifeToolbar(engine: _gameController.engine),
                        if (_gameController.showBuiltInPatterns) 
                          Expanded(
                            child: BuiltInPatternsPanel(
                              patterns: _gameController.getBuiltInPatterns(),
                              onPatternSelected: _loadPattern,
                              onClose: _gameController.hideBuiltInPatterns,
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  
                  // Zone principale de la grille
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LifeGrid(engine: _gameController.engine),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainerLowest,
                  ],
                ),
              ),
              child: Column(
                children: [
                  LifeToolbar(engine: _gameController.engine),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LifeGrid(engine: _gameController.engine),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _loadPattern(pattern) {
    _gameController.loadPattern(pattern);
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
        builder: (context) => WorkshopBrowser(engine: _gameController.engine),
      ),
    );
  }
}