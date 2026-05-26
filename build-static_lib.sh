#!/usr/bin/env bash

set -euo pipefail

CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:=Release}
SOURCE_DIR=${SOURCE_DIR:=static_lib}
BUILD_DIR=${BUILD_DIR:=build/static_lib}
OUTPUT_DIR=${OUTPUT_DIR:=output/static_lib}
ONNXRUNTIME_SOURCE_DIR=${ONNXRUNTIME_SOURCE_DIR:=onnxruntime}
ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:=$(cat ONNXRUNTIME_VERSION)}
CMAKE_OPTIONS=${CMAKE_OPTIONS:=}
CMAKE_BUILD_OPTIONS=${CMAKE_BUILD_OPTIONS:=}

echo "CMAKE_BUILD_TYPE: $CMAKE_BUILD_TYPE"
echo "CMAKE_BUILD_OPTIONS: $CMAKE_BUILD_OPTIONS"

case "$(uname -s)" in
Darwin) CPU_COUNT=$(sysctl -n hw.physicalcpu) ;;
Linux) CPU_COUNT=$(grep -c ^processor /proc/cpuinfo) ;;
*) CPU_COUNT=${NUMBER_OF_PROCESSORS:-1} ;;
esac
PARALLEL_JOB_COUNT=${PARALLEL_JOB_COUNT:=$CPU_COUNT}

cd "$(dirname "$0")"

if [[ ! -d "$ONNXRUNTIME_SOURCE_DIR/.git" ]]; then
  git clone --depth=1 --branch "v$ONNXRUNTIME_VERSION" https://github.com/microsoft/onnxruntime.git "$ONNXRUNTIME_SOURCE_DIR"
fi

(
  cd "$ONNXRUNTIME_SOURCE_DIR"
  if [[ "$ONNXRUNTIME_VERSION" != "$(cat VERSION_NUMBER)" ]]; then
    git fetch origin tag "v$ONNXRUNTIME_VERSION"
    git checkout "v$ONNXRUNTIME_VERSION"
  fi
  git submodule update --init --depth=1 --recursive
  sed -i.bak '/SOVERSION/d' ./cmake/onnxruntime.cmake
  sed -i.bak '/onnxruntime PROPERTIES VERSION/d' ./cmake/onnxruntime.cmake
  git diff .
)

cmake \
  -S "$SOURCE_DIR" \
  -B "$BUILD_DIR" \
  -D CMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
  -D CMAKE_CONFIGURATION_TYPES="$CMAKE_BUILD_TYPE" \
  -D CMAKE_INSTALL_PREFIX="$OUTPUT_DIR" \
  -D ONNXRUNTIME_SOURCE_DIR="$(pwd)/$ONNXRUNTIME_SOURCE_DIR" \
  --compile-no-warning-as-error \
  $CMAKE_OPTIONS

cmake \
  --build "$BUILD_DIR" \
  --config "$CMAKE_BUILD_TYPE" \
  --parallel "$PARALLEL_JOB_COUNT" \
  $CMAKE_BUILD_OPTIONS

cmake --install "$BUILD_DIR" --config "$CMAKE_BUILD_TYPE"
