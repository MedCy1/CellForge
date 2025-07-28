#!/bin/bash
# Build script for AVX2 native engine

echo "🔨 Building AVX2 native engine..."

# Navigate to native directory
cd "$(dirname "$0")/native"

# Clean previous build
echo "🧹 Cleaning previous build..."
make clean 2>/dev/null || true

# Build the library
echo "⚙️  Compiling native library..."
if make both; then
    echo "✅ Native libraries built successfully!"
    echo "📄 Created: $(pwd)/libavx2_engine.so (Linux)"
    echo "📄 Created: $(pwd)/avx2_engine.dll (Windows)"
    
    # Check file sizes
    if [ -f libavx2_engine.so ]; then
        size_so=$(ls -lh libavx2_engine.so | awk '{print $5}')
        echo "📊 Linux library size: $size_so"
    fi
    if [ -f avx2_engine.dll ]; then
        size_dll=$(ls -lh avx2_engine.dll | awk '{print $5}')
        echo "📊 Windows library size: $size_dll"
    fi
    
    echo ""
    echo "🚀 Ready to test! Run:"
    echo "   flutter run"
    echo ""
    echo "💡 The app will now use high-performance engine for large grids!"
else
    echo "❌ Build failed!"
    echo "🔍 Check the error messages above"
    exit 1
fi