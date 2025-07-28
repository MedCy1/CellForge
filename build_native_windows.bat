@echo off
echo 🔨 Building AVX2 native engine for Windows...

REM Check if we're in WSL path or Windows path
if exist "C:\Windows\System32\wsl.exe" (
    echo 💡 Using WSL to build native library...
    wsl -e bash -c "cd '/mnt/c/Users/meder/Documents/Code/Perso/CellForge/native' && make clean && make"
    
    if exist "native\libavx2_engine.so" (
        echo ✅ Native library built successfully using WSL!
        echo 📄 Created: %cd%\native\libavx2_engine.so
        goto :success
    ) else (
        echo ❌ WSL build failed, trying Windows build...
        goto :windows_build
    )
) else (
    echo 💡 WSL not found, trying Windows build...
    goto :windows_build
)

:windows_build
echo 🔍 Checking for GCC compiler...
gcc --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ GCC compiler not found!
    echo.
    echo 🛠️  Install options:
    echo    1. MinGW-w64: https://www.mingw-w64.org/downloads/
    echo    2. MSYS2: https://www.msys2.org/
    echo    3. Use WSL: Install Windows Subsystem for Linux
    echo.
    echo 💡 Or run this in WSL if you have it:
    echo    cd /mnt/c/Users/meder/Documents/Code/Perso/CellForge/native ^&^& make
    pause
    exit /b 1
)

cd /d "%~dp0native"
echo 🧹 Cleaning previous build...
if exist libavx2_engine.so del libavx2_engine.so
if exist libavx2_engine.dll del libavx2_engine.dll

echo ⚙️  Compiling native library...
gcc -Wall -Wextra -O3 -shared -o avx2_engine.dll avx2_engine.c

if exist avx2_engine.dll (
    echo ✅ Native library built successfully!
    echo 📄 Created: %cd%\avx2_engine.dll
    goto :success
) else (
    echo ❌ Build failed!
    echo 🔍 Check the error messages above
    pause
    exit /b 1
)

:success
echo.
echo 🚀 Ready to test! Run:
echo    flutter run
echo.
echo 💡 The app will now use high-performance engine for large grids!
pause