# Makefile for AVX2 Engine Native Library

CC = gcc
CFLAGS = -Wall -Wextra -O3 -fPIC -shared
TARGET = libavx2_engine.so
SOURCE = avx2_engine.c

# Default target
all: $(TARGET)

# Build the shared library
$(TARGET): $(SOURCE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCE)

# Clean build artifacts
clean:
	rm -f $(TARGET)

# Install library (optional)
install: $(TARGET)
	sudo cp $(TARGET) /usr/local/lib/
	sudo ldconfig

# For future AVX2 optimization
avx2: CFLAGS += -mavx2 -DUSE_AVX2
avx2: $(TARGET)

.PHONY: all clean install avx2