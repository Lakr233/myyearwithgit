#!/bin/zsh

set -e
set -o pipefail

echo "    CONFIGURATION: $CONFIGURATION"
echo "    CODE_SIGN_IDENTITY: $CODE_SIGN_IDENTITY"
echo "    EXPANDED_CODE_SIGN_IDENTITY_NAME: $EXPANDED_CODE_SIGN_IDENTITY_NAME"
echo "    DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM"

APP_PATH="$CODESIGNING_FOLDER_PATH"
AUX_BINARY_ROOT_DIR="$APP_PATH/Contents/Resources/GitBuild"

if [ -n "$EXPANDED_CODE_SIGN_IDENTITY_NAME" ]; then
    echo "[*] overwrite CODE_SIGN_IDENTITY to $EXPANDED_CODE_SIGN_IDENTITY_NAME"
    CODE_SIGN_IDENTITY="$EXPANDED_CODE_SIGN_IDENTITY_NAME"
fi

function codesign_binary_at_path() {
    local binary_path="$1"
    echo "[*] codesigning $binary_path"
    codesign --force --sign "$CODE_SIGN_IDENTITY" \
        --entitlements "$PROJECT_DIR/MyYearWithGit/Entitlements-Subprocess.entitlements" \
        "$binary_path"
}

for binary in $(find "$AUX_BINARY_ROOT_DIR" -type f); do
    if ! file "$binary" | grep -q "Mach-O"; then
        continue
    fi
    codesign_binary_at_path "$binary"
done

echo "[*] done $0"
