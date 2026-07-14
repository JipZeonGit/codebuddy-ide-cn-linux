#!/bin/bash
# AppImage packaging helpers. Sourced by build-appimage.sh.

LINUXDEPLOY_URL="${LINUXDEPLOY_URL:-https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage}"
LINUXDEPLOY_BIN="${LINUXDEPLOY_BIN:-$REPO_DIR/build/tools/linuxdeploy-x86_64.AppImage}"
APPIMAGE_RUNTIME_URL="${APPIMAGE_RUNTIME_URL:-https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64}"
APPIMAGE_RUNTIME_BIN="${APPIMAGE_RUNTIME_BIN:-$REPO_DIR/build/tools/runtime-x86_64}"

download_linuxdeploy() {
    if [ -x "$LINUXDEPLOY_BIN" ]; then
        info "linuxdeploy already cached: $LINUXDEPLOY_BIN"
    else
        mkdir -p "$(dirname "$LINUXDEPLOY_BIN")"
        info "Downloading linuxdeploy ..."
        curl -fSL --progress-bar -o "$LINUXDEPLOY_BIN" "$LINUXDEPLOY_URL"
        chmod +x "$LINUXDEPLOY_BIN"
        info "linuxdeploy saved: $LINUXDEPLOY_BIN"
    fi

    if [ -x "$APPIMAGE_RUNTIME_BIN" ]; then
        info "AppImage runtime already cached: $APPIMAGE_RUNTIME_BIN"
    else
        mkdir -p "$(dirname "$APPIMAGE_RUNTIME_BIN")"
        info "Downloading AppImage runtime ..."
        curl -fSL --progress-bar -o "$APPIMAGE_RUNTIME_BIN" "$APPIMAGE_RUNTIME_URL"
        chmod +x "$APPIMAGE_RUNTIME_BIN"
        info "AppImage runtime saved: $APPIMAGE_RUNTIME_BIN"
    fi
}

prepare_appdir() {
    local appdir="$1"

    rm -rf "$appdir"
    mkdir -p \
        "$appdir/usr/bin" \
        "$appdir/usr/share/applications" \
        "$appdir/usr/share/icons/hicolor/256x256/apps"

    # Copy the entire built app into usr/bin/
    # start.sh uses $(dirname "${BASH_SOURCE[0]}") to locate electron,
    # so the internal layout must stay intact.
    cp -a "$APP_DIR" "$appdir/usr/bin/codebuddycn-app"

    # Icon
    local icon_src="$APP_DIR/.codebuddycn-linux/codebuddycn.png"
    if [ -f "$icon_src" ]; then
        cp "$icon_src" "$appdir/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
    else
        warn "Icon not found; AppImage will use a fallback icon"
    fi
}

build_appimage() {
    local appdir="$1"
    local output="$2"
    local workdir="$3"
    local icon_path="$appdir/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"

    local apprun_src="$workdir/AppRun"
    cat > "$apprun_src" <<'APPRUN'
#!/bin/bash
SELF_DIR="$(dirname "$(readlink -f "$0")")"
export ELECTRON_DISABLE_SANDBOX=1
exec "$SELF_DIR/usr/bin/codebuddycn-app/buddycn" --no-sandbox "$@"
APPRUN
    chmod 0755 "$apprun_src"

    local desktop_src="$workdir/$PACKAGE_NAME.desktop"
    if [ -f "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" ]; then
        sed -e "s|/usr/bin/$PACKAGE_NAME|$PACKAGE_NAME|g" \
            "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" > "$desktop_src"
    else
        sed -e "s|__EXEC__|$PACKAGE_NAME %F|g" "$DESKTOP_TEMPLATE" \
            > "$desktop_src"
    fi
    chmod 0644 "$desktop_src"

    info "Building AppImage ..."
    mkdir -p "$DIST_DIR"

    local -a deploy_args=(
        --appimage-extract-and-run
        --appdir "$appdir"
        --custom-apprun "$apprun_src"
        --desktop-file "$desktop_src"
        --output appimage
    )
    if [ -f "$icon_path" ]; then
        deploy_args+=(--icon-file "$icon_path")
    fi

    # --appimage-extract-and-run avoids requiring FUSE at build time
    LDAI_RUNTIME_FILE="$APPIMAGE_RUNTIME_BIN" ARCH=x86_64 "$LINUXDEPLOY_BIN" "${deploy_args[@]}" >&2

    # linuxdeploy writes the AppImage into the current directory
    local generated
    generated="$(find "$REPO_DIR" -maxdepth 1 -name "*.AppImage" -print | head -n 1)"
    if [ -n "$generated" ] && [ -f "$generated" ]; then
        mv "$generated" "$output"
    else
        error "AppImage generation failed; no output file found"
    fi

    info "Built AppImage: $output"
}
