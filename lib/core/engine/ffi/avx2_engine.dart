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
      // Try to load the shared library
      // You'll need to compile the C code as: gcc -shared -fPIC -o libavx2_engine.so avx2_engine.c
      if (Platform.isLinux) {
        _dylib = ffi.DynamicLibrary.open('./native/libavx2_engine.so');
      } else if (Platform.isWindows) {
        _dylib = ffi.DynamicLibrary.open('./native/avx2_engine.dll');
      } else if (Platform.isMacOS) {
        _dylib = ffi.DynamicLibrary.open('./native/libavx2_engine.dylib');
      } else {
        throw UnsupportedError('Platform not supported');
      }
      
      _initialized = true;
    } catch (e) {
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