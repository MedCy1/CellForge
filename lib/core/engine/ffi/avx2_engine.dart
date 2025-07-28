import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI binding for the native avxStep function
@ffi.Native<ffi.Void Function(ffi.Pointer<ffi.Uint8>, ffi.Uint32, ffi.Uint32)>()
external void avxStep(ffi.Pointer<ffi.Uint8> grid, int width, int height);

// Dynamic library loader
class Avx2EngineFFI {
  static ffi.DynamicLibrary? _dylib;
  static bool _initialized = false;

  // Initialize the FFI library
  static void initialize() {
    if (_initialized) return;
    
    try {
      // Try multiple paths to find the library
      List<String> libraryPaths = [];
      
      if (Platform.isLinux || Platform.isAndroid) {
        libraryPaths = [
          './native/libavx2_engine.so',
          'native/libavx2_engine.so',
          '../native/libavx2_engine.so',
          './libavx2_engine.so',
        ];
      } else if (Platform.isWindows) {
        libraryPaths = [
          './native/avx2_engine.dll',
          'native/avx2_engine.dll',
          '../native/avx2_engine.dll',
          './avx2_engine.dll',
        ];
      } else if (Platform.isMacOS || Platform.isIOS) {
        libraryPaths = [
          './native/libavx2_engine.dylib',
          'native/libavx2_engine.dylib',
          '../native/libavx2_engine.dylib',
          './libavx2_engine.dylib',
        ];
      } else {
        throw UnsupportedError('Platform ${Platform.operatingSystem} not supported');
      }
      
      // Try each path until one works
      Exception? lastError;
      for (String path in libraryPaths) {
        try {
          _dylib = ffi.DynamicLibrary.open(path);
          _initialized = true;
          // AVX2 library loaded successfully from: $path
          return;
        } catch (e) {
          lastError = Exception('Failed to load from $path: $e');
          continue;
        }
      }
      
      // If we get here, none of the paths worked
      throw lastError ?? Exception('No library paths worked');
      
    } catch (e) {
      // Failed to load AVX2 native library: $e
      // Current working directory: ${Directory.current.path}
      // Make sure to build the library with: cd native && make
      throw Exception('Failed to load native library: $e');
    }
  }

  // Get the dynamic library instance
  static ffi.DynamicLibrary get dylib {
    if (!_initialized) {
      initialize();
    }
    return _dylib!;
  }
}

// Helper class for FFI operations
class Avx2FFIHelper {
  // Convert Dart Uint8List to FFI Pointer<Uint8>
  static ffi.Pointer<ffi.Uint8> uint8ListToPointer(List<int> list) {
    final pointer = malloc<ffi.Uint8>(list.length);
    for (int i = 0; i < list.length; i++) {
      pointer[i] = list[i];
    }
    return pointer;
  }

  // Convert FFI Pointer<Uint8> back to Dart Uint8List
  static List<int> pointerToUint8List(ffi.Pointer<ffi.Uint8> pointer, int length) {
    return List<int>.generate(length, (i) => pointer[i]);
  }

  // Free FFI pointer
  static void freePointer(ffi.Pointer pointer) {
    malloc.free(pointer);
  }
}