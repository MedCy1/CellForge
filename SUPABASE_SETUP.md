# Configuration Supabase pour CellForge

## Structure de la base de données

Voici la structure SQL à créer dans votre projet Supabase :

```sql
-- Créer la table patterns
CREATE TABLE patterns (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  author VARCHAR(255),
  description TEXT,
  data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Créer un index pour les recherches
CREATE INDEX idx_patterns_name ON patterns(name);
CREATE INDEX idx_patterns_author ON patterns(author);
CREATE INDEX idx_patterns_created_at ON patterns(created_at DESC);

-- Politique de sécurité pour permettre la lecture publique
CREATE POLICY "Patterns are viewable by everyone" 
  ON patterns FOR SELECT 
  USING (true);

-- Politique de sécurité pour permettre l'insertion aux utilisateurs authentifiés
CREATE POLICY "Users can insert their own patterns" 
  ON patterns FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs de mettre à jour leurs propres patterns
CREATE POLICY "Users can update their own patterns" 
  ON patterns FOR UPDATE 
  USING (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs de supprimer leurs propres patterns
CREATE POLICY "Users can delete their own patterns" 
  ON patterns FOR DELETE 
  USING (auth.uid() = user_id);

-- Activer RLS (Row Level Security)
ALTER TABLE patterns ENABLE ROW LEVEL SECURITY;
```

## Variables d'environnement

1. Copiez `.env.example` vers `.env`
2. Ajoutez vos informations Supabase dans le fichier `.env` :
   ```
   SUPABASE_URL=https://votre-projet.supabase.co
   SUPABASE_KEY=votre-cle-anon-ici
   ```
3. Utilisez la commande suivante pour lancer l'app avec les variables :

```bash
flutter run --dart-define-from-file=.env
```

Ou pour un build :

```bash
flutter build apk --dart-define-from-file=.env
```

## Fonctionnalités implémentées

- ✅ Authentification avec email/mot de passe
- ✅ Publication de patterns (authentification requise)
- ✅ Consultation de patterns (accès libre)
- ✅ Gestion des comptes utilisateurs
- ✅ Interface moderne et responsive

## Notes importantes

- L'application fonctionne même sans Supabase (mode offline)
- Les patterns intégrés sont toujours disponibles
- Seule la publication nécessite une authentification