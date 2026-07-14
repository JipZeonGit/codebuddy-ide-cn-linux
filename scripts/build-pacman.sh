#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$REPO_DIR/scripts/lib/common.sh"

APP_DIR="${APP_DIR:-$REPO_DIR/codebuddycn-app}"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
PKG_WORK="${PKG_WORK:-$DIST_DIR/pacman-work}"
PACKAGE_NAME="${PACKAGE_NAME:-codebuddy-ide-cn}"
PACKAGE_VERSION="${PACKAGE_VERSION:-$(date -u +%Y.%m.%d.%H%M%S)}"
PACMAN_VERSION="${PACKAGE_VERSION//+/_}"
PACMAN_VERSION="${PACMAN_VERSION//-/_}"
DESKTOP_TEMPLATE="$REPO_DIR/packaging/linux/codebuddy-ide-cn.desktop"

map_arch() {
    case "$(uname -m)" in
        x86_64) echo "x86_64" ;;
        aarch64) echo "aarch64" ;;
        *) error "Unsupported pacman architecture: $(uname -m)" ;;
    esac
}

main() {
    [ -x "$APP_DIR/start.sh" ] || error "Missing generated app. Run make build-app first."
    require_cmd makepkg

    local arch output_file source_root
    arch="$(map_arch)"
    output_file="$DIST_DIR/${PACKAGE_NAME}-${PACMAN_VERSION}-1-${arch}.pkg.tar.zst"
    source_root="$PKG_WORK/src/app"

    rm -rf "$PKG_WORK"
    mkdir -p "$source_root"
    cp -a "$APP_DIR/." "$source_root/"

    if [ -f "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" ]; then
        cp "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" "$PKG_WORK/$PACKAGE_NAME.desktop"
    fi
    if [ -f "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME-url-handler.desktop" ]; then
        cp "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME-url-handler.desktop" "$PKG_WORK/$PACKAGE_NAME-url-handler.desktop"
    fi

    cat > "$PKG_WORK/PKGBUILD" <<EOF
pkgname=$PACKAGE_NAME
pkgver=$PACMAN_VERSION
pkgrel=1
pkgdesc='Unofficial local Linux repackaging of CodeBuddy IDE CN'
arch=('$arch')
license=('MIT')
depends=('gtk3' 'nss' 'libxss' 'alsa-lib' 'libsecret' 'libxkbfile')
conflicts=('codebuddycn-ide' 'codebuddy-cn-ide')
source=()
sha256sums=()

package() {
  mkdir -p "\$pkgdir/opt/$PACKAGE_NAME" "\$pkgdir/usr/bin" "\$pkgdir/usr/share/applications" "\$pkgdir/usr/share/icons/hicolor/256x256/apps"
  cp -a "$source_root/." "\$pkgdir/opt/$PACKAGE_NAME/"
  cat > "\$pkgdir/usr/bin/$PACKAGE_NAME" <<'SCRIPT'
#!/bin/bash
exec /opt/$PACKAGE_NAME/start.sh "\$@"
SCRIPT
  chmod 0755 "\$pkgdir/usr/bin/$PACKAGE_NAME"
  install -m 0644 "$PKG_WORK/$PACKAGE_NAME.desktop" "\$pkgdir/usr/share/applications/$PACKAGE_NAME.desktop"
  install -m 0644 "$PKG_WORK/$PACKAGE_NAME-url-handler.desktop" "\$pkgdir/usr/share/applications/$PACKAGE_NAME-url-handler.desktop"
  if [ -f "$source_root/.codebuddycn-linux/codebuddycn.png" ]; then
    install -m 0644 "$source_root/.codebuddycn-linux/codebuddycn.png" "\$pkgdir/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
  fi
}
EOF

    (
        cd "$PKG_WORK"
        makepkg -f --noconfirm
    )

    mkdir -p "$DIST_DIR"
    # makepkg may produce a split debug package (*-debug-*.pkg.tar.zst) in
    # addition to the main package.  Pick only the main package to copy out.
    local built_pkg
    built_pkg="$(find "$PKG_WORK" -maxdepth 1 -name "${PACKAGE_NAME}-*.pkg.tar.zst" \
        ! -name "${PACKAGE_NAME}-debug-*.pkg.tar.zst" | head -n 1)"
    [ -n "$built_pkg" ] || error "makepkg did not produce a package in $PKG_WORK"
    cp "$built_pkg" "$output_file"
    info "Built package: $output_file"
}

main "$@"
