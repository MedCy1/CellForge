import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/optimized_pattern.dart';

class PatternModel {
  final String id;
  final String name;
  final String? author;
  final String? description;
  final OptimizedPattern pattern;
  final DateTime createdAt;

  PatternModel({
    required this.id,
    required this.name,
    this.author,
    this.description,
    required this.pattern,
    required this.createdAt,
  });

  /// Constructeur à partir d'une grille
  PatternModel.fromGrid({
    required this.id,
    required this.name,
    this.author,
    this.description,
    required List<List<bool>> data,
    required this.createdAt,
  }) : pattern = OptimizedPattern.fromGrid(data);

  /// Convertir vers une grille pour l'affichage
  List<List<bool>> toGrid({int? width, int? height}) => pattern.toGrid(targetWidth: width, targetHeight: height);

  /// Obtenir les dimensions du pattern
  ({int width, int height}) get bounds => pattern.bounds;

  /// Nombre de cellules vivantes
  int get aliveCellCount => pattern.aliveCellCount;

  factory PatternModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final pattern = OptimizedPattern.fromJson(data);

    return PatternModel(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String?,
      description: json['description'] as String?,
      pattern: pattern,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson({String? userId}) {
    final json = {
      'name': name,
      'author': author,
      'description': description,
      'data': pattern.toJson(),
    };
    
    if (userId != null) {
      json['user_id'] = userId;
    }
    
    return json;
  }
}

class PatternService {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  bool get isSupabaseAvailable => _client != null;

  Future<List<PatternModel>> getPatterns() async {
    if (!isSupabaseAvailable) {
      throw Exception('Workshop hors ligne - Supabase non configuré');
    }

    try {
      final response = await _client!
          .from('patterns')
          .select()
          .order('created_at', ascending: false);

      final patterns = (response as List)
          .map((json) => PatternModel.fromJson(json))
          .toList();

      return patterns;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des patterns: $e');
    }
  }

  Future<void> uploadPattern(
    String name,
    String? author,
    List<List<bool>> data, {
    String? description,
  }) async {
    if (!isSupabaseAvailable) {
      throw Exception('Workshop hors ligne - Supabase non configuré');
    }

    if (name.isEmpty) {
      throw Exception('Le nom du pattern est requis');
    }

    if (data.isEmpty || data.every((row) => row.every((cell) => !cell))) {
      throw Exception('Le pattern ne peut pas être vide');
    }

    try {
      final pattern = PatternModel.fromGrid(
        id: '',
        name: name,
        author: author,
        description: description,
        data: data,
        createdAt: DateTime.now(),
      );

      // Récupérer l'ID de l'utilisateur connecté
      final currentUser = _client!.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Vous devez être connecté pour publier un pattern');
      }

      await _client!.from('patterns').insert(pattern.toJson(userId: currentUser.id));
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du pattern: $e');
    }
  }

  Future<PatternModel?> getPattern(String id) async {
    if (!isSupabaseAvailable) {
      throw Exception('Workshop hors ligne - Supabase non configuré');
    }

    try {
      final response = await _client!
          .from('patterns')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      
      return PatternModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du pattern: $e');
    }
  }

  Future<List<PatternModel>> searchPatterns(String query) async {
    if (!isSupabaseAvailable) {
      throw Exception('Workshop hors ligne - Supabase non configuré');
    }

    try {
      final response = await _client!
          .from('patterns')
          .select()
          .or('name.ilike.%$query%,author.ilike.%$query%')
          .order('created_at', ascending: false);

      final patterns = (response as List)
          .map((json) => PatternModel.fromJson(json))
          .toList();

      return patterns;
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  static List<PatternModel> getBuiltInPatterns() {
    return [
      PatternModel.fromGrid(
        id: 'glider',
        name: 'Glider',
        author: 'Conway',
        data: [
          [false, true, false],
          [false, false, true],
          [true, true, true],
        ],
        createdAt: DateTime.now(),
      ),
      PatternModel.fromGrid(
        id: 'blinker',
        name: 'Blinker',
        author: 'Conway',
        data: [
          [true, true, true],
        ],
        createdAt: DateTime.now(),
      ),
      PatternModel.fromGrid(
        id: 'beacon',
        name: 'Beacon',
        author: 'Conway',
        data: [
          [true, true, false, false],
          [true, true, false, false],
          [false, false, true, true],
          [false, false, true, true],
        ],
        createdAt: DateTime.now(),
      ),
      PatternModel.fromGrid(
        id: 'toad',
        name: 'Toad',
        author: 'Conway',
        data: [
          [false, true, true, true],
          [true, true, true, false],
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }
}