# Introduction

This repo provides pre-compiled onnxruntime shared and static libraries
for various platforms.

Please visit https://github.com/csukuangfj/onnxruntime-libs/releases
to download pre-compiled onnxruntime libraries.

Note:

 - Code for building shared libraries: https://github.com/csukuangfj/onnxruntime-libs/tree/master/.github/workflows
 - Code for building static libraries: https://github.com/csukuangfj/onnxruntime-build/tree/main/.github/workflows
 - Linux x86_64/aarch64 workflows use Zig 0.16 `cc`/`c++`. Windows x86_64/aarch64 workflows build MSVC DLLs for use through the ONNX Runtime C API. macOS x86_64/aarch64 workflows use Apple Clang.
