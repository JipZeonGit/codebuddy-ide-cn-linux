#!/bin/bash
# DEB discovery and metadata extraction. Sourced by install.sh.

resolve_deb_input_path() {
    local explicit_path="$1"
    local -a candidates=()

    if [ -n "$explicit_path" ]; then
        [ -e "$explicit_path" ] || error "Input not found: $explicit_path"
        realpath "$explicit_path"
        return 0
    fi

    if [ -d "$SCRIPT_DIR/downloads" ]; then
        mapfile -d '' candidates < <(find "$SCRIPT_DIR/downloads" -maxdepth 1 -type f -name "*.deb" -print0 | sort -z)
        if [ "${#candidates[@]}" -eq 1 ]; then
            realpath "${candidates[0]}"
            return 0
        fi
        if [ "${#candidates[@]}" -gt 1 ]; then
            error "Multiple DEBs found in downloads/. Pass one explicitly."
        fi
    fi

    error "No input DEB found. Pass a .deb path or place one official .deb in downloads/."
}

extract_deb_control_field() {
    local deb_file="$1"
    local field_name="$2"
    local original_dir="$(pwd)"
    local work_dir="$(mktemp -d)"
    local value=""

    cp "$deb_file" "$work_dir/app.deb"
    cd "$work_dir"
    ar x app.deb

    local control_archive=""
    if [ -f "control.tar.xz" ]; then
        control_archive="control.tar.xz"
    elif [ -f "control.tar.gz" ]; then
        control_archive="control.tar.gz"
    elif [ -f "control.tar.zst" ]; then
        control_archive="control.tar.zst"
    fi

    if [ -n "$control_archive" ]; then
        value="$(tar -O -xf "$control_archive" ./control 2>/dev/null | grep -i "^${field_name}:" | cut -d':' -f2- | tr -d '[:space:]')"
    fi

    cd "$original_dir"
    rm -rf "$work_dir"
    echo "$value"
}

extract_deb_payload() {
    local deb_file="$1"
    local target_dir="$2"
    local original_dir="$(pwd)"
    local work_dir="$(mktemp -d)"

    info "Extracting DEB payload"
    cp "$deb_file" "$work_dir/app.deb"
    cd "$work_dir"
    ar x app.deb

    local data_archive=""
    if [ -f "data.tar.xz" ]; then
        data_archive="data.tar.xz"
    elif [ -f "data.tar.gz" ]; then
        data_archive="data.tar.gz"
    elif [ -f "data.tar.zst" ]; then
        data_archive="data.tar.zst"
    fi

    [ -n "$data_archive" ] || error "No data.tar payload found in DEB"

    # Extract the data archive to target_dir
    mkdir -p "$target_dir"
    tar -C "$target_dir" -xf "$data_archive"

    cd "$original_dir"
    rm -rf "$work_dir"
}
