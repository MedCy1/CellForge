import 'dart:async';

abstract class ILifeEngine {
  Stream<List<List<bool>>> get gridStream;
  Stream<int> get generationStream;
  
  bool get isRunning;
  int get width;
  int get height;
  int get generation;
  Duration get generationInterval;
  
  bool getCellState(int x, int y);
  void setCellState(int x, int y, bool isAlive);
  void toggleCell(int x, int y);
  void clearGrid();
  void randomizeGrid({double probability = 0.3});
  void setGenerationInterval(Duration interval);
  void start();
  void stop();
  void toggle();
  void nextGeneration();
  void loadPattern(List<List<bool>> pattern, {int? startX, int? startY});
  List<List<bool>> exportPattern();
  List<List<bool>> getCurrentGrid();
  void resizeGrid(int newWidth, int newHeight);
  void dispose();
}