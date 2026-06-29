#!/bin/bash
set -e

NDK_ROOT=~/android-ndk-r29
API=24
LJ_ROOT=$(pwd)/LuaJIT 
OUT_ROOT=$(pwd)/LuaJIT-build-cmake

TOOLCHAIN="$NDK_ROOT/build/cmake/android-legacy.toolchain.cmake"

ABIS=("arm64-v8a")

mkdir -p $OUT_ROOT

for ABI in "${ABIS[@]}"; do
    echo "[*] Building for $ABI ..."
    BUILD_DIR="build-$ABI"
    INSTALL_DIR="$OUT_ROOT/$ABI"

    cd $LJ_ROOT
    rm -rf $BUILD_DIR
    mkdir $BUILD_DIR && cd $BUILD_DIR

    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
        -DANDROID_ABI=$ABI \
        -D_FILE_OFFSET_BITS=64 \
        -DANDROID_PLATFORM=android-$API \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DBUILD_SHARED_LIBS=ON \
        -DLUAJIT_ENABLE_UTF8_FOPEN=OFF \
        -DLUA_BUILD_DOCS=OFF \
        -DLUA_BUILD_TESTING=OFF \
        -DANDROID_ARM_MODE=arm \
        -DANDROID_STL="c++_shared" \
        -DCMAKE_SHADERLINKER_FLAGS="-flto=thin -Wl,--build-id" \
        -DCMAKE_C_FLAGS="-Os -flto=thin -fno-omit-frame-pointer -funwind-tables -fstack-protector-strong -g -D_FILE_OFFSET_BITS=64" \
        -DCMAKE_CXX_FLAGS="-Os -flto=thin -fno-omit-frame-pointer -funwind-tables -fstack-protector-strong -g -D_FILE_OFFSET_BITS=64"

    make -j16
    make install
 
    echo "[✓] $ABI installed to $INSTALL_DIR"
    cd $LJ_ROOT
done

ls -la $OUT_ROOT/*/lib/libluajit.so