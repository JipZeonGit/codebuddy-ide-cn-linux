#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$REPO_DIR/scripts/lib/common.sh"

detect_package_format() {
    # 1. 优先基于发行版识别（/etc/os-release 是 systemd/Linux 标准规范）
    if [ -f /etc/os-release ]; then
        local id id_like
        . /etc/os-release
        id_like="${ID_LIKE:-$ID}"
        case "$ID $id_like" in
            *fedora*|*rhel*|*centos*|*rocky*|*alma*|*suse*)
                if command -v rpmbuild >/dev/null 2>&1; then
                    echo "rpm"; return 0
                fi ;;
            *debian*|*ubuntu*|*mint*)
                if command -v dpkg-deb >/dev/null 2>&1 && command -v dpkg >/dev/null 2>&1; then
                    echo "deb"; return 0
                fi ;;
            *arch*|*manjaro*)
                if command -v makepkg >/dev/null 2>&1; then
                    echo "pacman"; return 0
                fi ;;
        esac
    fi

    # 2. Fallback: 无法通过发行版判断时探测工具链
    if command -v dpkg-deb >/dev/null 2>&1 && command -v dpkg >/dev/null 2>&1; then
        echo "deb"
    elif command -v rpmbuild >/dev/null 2>&1; then
        echo "rpm"
    elif command -v makepkg >/dev/null 2>&1; then
        echo "pacman"
    else
        error "Could not detect a supported package builder. Install dpkg-deb, rpmbuild, or makepkg."
    fi
}

case "${PACKAGE_FORMAT:-$(detect_package_format)}" in
    deb) bash "$REPO_DIR/scripts/build-deb.sh" ;;
    rpm) bash "$REPO_DIR/scripts/build-rpm.sh" ;;
    pacman|pkg.tar.zst) bash "$REPO_DIR/scripts/build-pacman.sh" ;;
    *) error "Unsupported PACKAGE_FORMAT: ${PACKAGE_FORMAT}" ;;
esac
