# Makefile for AVX2 Engine Native Library

CC = gcc
WIN_CC = x86_64-w64-mingw32-gcc
CFLAGS = -Wall -Wextra -O3 -fPIC -shared
WIN_CFLAGS = -Wall -Wextra -O3 -shared
TARGET = libavx2_engine.so
DLL_TARGET = avx2_engine.dll
SOURCE = avx2_engine.c

# Default target
all: $(TARGET)

# Build the shared library (Linux/WSL)
$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

# Build Windows DLL
dll: $(DLL_TARGET)

$(DLL_TARGET): $(SOURCE)
	$(WIN_CC) $(WIN_CFLAGS) -o $(DLL_TARGET) $(SOURCE)

# Build both Linux and Windows versions
both: $(TARGET) $(DLL_TARGET)

# Clean build artifacts
clean:
	rm -f $(TARGET) $(DLL_TARGET) libavx2_engine.a

# Install library (optional)
install: $(TARGET)
	sudo cp $(TARGET) /usr/local/lib/
	sudo ldconfig

# For future AVX2 optimization
avx2: CFLAGS += -mavx2 -DUSE_AVX2
avx2: $(TARGET)

# AVX2 DLL
avx2-dll: CFLAGS += -mavx2 -DUSE_AVX2
avx2-dll: $(DLL_TARGET)

.PHONY: all dll both clean install avx2 avx2-dll