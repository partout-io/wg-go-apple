#!/bin/bash
set -euo pipefail

if [[ -z ${1:-} ]]; then
    echo "Provide an output"
    exit 1
fi

BUILD_PATH="build"
PLATFORMS_PATH="$BUILD_PATH"
FRAMEWORKS_PATH="$BUILD_PATH/frameworks"
FRAMEWORK_PATH="$1"
FRAMEWORK_NAME="wg_go"
BUNDLE_IDENTIFIER_NAME="wg-go"

function write_info_plist() {
    local plist_path="$1"
    local platform_name="$2"

    mkdir -p "$(dirname "$plist_path")"
    cat > "$plist_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>io.partout.$BUNDLE_IDENTIFIER_NAME.$platform_name</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$FRAMEWORK_NAME</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF
}

function write_module_map() {
    local module_map_path="$1"

    cat > "$module_map_path" <<EOF
framework module $FRAMEWORK_NAME {
    umbrella header "wg_go.h"
    export *
}
EOF
}

function create_flat_framework() {
    local platform_path="$1"
    local framework_path="$2"
    local platform_name

    platform_name="$(basename "$platform_path")"

    mkdir -p "$framework_path/Headers"
    mkdir -p "$framework_path/Modules"
    cp "$platform_path/libwg-go.a" "$framework_path/$FRAMEWORK_NAME"
    cp "$platform_path/Headers/wg_go.h" "$framework_path/Headers"
    write_module_map "$framework_path/Modules/module.modulemap"
    write_info_plist "$framework_path/Info.plist" "$platform_name"
}

function create_macos_framework() {
    local platform_path="$1"
    local framework_path="$2"
    local platform_name
    local version_path

    platform_name="$(basename "$platform_path")"
    version_path="$framework_path/Versions/A"

    mkdir -p "$version_path/Headers"
    mkdir -p "$version_path/Modules"
    cp "$platform_path/libwg-go.a" "$version_path/$FRAMEWORK_NAME"
    cp "$platform_path/Headers/wg_go.h" "$version_path/Headers"
    write_module_map "$version_path/Modules/module.modulemap"
    write_info_plist "$version_path/Resources/Info.plist" "$platform_name"

    ln -s A "$framework_path/Versions/Current"
    ln -s Versions/Current/Headers "$framework_path/Headers"
    ln -s Versions/Current/Modules "$framework_path/Modules"
    ln -s Versions/Current/Resources "$framework_path/Resources"
    ln -s Versions/Current/$FRAMEWORK_NAME "$framework_path/$FRAMEWORK_NAME"
}

rm -rf "$FRAMEWORKS_PATH"
mkdir -p "$FRAMEWORKS_PATH"

ARGS=()
for PLATFORM_PATH in "$PLATFORMS_PATH"/*; do
    [[ -f "$PLATFORM_PATH/libwg-go.a" ]] || continue

    PLATFORM_NAME="$(basename "$PLATFORM_PATH")"
    PLATFORM_FRAMEWORK="$FRAMEWORKS_PATH/$PLATFORM_NAME/$FRAMEWORK_NAME.framework"

    mkdir -p "$(dirname "$PLATFORM_FRAMEWORK")"
    if [[ "$PLATFORM_NAME" == "macosx" ]]; then
        create_macos_framework "$PLATFORM_PATH" "$PLATFORM_FRAMEWORK"
    else
        create_flat_framework "$PLATFORM_PATH" "$PLATFORM_FRAMEWORK"
    fi
    ARGS+=("-framework" "$PLATFORM_FRAMEWORK")
done

if [[ ${#ARGS[@]} -eq 0 ]]; then
    echo "No platform libraries found under $PLATFORMS_PATH"
    exit 1
fi

rm -rf "$FRAMEWORK_PATH"
xcodebuild -create-xcframework "${ARGS[@]}" -output "$FRAMEWORK_PATH"
