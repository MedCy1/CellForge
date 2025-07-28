#include <stdint.h>
#include <string.h>
#include <stdlib.h>

// Conway's Game of Life rules:
// 1. Any live cell with 2 or 3 live neighbors survives
// 2. Any dead cell with exactly 3 live neighbors becomes a live cell
// 3. All other live cells die, all other dead cells stay dead

// Count neighbors for a cell at position (x, y)
static inline int count_neighbors(const uint8_t* grid, uint32_t width, uint32_t height, uint32_t x, uint32_t y) {
    int count = 0;
    
    // Check all 8 neighbors
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            // Skip the center cell
            if (dx == 0 && dy == 0) continue;
            
            int nx = (int)x + dx;
            int ny = (int)y + dy;
            
            // Check bounds
            if (nx >= 0 && nx < (int)width && ny >= 0 && ny < (int)height) {
                count += grid[ny * width + nx];
            }
        }
    }
    
    return count;
}

// Apply one generation of Conway's Game of Life
// grid: pointer to 1D uint8_t array representing 2D grid (row-major order)
// width: width of the grid
// height: height of the grid
// Note: This modifies the grid in-place, so we need a temporary buffer
void avxStep(uint8_t* grid, uint32_t width, uint32_t height) {
    if (!grid || width == 0 || height == 0) return;
    
    // Allocate temporary buffer for the new generation
    uint32_t size = width * height;
    uint8_t* new_grid = (uint8_t*)malloc(size * sizeof(uint8_t));
    if (!new_grid) return;
    
    // Process each cell
    for (uint32_t y = 0; y < height; y++) {
        for (uint32_t x = 0; x < width; x++) {
            uint32_t index = y * width + x;
            int neighbors = count_neighbors(grid, width, height, x, y);
            uint8_t current_cell = grid[index];
            
            // Apply Conway's Game of Life rules
            if (current_cell) {
                // Live cell: survives with 2 or 3 neighbors, dies otherwise
                new_grid[index] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
            } else {
                // Dead cell: becomes alive with exactly 3 neighbors
                new_grid[index] = (neighbors == 3) ? 1 : 0;
            }
        }
    }
    
    // Copy the new generation back to the original grid
    memcpy(grid, new_grid, size * sizeof(uint8_t));
    
    // Free temporary buffer
    free(new_grid);
}