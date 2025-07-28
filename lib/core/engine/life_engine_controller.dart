import 'i_life_engine.dart';
import 'bruteforce_engine.dart';

class LifeEngineController {
  ILifeEngine _engine;
  
  LifeEngineController({ILifeEngine? engine}) 
    : _engine = engine ?? BruteforceEngine();
  
  Stream<List<List<bool>>> get gridStream => _engine.gridStream;
  Stream<int> get generationStream => _engine.generationStream;
  
  bool get isRunning => _engine.isRunning;
  int get width => _engine.width;
  int get height => _engine.height;
  int get generation => _engine.generation;
  Duration get generationInterval => _engine.generationInterval;
  
  bool getCellState(int x, int y) => _engine.getCellState(x, y);
  void setCellState(int x, int y, bool isAlive) => _engine.setCellState(x, y, isAlive);
  void toggleCell(int x, int y) => _engine.toggleCell(x, y);
  void clearGrid() => _engine.clearGrid();
  void randomizeGrid({double probability = 0.3}) => _engine.randomizeGrid(probability: probability);
  void setGenerationInterval(Duration interval) => _engine.setGenerationInterval(interval);
  void start() => _engine.start();
  void stop() => _engine.stop();
  void toggle() => _engine.toggle();
  void nextGeneration() => _engine.nextGeneration();
  void loadPattern(List<List<bool>> pattern, {int? startX, int? startY}) => 
    _engine.loadPattern(pattern, startX: startX, startY: startY);
  List<List<bool>> exportPattern() => _engine.exportPattern();
  List<List<bool>> getCurrentGrid() => _engine.getCurrentGrid();
  void resizeGrid(int newWidth, int newHeight) => _engine.resizeGrid(newWidth, newHeight);
  void dispose() => _engine.dispose();
  
  void switchEngine(ILifeEngine newEngine) {
    final oldGrid = _engine.getCurrentGrid();
    final wasRunning = _engine.isRunning;
    
    _engine.dispose();
    _engine = newEngine;
    
    _engine.loadPattern(oldGrid);
    
    if (wasRunning) {
      _engine.start();
    }
  }
  
  ILifeEngine get currentEngine => _engine;
}