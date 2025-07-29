# Makefile for AVX2 Engine Native Library with Performance Optimizations

CC = gcc
WIN_CC = x86_64-w64-mingw32-gcc
BASE_CFLAGS = -Wall -Wextra -O3 -fPIC -std=c99
CFLAGS = $(BASE_CFLAGS) -shared -mavx2 -mfma -march=native -funroll-loops
WIN_CFLAGS = $(BASE_CFLAGS) -shared -mavx2 -mfma -funroll-loops -D_WIN32
TARGET = libavx2_engine.so
DLL_TARGET = avx2_engine.dll
SOURCE = avx2_engine.c

# Default target with AVX2 optimizations
all: $(TARGET)

# Build the shared library (Linux/WSL) with AVX2
$(TARGET): $(SOURCE)
	@echo "Building optimized AVX2 library with flags: $(CFLAGS)"
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)
	@echo "Successfully built $(TARGET) with AVX2 optimizations"

# Build Windows DLL with AVX2
dll: $(DLL_TARGET)

$(DLL_TARGET): $(SOURCE)
	@echo "Building Windows DLL with AVX2 optimizations..."
	$(WIN_CC) $(WIN_CFLAGS) -o $(DLL_TARGET) $(SOURCE)
	@echo "Successfully built $(DLL_TARGET)"

# Build both Linux and Windows versions
both: $(TARGET) $(DLL_TARGET)

# Fallback build without AVX2 (for older CPUs)
fallback: CFLAGS = $(BASE_CFLAGS) -shared -O3
fallback: $(TARGET)
	@echo "Built fallback version without AVX2"

# Debug build with sanitizers
debug: CFLAGS = $(BASE_CFLAGS) -shared -g -DDEBUG -fsanitize=address -mavx2
debug: $(TARGET)
	@echo "Built debug version with AddressSanitizer"

# Performance optimized build
performance: CFLAGS = $(BASE_CFLAGS) -shared -Ofast -mavx2 -mfma -march=native -funroll-loops -flto -ffast-math
performance: LDFLAGS = -flto
performance: $(TARGET)
	@echo "Built high-performance version with aggressive optimizations"

# Clean build artifacts
clean:
	rm -f $(TARGET) $(DLL_TARGET) libavx2_engine.a *.o

# Install library (optional)
install: $(TARGET)
	sudo cp $(TARGET) /usr/local/lib/
	sudo ldconfig
	@echo "Installed $(TARGET) to system library path"

# Test build by checking for AVX2 symbols
test: $(TARGET)
	@echo "Testing library for AVX2 symbols..."
	@objdump -t $(TARGET) | grep -i avx && echo "AVX2 symbols found" || echo "No AVX2 symbols (may be inlined)"
	@file $(TARGET)

# Check CPU features
check-cpu:
	@echo "Checking CPU features..."
	@grep -i avx2 /proc/cpuinfo && echo "AVX2 supported" || echo "AVX2 not supported"

.PHONY: all dll both fallback debug performance clean install test check-cpu