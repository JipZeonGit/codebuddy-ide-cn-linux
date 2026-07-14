#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$REPO_DIR/scripts/lib/common.sh"

APP_DIR="${APP_DIR:-$REPO_DIR/codebuddycn-app}"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
PKG_ROOT="${PKG_ROOT:-$DIST_DIR/rpm-root}"
PACKAGE_NAME="${PACKAGE_NAME:-codebuddy-ide-cn}"
PACKAGE_VERSION="${PACKAGE_VERSION:-$(date -u +%Y.%m.%d.%H%M%S)}"
RPM_VERSION="${PACKAGE_VERSION//+/_}"
RPM_VERSION="${RPM_VERSION//-/_}"
DESKTOP_TEMPLATE="$REPO_DIR/packaging/linux/codebuddy-ide-cn.desktop"
SPEC_FILE="$DIST_DIR/$PACKAGE_NAME.spec"

map_arch() {
    case "$(uname -m)" in
        x86_64) echo "x86_64" ;;
        aarch64) echo "aarch64" ;;
        *) error "Unsupported RPM architecture: $(uname -m)" ;;
    esac
}

main() {
    [ -x "$APP_DIR/start.sh" ] || error "Missing generated app. Run make build-app first."
    require_cmd rpmbuild

    local arch output_dir output_file
    arch="$(map_arch)"
    output_dir="$DIST_DIR/rpmbuild"
    output_file="$DIST_DIR/${PACKAGE_NAME}-${RPM_VERSION}-1.${arch}.rpm"

    rm -rf "$PKG_ROOT" "$output_dir"
    mkdir -p \
        "$PKG_ROOT/opt/$PACKAGE_NAME" \
        "$PKG_ROOT/usr/bin" \
        "$PKG_ROOT/usr/share/applications" \
        "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps" \
        "$output_dir/BUILD" "$output_dir/RPMS" "$output_dir/SOURCES" "$output_dir/SPECS" "$output_dir/SRPMS"

    cp -a "$APP_DIR/." "$PKG_ROOT/opt/$PACKAGE_NAME/"
    cat > "$PKG_ROOT/usr/bin/$PACKAGE_NAME" <<EOF
#!/bin/bash
exec /opt/$PACKAGE_NAME/start.sh "\$@"
EOF
    chmod 0755 "$PKG_ROOT/usr/bin/$PACKAGE_NAME"

    if [ -f "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" ]; then
        cp "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME.desktop" \
            "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME.desktop"
    fi

    if [ -f "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME-url-handler.desktop" ]; then
        cp "$APP_DIR/.codebuddycn-linux/$PACKAGE_NAME-url-handler.desktop" \
            "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME-url-handler.desktop"
    fi

    if [ -f "$APP_DIR/.codebuddycn-linux/codebuddycn.png" ]; then
        cp "$APP_DIR/.codebuddycn-linux/codebuddycn.png" \
            "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
    fi

    local icon_files_entry=""
    if [ -f "$APP_DIR/.codebuddycn-linux/codebuddycn.png" ]; then
        icon_files_entry="/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
    fi

    local changelog_date
    changelog_date="$(date -u '+%a %b %d %Y')"

    cat > "$SPEC_FILE" <<EOF
%define _use_internal_dependency_generator 0
%define __find_requires %{nil}
%define __find_provides %{nil}
%define debug_package %{nil}
%define __check_files %{nil}
%define _binary_payload w3.gzdio

Name: $PACKAGE_NAME
Version: $RPM_VERSION
Release: 1%{?dist}
Summary: Unofficial local Linux conversion of CodeBuddy IDE CN
License: MIT
BuildArch: $arch
Requires: gtk3, nss, libXScrnSaver, alsa-lib, libsecret, libxkbfile
Conflicts: codebuddycn-ide, codebuddy-cn-ide

%description
This package is repackaged locally from the official CodeBuddy IDE CN Debian package.
It does not redistribute upstream software through the source repository.

%install
mkdir -p %{buildroot}
cp -a $PKG_ROOT/. %{buildroot}/

%files
/opt/$PACKAGE_NAME
/usr/bin/$PACKAGE_NAME
/usr/share/applications/$PACKAGE_NAME.desktop
/usr/share/applications/$PACKAGE_NAME-url-handler.desktop
$icon_files_entry

%changelog
* $changelog_date Auto Builder <builder@codebuddy.local> - $RPM_VERSION-1
- Initial release for Fedora.
EOF

    rpmbuild --define "_topdir $output_dir" --define "_build_id_links none" -bb "$SPEC_FILE" >&2
    mkdir -p "$DIST_DIR"
    find "$output_dir/RPMS" -type f -name "*.rpm" -exec cp {} "$output_file" \;
    [ -f "$output_file" ] || error "RPM was not produced"
    info "Built package: $output_file"
}

main "$@"
