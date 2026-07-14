#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_ID="${CODEBUDDY_APP_ID:-codebuddy-ide-cn}"
APP_DISPLAY_NAME="${CODEBUDDY_APP_DISPLAY_NAME:-CodeBuddy CN}"
INSTALL_DIR="${CODEBUDDY_INSTALL_DIR:-$SCRIPT_DIR/codebuddycn-app}"
WORK_DIR="$(mktemp -d)"
PROVIDED_INPUT=""
FRESH=0

. "$SCRIPT_DIR/scripts/lib/common.sh"
. "$SCRIPT_DIR/scripts/lib/deb.sh"
. "$SCRIPT_DIR/scripts/lib/native-modules.sh"

ELECTRON_HEADERS_URL="${ELECTRON_HEADERS_URL:-${npm_config_disturl:-${NPM_CONFIG_DISTURL:-https://artifacts.electronjs.org/headers/dist}}}"

usage() {
    cat <<'HELP'
Usage: ./install.sh [--fresh] [path/to/codebuddy.deb]

Builds a local Linux CodeBuddy app by extracting the official CodeBuddy Linux DEB package.
With no path, the installer expects exactly one official DEB in downloads/.

Environment:
  CODEBUDDY_INSTALL_DIR   Output app directory (default: ./codebuddycn-app)
HELP
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --fresh)
                FRESH=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                usage >&2
                exit 2
                ;;
            *)
                [ -z "$PROVIDED_INPUT" ] || error "Only one input path can be provided"
                PROVIDED_INPUT="$1"
                ;;
        esac
        shift
    done
}

check_deps() {
    require_cmd tar
    require_cmd ar
    require_cmd node
    require_cmd npm
    require_cmd npx
    require_cmd python3
}

prepare_install_dir() {
    if [ -e "$INSTALL_DIR" ]; then
        info "Replacing existing install dir: $INSTALL_DIR"
        rm -rf "$INSTALL_DIR"
    fi
    mkdir -p "$INSTALL_DIR"
}

copy_app_payload() {
    local deb_root="$1"
    local app_payload="$deb_root/usr/share/buddycn"

    [ -d "$app_payload" ] || error "Missing app payload in DEB: $app_payload"

    info "Copying CodeBuddy app payload to $INSTALL_DIR"
    cp -a "$app_payload/." "$INSTALL_DIR/"
}

write_icon() {
    local deb_root="$1"
    local icon_source="$deb_root/usr/share/pixmaps/buddycn.png"
    local icon_target="$INSTALL_DIR/.codebuddycn-linux/codebuddycn.png"

    mkdir -p "$INSTALL_DIR/.codebuddycn-linux"
    if [ -f "$icon_source" ]; then
        if command -v convert >/dev/null 2>&1; then
            info "Resizing CodeBuddy icon to 256x256 using convert"
            convert "$icon_source" -resize 256x256 "$icon_target"
        elif command -v magick >/dev/null 2>&1; then
            info "Resizing CodeBuddy icon to 256x256 using magick"
            magick "$icon_source" -resize 256x256 "$icon_target"
        else
            warn "ImageMagick not found, using original 150x150 icon"
            cp "$icon_source" "$icon_target"
        fi
    else
        warn "CodeBuddy icon not found in DEB payload, using fallback icon path"
    fi
}

write_launcher() {
    cat > "$INSTALL_DIR/start.sh" <<EOF
#!/bin/bash
set -euo pipefail

APP_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
export CHROME_DESKTOP="${APP_ID}.desktop"
export ELECTRON_DISABLE_SANDBOX=1

# Run the official launcher script
exec "\$APP_DIR/bin/buddycn" "\$@"
EOF
    chmod +x "$INSTALL_DIR/start.sh"
}

write_desktop_entry() {
    local deb_root="$1"
    local desktop_src="$deb_root/usr/share/applications/buddycn.desktop"
    local url_desktop_src="$deb_root/usr/share/applications/buddycn-url-handler.desktop"
    local desktop_target="$INSTALL_DIR/.codebuddycn-linux/$APP_ID.desktop"
    local url_desktop_target="$INSTALL_DIR/.codebuddycn-linux/$APP_ID-url-handler.desktop"

    mkdir -p "$INSTALL_DIR/.codebuddycn-linux"
    
    if [ -f "$desktop_src" ]; then
        sed -e "s|/usr/share/buddycn/bin/buddycn|/usr/bin/$APP_ID|g" \
            -e "s|Icon=buddycn|Icon=codebuddycn|g" \
            "$desktop_src" > "$desktop_target"
    fi

    if [ -f "$url_desktop_src" ]; then
        sed -e "s|/usr/share/buddycn/bin/buddycn|/usr/bin/$APP_ID|g" \
            -e "s|Icon=buddycn|Icon=codebuddycn|g" \
            "$url_desktop_src" > "$url_desktop_target"
    fi
}

write_build_metadata() {
    local version="$1"
    mkdir -p "$INSTALL_DIR/.codebuddycn-linux"
    cat > "$INSTALL_DIR/.codebuddycn-linux/build-info.json" <<EOF
{
  "appId": "$APP_ID",
  "displayName": "$APP_DISPLAY_NAME",
  "upstreamVersion": "$version",
  "generatedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

main() {
    parse_args "$@"
    check_deps

    local input_deb version deb_root
    input_deb="$(resolve_deb_input_path "$PROVIDED_INPUT")"
    version="$(extract_deb_control_field "$input_deb" "Version")"
    deb_root="$WORK_DIR/deb-root"

    info "Using DEB package: $input_deb"
    info "Using Version: $version"

    prepare_install_dir
    extract_deb_payload "$input_deb" "$deb_root"
    copy_app_payload "$deb_root"

    # Rebuild native modules if missing (like node-pty)
    ELECTRON_VERSION="$(cat "$INSTALL_DIR/resources/app/package.json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('electronVersion', d.get('devDependencies',{}).get('electron','N/A')))" 2>/dev/null)"
    export ELECTRON_VERSION
    rebuild_native_modules "$INSTALL_DIR/resources/app"

    write_icon "$deb_root"
    write_launcher
    write_desktop_entry "$deb_root"
    write_build_metadata "$version"

    info "Build complete: $INSTALL_DIR"
    info "Run: $INSTALL_DIR/start.sh"
}

trap 'rm -rf "$WORK_DIR"' EXIT
main "$@"
