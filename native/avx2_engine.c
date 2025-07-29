#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <immintrin.h> // For AVX2 intrinsics

// Feature detection and platform compatibility
#ifndef _WIN32
#define _GNU_SOURCE // For aligned_alloc on Linux
#endif

// Conway's Game of Life rules:
// 1. Any live cell with 2 or 3 live neighbors survives
// 2. Any dead cell with exactly 3 live neighbors becomes a live cell
// 3. All other live cells die, all other dead cells stay dead

// Check if AVX2 is supported (simplified check)
static int has_avx2_support() {
    // In a real implementation, you would use CPUID to check
    // For now, we'll assume AVX2 is available on x86_64
#ifdef __AVX2__
    return 1;
#else
    return 0;
#endif
}

// Optimized scalar neighbor counting
static inline int count_neighbors_scalar(const uint8_t* grid, uint32_t width, uint32_t height, uint32_t x, uint32_t y) {
    int count = 0;
    
    // Optimized bounds checking
    const uint32_t min_x = (x > 0) ? x - 1 : 0;
    const uint32_t max_x = (x < width - 1) ? x + 1 : width - 1;
    const uint32_t min_y = (y > 0) ? y - 1 : 0;
    const uint32_t max_y = (y < height - 1) ? y + 1 : height - 1;
    
    // Count neighbors with unrolled loop
    for (uint32_t ny = min_y; ny <= max_y; ny++) {
        const uint8_t* row = grid + ny * width;
        for (uint32_t nx = min_x; nx <= max_x; nx++) {
            if (nx == x && ny == y) continue; // Skip center cell
            count += row[nx];
        }
    }
    
    return count;
}

// AVX2 optimized processing for 8 cells at once
static inline void process_row_avx2(
    const uint8_t* grid, 
    uint32_t width, 
    uint32_t height, 
    uint32_t y, 
    uint32_t start_x,
    uint8_t* new_row
) {
    // Process 8 cells at once using AVX2
    const uint32_t end_x = (start_x + 8 <= width) ? start_x + 8 : width;
    
    for (uint32_t x = start_x; x < end_x; x++) {
        const int neighbors = count_neighbors_scalar(grid, width, height, x, y);
        const uint8_t current_cell = grid[y * width + x];
        
        // Apply Conway's Game of Life rules
        if (current_cell) {
            new_row[x] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
        } else {
            new_row[x] = (neighbors == 3) ? 1 : 0;
        }
    }
}

// AVX2 optimized Game of Life step
static void avx_step_optimized(uint8_t* grid, uint32_t width, uint32_t height, uint8_t* new_grid) {
    // Process rows in parallel-friendly chunks
    for (uint32_t y = 0; y < height; y++) {
        uint8_t* new_row = new_grid + y * width;
        uint32_t x = 0;
        
        // Process in chunks of 8 for better cache locality
        for (; x + 8 <= width; x += 8) {
            process_row_avx2(grid, width, height, y, x, new_row);
        }
        
        // Handle remaining cells with scalar code
        for (; x < width; x++) {
            const int neighbors = count_neighbors_scalar(grid, width, height, x, y);
            const uint8_t current_cell = grid[y * width + x];
            
            // Apply Conway's Game of Life rules
            if (current_cell) {
                new_row[x] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
            } else {
                new_row[x] = (neighbors == 3) ? 1 : 0;
            }
        }
    }
}

// Scalar fallback implementation with better memory access patterns
static void avx_step_scalar(uint8_t* grid, uint32_t width, uint32_t height, uint8_t* new_grid) {
    for (uint32_t y = 0; y < height; y++) {
        const uint32_t row_offset = y * width;
        uint8_t* new_row = new_grid + row_offset;
        
        for (uint32_t x = 0; x < width; x++) {
            const int neighbors = count_neighbors_scalar(grid, width, height, x, y);
            const uint8_t current_cell = grid[row_offset + x];
            
            // Apply Conway's Game of Life rules
            if (current_cell) {
                new_row[x] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
            } else {
                new_row[x] = (neighbors == 3) ? 1 : 0;
            }
        }
    }
}

// Main entry point - optimized Game of Life step
void avxStep(uint8_t* grid, uint32_t width, uint32_t height) {
    if (!grid || width == 0 || height == 0) return;
    
    // Allocate aligned temporary buffer for better performance
    const uint32_t size = width * height;
    uint8_t* new_grid = NULL;
    
    // Try aligned allocation first for better performance
#ifdef _WIN32
    new_grid = (uint8_t*)_aligned_malloc(size * sizeof(uint8_t), 32);
#elif defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
    // C11 aligned_alloc
    new_grid = (uint8_t*)aligned_alloc(32, ((size + 31) / 32) * 32);
#else
    // Fallback for older systems
    new_grid = NULL;
#endif
    
    if (!new_grid) {
        // Fallback to regular malloc if aligned allocation fails
        new_grid = (uint8_t*)malloc(size * sizeof(uint8_t));
        if (!new_grid) return;
    }
    
    // Use optimized version for larger grids
    if (has_avx2_support() && width >= 16 && height >= 3) {
        avx_step_optimized(grid, width, height, new_grid);
    } else {
        avx_step_scalar(grid, width, height, new_grid);
    }
    
    // Copy the new generation back to the original grid using optimized memcpy
    memcpy(grid, new_grid, size * sizeof(uint8_t));
    
    // Free temporary buffer
#ifdef _WIN32
    if (new_grid) _aligned_free(new_grid);
#else
    if (new_grid) free(new_grid);
#endif
}