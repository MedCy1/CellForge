@echo off
echo 🔨 Building AVX2 native engine...

cd /d "%~dp0native"

echo 🧹 Cleaning previous build...
if exist libavx2_engine.so del libavx2_engine.so
if exist libavx2_engine.dll del libavx2_engine.dll

echo ⚙️  Compiling native library...
make

if exist libavx2_engine.so (
    echo ✅ Native library built successfully!
    echo 📄 Created: %cd%\libavx2_engine.so
    
    echo.
    echo 🚀 Ready to test! Run:
    echo    flutter run
    echo.
    echo 💡 The app will now use high-performance engine for large grids!
) else (
    echo ❌ Build failed!
    echo 🔍 Check the error messages above
    pause
)