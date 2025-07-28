/// Représente une cellule vivante avec ses coordonnées
class LiveCell {
  final int x;
  final int y;
  
  const LiveCell(this.x, this.y);
  
  Map<String, dynamic> toJson() => {'x': x, 'y': y};
  
  factory LiveCell.fromJson(Map<String, dynamic> json) {
    return LiveCell(json['x'] as int, json['y'] as int);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiveCell && other.x == x && other.y == y;
  }
  
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
  
  @override
  String toString() => 'LiveCell($x, $y)';
}

/// Format optimisé pour stocker un pattern du Jeu de la Vie
class OptimizedPattern {
  final List<LiveCell> liveCells;
  final int? width;  // Optionnel : largeur de la zone de travail
  final int? height; // Optionnel : hauteur de la zone de travail
  
  const OptimizedPattern({
    required this.liveCells,
    this.width,
    this.height,
  });
  
  /// Créer un pattern optimisé à partir d'une grille traditionnelle
  factory OptimizedPattern.fromGrid(List<List<bool>> grid) {
    final liveCells = <LiveCell>[];
    
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
        if (grid[y][x]) {
          liveCells.add(LiveCell(x, y));
        }
      }
    }
    
    return OptimizedPattern(
      liveCells: liveCells,
      width: grid.isNotEmpty ? grid[0].length : 0,
      height: grid.length,
    );
  }
  
  /// Convertir vers une grille traditionnelle
  List<List<bool>> toGrid({int? targetWidth, int? targetHeight}) {
    if (liveCells.isEmpty) {
      return List.generate(
        targetHeight ?? height ?? 1,
        (y) => List.generate(targetWidth ?? width ?? 1, (x) => false),
      );
    }
    
    // Calculer les dimensions minimales nécessaires
    final minX = liveCells.map((cell) => cell.x).reduce((a, b) => a < b ? a : b);
    final maxX = liveCells.map((cell) => cell.x).reduce((a, b) => a > b ? a : b);
    final minY = liveCells.map((cell) => cell.y).reduce((a, b) => a < b ? a : b);
    final maxY = liveCells.map((cell) => cell.y).reduce((a, b) => a > b ? a : b);
    
    final requiredWidth = maxX - minX + 1;
    final requiredHeight = maxY - minY + 1;
    
    final gridWidth = targetWidth ?? width ?? requiredWidth;
    final gridHeight = targetHeight ?? height ?? requiredHeight;
    
    // Créer la grille vide
    final grid = List.generate(
      gridHeight,
      (y) => List.generate(gridWidth, (x) => false),
    );
    
    // Calculer l'offset pour centrer le pattern
    final offsetX = targetWidth != null ? 
        ((targetWidth - requiredWidth) / 2).floor() - minX : -minX;
    final offsetY = targetHeight != null ? 
        ((targetHeight - requiredHeight) / 2).floor() - minY : -minY;
    
    // Placer les cellules vivantes
    for (final cell in liveCells) {
      final x = cell.x + offsetX;
      final y = cell.y + offsetY;
      
      if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
        grid[y][x] = true;
      }
    }
    
    return grid;
  }
  
  /// Obtenir les dimensions du pattern
  ({int width, int height}) get bounds {
    if (liveCells.isEmpty) return (width: 0, height: 0);
    
    final minX = liveCells.map((cell) => cell.x).reduce((a, b) => a < b ? a : b);
    final maxX = liveCells.map((cell) => cell.x).reduce((a, b) => a > b ? a : b);
    final minY = liveCells.map((cell) => cell.y).reduce((a, b) => a < b ? a : b);
    final maxY = liveCells.map((cell) => cell.y).reduce((a, b) => a > b ? a : b);
    
    return (width: maxX - minX + 1, height: maxY - minY + 1);
  }
  
  /// Nombre de cellules vivantes
  int get aliveCellCount => liveCells.length;
  
  /// Vérifier si le pattern est vide
  bool get isEmpty => liveCells.isEmpty;
  
  /// Décaler le pattern
  OptimizedPattern translate(int deltaX, int deltaY) {
    return OptimizedPattern(
      liveCells: liveCells.map((cell) => LiveCell(cell.x + deltaX, cell.y + deltaY)).toList(),
      width: width,
      height: height,
    );
  }
  
  /// Normaliser le pattern (déplacer vers l'origine)
  OptimizedPattern normalize() {
    if (liveCells.isEmpty) return this;
    
    final minX = liveCells.map((cell) => cell.x).reduce((a, b) => a < b ? a : b);
    final minY = liveCells.map((cell) => cell.y).reduce((a, b) => a < b ? a : b);
    
    return translate(-minX, -minY);
  }
  
  /// Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'live_cells': liveCells.map((cell) => cell.toJson()).toList(),
      'width': width,
      'height': height,
    };
  }
  
  /// Désérialisation JSON
  factory OptimizedPattern.fromJson(Map<String, dynamic> json) {
    final liveCellsData = json['live_cells'] as List;
    final liveCells = liveCellsData.map((cellData) => LiveCell.fromJson(cellData)).toList();
    
    return OptimizedPattern(
      liveCells: liveCells,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }
  
  @override
  String toString() {
    final bounds = this.bounds;
    return 'OptimizedPattern(${liveCells.length} cells, ${bounds.width}×${bounds.height})';
  }
}