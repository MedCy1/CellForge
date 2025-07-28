import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const _supabaseKey = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');

class AuthService {
  static final _client = Supabase.instance.client;
  
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  // Getters
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userEmail => currentUser?.email;
  String? get userName => currentUser?.userMetadata?['display_name'] ?? userEmail?.split('@').first;
  
  // Stream pour écouter les changements d'état
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Inscription
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Connexion
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Déconnexion
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
  
  // Mettre à jour le profil
  Future<UserResponse> updateProfile({
    String? displayName,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          data: displayName != null ? {'display_name': displayName} : null,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Vérifier si Supabase est disponible
  static bool get isSupabaseAvailable {
    return _supabaseUrl.isNotEmpty && _supabaseKey.isNotEmpty;
  }
}