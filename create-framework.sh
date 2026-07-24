#!/bin/bash
set -euo pipefail

if [[ -z ${1:-} ]]; then
    echo "Provide an output"
    exit 1
fi

BUILD_PATH="build"
PLATFORMS_PATH="$BUILD_PATH"
FRAMEWORK_PATH="$1"

ARGS=()
for PLATFORM_PATH in "$PLATFORMS_PATH"/*; do
    [[ -f "$PLATFORM_PATH/libwg-go.a" ]] || continue

    ARGS+=(
        "-library" "$PLATFORM_PATH/libwg-go.a"
        "-headers" "$PLATFORM_PATH/Headers"
    )
done

if [[ ${#ARGS[@]} -eq 0 ]]; then
    echo "No platform libraries found under $PLATFORMS_PATH"
    exit 1
fi

rm -rf "$FRAMEWORK_PATH"
xcodebuild -create-xcframework "${ARGS[@]}" -output "$FRAMEWORK_PATH"
