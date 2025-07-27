import 'package:supabase_flutter/supabase_flutter.dart';

class PatternModel {
  final String id;
  final String name;
  final String? author;
  final List<List<bool>> data;
  final DateTime createdAt;

  PatternModel({
    required this.id,
    required this.name,
    this.author,
    required this.data,
    required this.createdAt,
  });

  factory PatternModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List;
    final grid = data.map((row) {
      final rowList = row as List;
      return rowList.map((cell) => cell as bool).toList();
    }).toList();

    return PatternModel(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String?,
      data: grid,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author': author,
      'data': data,
    };
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
    List<List<bool>> data,
  ) async {
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
      final pattern = PatternModel(
        id: '',
        name: name,
        author: author,
        data: data,
        createdAt: DateTime.now(),
      );

      await _client!.from('patterns').insert(pattern.toJson());
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
      PatternModel(
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
      PatternModel(
        id: 'blinker',
        name: 'Blinker',
        author: 'Conway',
        data: [
          [true, true, true],
        ],
        createdAt: DateTime.now(),
      ),
      PatternModel(
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
      PatternModel(
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