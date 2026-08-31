#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$REPO_DIR/scripts/lib/common.sh"

latest_artifact() {
    local pattern="$1"
    [ -d "$REPO_DIR/dist" ] || return 0
    find "$REPO_DIR/dist" -maxdepth 1 -type f -name "$pattern" -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr \
        | awk 'NR == 1 { sub(/^[^ ]+ /, ""); print }'
}

install_deb() {
    local artifact
    artifact="$(latest_artifact 'codebuddy-ide-cn_*.deb')"
    [ -n "$artifact" ] || return 1
    info "Installing $artifact"
    sudo dpkg -i "$artifact"
}

install_rpm() {
    local artifact
    artifact="$(latest_artifact 'codebuddy-ide-cn-*.rpm')"
    [ -n "$artifact" ] || return 1
    info "Installing $artifact"
    if command -v dnf5 >/dev/null 2>&1; then
        sudo dnf5 install -y "$artifact"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$artifact"
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper --non-interactive --no-gpg-checks install "$artifact"
    else
        return 1
    fi
}

install_pacman() {
    local artifact
    artifact="$(latest_artifact 'codebuddy-ide-cn-*.pkg.tar.zst')"
    [ -n "$artifact" ] || return 1
    command -v pacman >/dev/null 2>&1 || return 1
    info "Installing $artifact"
    sudo pacman -U --noconfirm "$artifact"
}

detect_install_format() {
    if [ -f /etc/os-release ]; then
        local id id_like
        . /etc/os-release
        id_like="${ID_LIKE:-$ID}"
        case "$ID $id_like" in
            *fedora*|*rhel*|*centos*|*rocky*|*alma*|*suse*) echo "rpm"; return 0 ;;
            *debian*|*ubuntu*|*mint*) echo "deb"; return 0 ;;
            *arch*|*manjaro*) echo "pacman"; return 0 ;;
        esac
    fi
    # Fallback
    if command -v dpkg >/dev/null 2>&1; then echo "deb"
    elif command -v rpm >/dev/null 2>&1; then echo "rpm"
    elif command -v pacman >/dev/null 2>&1; then echo "pacman"
    fi
}

main() {
    local fmt
    fmt="$(detect_install_format)"

    case "$fmt" in
        deb) install_deb && return 0 ;;
        rpm) install_rpm && return 0 ;;
        pacman) install_pacman && return 0 ;;
    esac

    # Ultimate fallback: try all in order
    if install_rpm; then return 0; fi
    if install_deb; then return 0; fi
    if install_pacman; then return 0; fi

    error "No installable package artifact found in dist/. Run make package first."
}

main "$@"
