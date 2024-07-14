#!/bin/bash
WG_GO_PATH="src"
BUILD_PATH="build"
FRAMEWORK_PATH="$BUILD_PATH/$1"

function make_wg_go() {
    local platform_name="$1"
    local targets="$2"
    local outdir="$BUILD_PATH/$platform_name"

    mkdir -p "$outdir"
    mkdir -p "$outdir/Headers"
    make -C "$WG_GO_PATH" PLATFORM_NAME="$platform_name" TARGETS="$targets"
    cp "$WG_GO_PATH/out/libwg-go.a" "$outdir"
    cp "$WG_GO_PATH/wireguard.h" "$outdir/Headers"
    cp "$WG_GO_PATH/module.modulemap" "$outdir/Headers"
    make -C "$WG_GO_PATH" clean
}

make_wg_go "iphoneos" "arm64-apple-ios15.0"
make_wg_go "iphonesimulator" "arm64-apple-ios15.0-simulator"
make_wg_go "macosx" "arm64-apple-macos12.0 x86_64-apple-macos12.0"
make_wg_go "appletvos" "arm64-apple-tvos17.0"
make_wg_go "appletvsimulator" "arm64-apple-tvos17.0-simulator"
