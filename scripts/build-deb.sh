#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$REPO_DIR/scripts/lib/common.sh"

APP_DIR="${APP_DIR:-$REPO_DIR/codebuddycn-app}"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
PKG_ROOT="${PKG_ROOT:-$DIST_DIR/deb-root}"
PACKAGE_NAME="${PACKAGE_NAME:-codebuddy-ide-cn}"
PACKAGE_VERSION="${PACKAGE_VERSION:-$(date -u +%Y.%m.%d.%H%M%S)}"
DESKTOP_TEMPLATE="$REPO_DIR/packaging/linux/codebuddy-ide-cn.desktop"
CONTROL_TEMPLATE="$REPO_DIR/packaging/linux/control"

map_arch() {
    case "$(dpkg --print-architecture)" in
        amd64|arm64|armhf) dpkg --print-architecture ;;
        *) error "Unsupported Debian architecture: $(dpkg --print-architecture)" ;;
    esac
}

main() {
    [ -x "$APP_DIR/start.sh" ] || error "Missing generated app. Run ./install.sh first."
    require_cmd dpkg
    require_cmd dpkg-deb

    local arch output_file
    arch="$(map_arch)"
    output_file="$DIST_DIR/${PACKAGE_NAME}_${PACKAGE_VERSION}_${arch}.deb"

    rm -rf "$PKG_ROOT"
    mkdir -p \
        "$PKG_ROOT/DEBIAN" \
        "$PKG_ROOT/opt/$PACKAGE_NAME" \
        "$PKG_ROOT/usr/bin" \
        "$PKG_ROOT/usr/share/applications" \
        "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps"

    cp -a "$APP_DIR/." "$PKG_ROOT/opt/$PACKAGE_NAME/"

    cat > "$PKG_ROOT/usr/bin/$PACKAGE_NAME" <<EOF
#!/bin/bash
exec /opt/$PACKAGE_NAME/start.sh "\$@"
EOF
    chmod 0755 "$PKG_ROOT/usr/bin/$PACKAGE_NAME"

    if [ -f "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" ]; then
        cp "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" \
            "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME.desktop"
        chmod 0644 "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME.desktop"
    fi

    if [ -f "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME-url-handler.desktop" ]; then
        cp "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME-url-handler.desktop" \
            "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME-url-handler.desktop"
        chmod 0644 "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME-url-handler.desktop"
    fi

    if [ -f "$APP_DIR/.codebuddycn-linux/codebuddycn.png" ]; then
        cp "$APP_DIR/.codebuddycn-linux/codebuddycn.png" \
            "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
        chmod 0644 "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
    fi

    sed \
        -e "s/__PACKAGE_NAME__/$PACKAGE_NAME/g" \
        -e "s/__VERSION__/$PACKAGE_VERSION/g" \
        -e "s/__ARCH__/$arch/g" \
        "$CONTROL_TEMPLATE" > "$PKG_ROOT/DEBIAN/control"
    chmod 0644 "$PKG_ROOT/DEBIAN/control"

    mkdir -p "$DIST_DIR"
    dpkg-deb --root-owner-group --build "$PKG_ROOT" "$output_file" >&2
    info "Built package: $output_file"
}

main "$@"
