class MemoryEstimator {
  // Memory usage estimation for different components
  static const int bytesPerCell = 1; // uint8 for each cell
  static const int bytesPerBoolInList = 8; // Dart List<bool> overhead
  static const int listOverheadBytes = 24; // List object overhead
  static const int streamBufferMultiplier = 3; // Stream buffers and copies
  static const int uiRenderingMultiplier = 2; // UI rendering overhead
  static const double safetyMargin = 1.5; // 50% safety margin
  
  // Calculate total RAM usage for a grid
  static MemoryUsage calculateMemoryUsage(int width, int height) {
    final totalCells = width * height;
    
    // Core grid storage (flat array)
    final coreGridBytes = totalCells * bytesPerCell;
    
    // 2D grid representation for UI (List<List<bool>>)
    final uiGridBytes = (totalCells * bytesPerBoolInList) + (height * listOverheadBytes);
    
    // Stream buffers (multiple copies for broadcasting)
    final streamBytes = (coreGridBytes + uiGridBytes) * streamBufferMultiplier;
    
    // UI rendering overhead (widgets, painting, etc.)
    final renderingBytes = (coreGridBytes + uiGridBytes) * uiRenderingMultiplier;
    
    // Native engine temporary buffer (for computation)
    final nativeBufferBytes = coreGridBytes; // Temporary buffer in C
    
    // Total estimated usage
    final rawTotal = coreGridBytes + uiGridBytes + streamBytes + renderingBytes + nativeBufferBytes;
    final totalWithSafety = (rawTotal * safetyMargin).round();
    
    return MemoryUsage(
      width: width,
      height: height,
      totalCells: totalCells,
      coreGridBytes: coreGridBytes,
      uiGridBytes: uiGridBytes,
      streamBytes: streamBytes,
      renderingBytes: renderingBytes,
      nativeBufferBytes: nativeBufferBytes,
      rawTotalBytes: rawTotal,
      totalBytesWithSafety: totalWithSafety,
    );
  }
  
  // Get warning level based on memory usage
  static WarningLevel getWarningLevel(int totalBytes) {
    const mb = 1024 * 1024;
    
    if (totalBytes < 10 * mb) {
      return WarningLevel.safe;
    } else if (totalBytes < 50 * mb) {
      return WarningLevel.caution;
    } else if (totalBytes < 100 * mb) {
      return WarningLevel.warning;
    } else {
      return WarningLevel.danger;
    }
  }
  
  // Get recommended grid sizes
  static List<GridSize> getRecommendedSizes() {
    return [
      GridSize(50, 30, 'Small (Phone)'),
      GridSize(80, 50, 'Medium (Tablet)'),
      GridSize(120, 80, 'Large (Desktop)'),
      GridSize(200, 150, 'Extra Large'),
      GridSize(400, 300, 'Huge (High-end)'),
      GridSize(800, 600, 'Extreme (Workstation)'),
    ];
  }
  
  // Format bytes for human reading
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  // Get performance estimation
  static String getPerformanceEstimate(int width, int height) {
    final totalCells = width * height;
    
    if (totalCells <= 2500) {
      return 'Excellent performance expected';
    } else if (totalCells <= 10000) {
      return 'Good performance, may benefit from AVX2';
    } else if (totalCells <= 50000) {
      return 'Moderate performance, AVX2 recommended';
    } else if (totalCells <= 200000) {
      return 'Slower performance, powerful device needed';
    } else {
      return 'Very slow, high-end device required';
    }
  }
}

class MemoryUsage {
  final int width;
  final int height;
  final int totalCells;
  final int coreGridBytes;
  final int uiGridBytes;
  final int streamBytes;
  final int renderingBytes;
  final int nativeBufferBytes;
  final int rawTotalBytes;
  final int totalBytesWithSafety;
  
  const MemoryUsage({
    required this.width,
    required this.height,
    required this.totalCells,
    required this.coreGridBytes,
    required this.uiGridBytes,
    required this.streamBytes,
    required this.renderingBytes,
    required this.nativeBufferBytes,
    required this.rawTotalBytes,
    required this.totalBytesWithSafety,
  });
  
  WarningLevel get warningLevel => MemoryEstimator.getWarningLevel(totalBytesWithSafety);
  String get formattedTotal => MemoryEstimator.formatBytes(totalBytesWithSafety);
  String get performanceEstimate => MemoryEstimator.getPerformanceEstimate(width, height);
}

class GridSize {
  final int width;
  final int height;
  final String label;
  
  const GridSize(this.width, this.height, this.label);
  
  int get totalCells => width * height;
  MemoryUsage get memoryUsage => MemoryEstimator.calculateMemoryUsage(width, height);
}

enum WarningLevel {
  safe,
  caution,
  warning,
  danger,
}