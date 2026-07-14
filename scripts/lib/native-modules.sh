#!/bin/bash
# Native Node module rebuilds for the copied VS Code/Electron payload.
#
# The macOS DMG ships pre-compiled native modules without source code
# (no binding.gyp / src/).  Running @electron/rebuild on them is a no-op.
# Instead we download each module's full source from npm, rebuild it for
# the target Linux Electron, and copy the result back into the app.

native_module_report() {
    local app_dir="$1"
    find "$app_dir/node_modules" -name "*.node" -type f 2>/dev/null | sort || true
}

remove_known_wrong_platform_modules() {
    local app_dir="$1"

    rm -rf "$app_dir/node_modules/windows-foreground-love" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@vscode/windows-mutex" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@vscode/windows-process-tree" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@vscode/windows-registry" 2>/dev/null || true
    rm -f "$app_dir/node_modules/@vscode/deviceid/build/Release/windows.node" 2>/dev/null || true

    # Clean up proprietary @tencent/qimei-node which is only active on Windows/macOS
    rm -rf "$app_dir/node_modules/@tencent/qimei-node/build" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@tencent/qimei-node/src/mac" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@tencent/qimei-node/src/win" 2>/dev/null || true

    # Clean up non-Linux prebuilts from koffi (which is used by qimei-node on Windows)
    if [ -d "$app_dir/node_modules/koffi/build/koffi" ]; then
        find "$app_dir/node_modules/koffi/build/koffi" -mindepth 1 -maxdepth 1 \
            ! -name "linux_x64" ! -name "linux_arm64" -exec rm -rf {} + 2>/dev/null || true
    fi

    find "$app_dir/node_modules" -path "*/prebuilds/darwin-*" -type d -prune -exec rm -rf {} + 2>/dev/null || true
}

refresh_npm_package() {
    local app_dir="$1"
    local package_name="$2"
    local package_path="$app_dir/node_modules/$package_name"
    local version build_dir source_path

    [ -f "$package_path/package.json" ] || return 0
    version="$(node -e 'const p=require(process.argv[1]); process.stdout.write(String(p.version || ""));' "$package_path/package.json")"
    [ -n "$version" ] || return 0

    build_dir="$WORK_DIR/platform-packages/${package_name//@/_}"
    rm -rf "$build_dir"
    mkdir -p "$build_dir"

    info "Refreshing platform package $package_name@$version"
    (
        cd "$build_dir"
        npm init -y >/dev/null 2>&1
        npm install "$package_name@$version" --no-audit --no-fund
    )

    source_path="$build_dir/node_modules/$package_name"
    [ -d "$source_path" ] || error "Failed to install $package_name@$version"
    rm -rf "$package_path"
    mkdir -p "$(dirname "$package_path")"
    cp -a "$source_path" "$package_path"
}

refresh_platform_packages() {
    local app_dir="$1"

    refresh_npm_package "$app_dir" "@vscode/ripgrep"
    refresh_npm_package "$app_dir" "@parcel/watcher"
}

purge_macho_native_modules() {
    local app_dir="$1"
    local native_file description

    command -v file >/dev/null 2>&1 || return 0
    while IFS= read -r native_file; do
        description="$(file "$native_file" 2>/dev/null || true)"
        case "$description" in
            *Mach-O*)
                warn "Removing non-Linux native module: $native_file"
                rm -f "$native_file"
                ;;
        esac
    done < <(find "$app_dir/node_modules" -name "*.node" -type f 2>/dev/null | sort || true)
}

# ---------------------------------------------------------------------------
# read_module_version  –  get version from an in-tree package.json
# ---------------------------------------------------------------------------
read_module_version() {
    local app_dir="$1"
    local module_name="$2"
    local pkg="$app_dir/node_modules/$module_name/package.json"
    [ -f "$pkg" ] || return 1
    node -e 'process.stdout.write(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).version||"")' "$pkg"
}

# ---------------------------------------------------------------------------
# build_native_module_fresh  –  npm-install from source, rebuild, copy back
#
# Because the macOS payload only ships pre-built binaries (no binding.gyp,
# no src/), we must obtain a *full* source distribution from npm and compile
# it against the target Electron.
# ---------------------------------------------------------------------------
build_native_module_fresh() {
    local app_dir="$1"
    local module_name="$2"
    local module_version="$3"
    local allow_fail="${4:-0}"

    local build_dir="$WORK_DIR/native-build/${module_name//@/_}_${module_version}"
    rm -rf "$build_dir"
    mkdir -p "$build_dir"

    info "Building $module_name@$module_version from source for Electron $ELECTRON_VERSION"
    (
        cd "$build_dir"
        echo '{"private":true}' > package.json

        # Install Electron (headers only, skip the full download)
        npm install "electron@$ELECTRON_VERSION" --save-dev --ignore-scripts --no-audit --no-fund 2>&1 >/dev/null

        # Install the module's full source
        npm install "$module_name@$module_version" --ignore-scripts --no-audit --no-fund 2>&1 >/dev/null

        # Rebuild for the target Electron
        npm_config_disturl="$ELECTRON_HEADERS_URL" \
        NPM_CONFIG_DISTURL="$ELECTRON_HEADERS_URL" \
        npx --yes @electron/rebuild \
            -v "$ELECTRON_VERSION" \
            --force \
            --dist-url "$ELECTRON_HEADERS_URL" \
            --only "$module_name" 2>&1
    )

    local rc=$?
    if [ $rc -ne 0 ]; then
        if [ "$allow_fail" -eq 1 ]; then
            warn "Failed to build $module_name@$module_version (optional, continuing)"
            return 0
        else
            error "Failed to build $module_name@$module_version"
        fi
    fi

    # Verify at least one .node was produced
    local built_path="$build_dir/node_modules/$module_name"
    local node_count
    node_count="$(find "$built_path" -name '*.node' -type f 2>/dev/null | wc -l)"
    if [ "$node_count" -eq 0 ] && [ "$allow_fail" -eq 0 ]; then
        error "No .node files produced for $module_name@$module_version"
    fi

    # Copy the freshly built module back into the app
    local target_path="$app_dir/node_modules/$module_name"
    rm -rf "$target_path"
    mkdir -p "$(dirname "$target_path")"
    cp -a "$built_path" "$target_path"
    info "Installed fresh $module_name@$module_version (${node_count} native files)"
}

# ---------------------------------------------------------------------------
# rebuild_native_modules  –  main entry point called from install.sh
# ---------------------------------------------------------------------------
rebuild_native_modules() {
    local app_dir="$1"

    [ -d "$app_dir/node_modules" ] || {
        warn "No node_modules directory found; skipping native rebuild"
        return 0
    }

    info "Native modules before cleanup:"
    native_module_report "$app_dir" >&2
    remove_known_wrong_platform_modules "$app_dir"

    # Only refresh platform packages if they are missing compiled native binaries
    local has_watcher
    has_watcher=$(find "$app_dir/node_modules/@parcel/watcher" -name "*.node" 2>/dev/null | head -1)
    if [ -z "$has_watcher" ]; then
        refresh_platform_packages "$app_dir"
    else
        info "Platform package @parcel/watcher already has native binary, skipping refresh"
    fi

    # ------------------------------------------------------------------
    # Collect versions of native modules that need a from-source rebuild
    # ------------------------------------------------------------------
    local module_name module_version

    # Modules that are critical for core functionality
    local -a critical_modules=(
        "node-pty"
        "native-keymap"
        "native-watchdog"
    )

    # Modules that are important but not fatal if they fail
    local -a optional_modules=(
        "@vscode/spdlog"
        "@vscode/sqlite3"
        "kerberos"
        "native-is-elevated"
        "@vscode/policy-watcher"
    )

    info "Rebuilding native modules for Electron $ELECTRON_VERSION"
    info "Using Electron headers: $ELECTRON_HEADERS_URL"

    # Build critical modules (fail on error)
    for module_name in "${critical_modules[@]}"; do
        module_version="$(read_module_version "$app_dir" "$module_name" 2>/dev/null || true)"
        if [ -z "$module_version" ]; then
            warn "Module $module_name not found in app; skipping"
            continue
        fi

        # Skip rebuild if native binaries already exist
        local has_node
        has_node=$(find "$app_dir/node_modules/$module_name" -name "*.node" 2>/dev/null | head -1)
        if [ -n "$has_node" ]; then
            info "Module $module_name already has precompiled binary ($has_node), skipping rebuild"
            continue
        fi

        build_native_module_fresh "$app_dir" "$module_name" "$module_version" 0
    done

    # Build optional modules (allow failure)
    for module_name in "${optional_modules[@]}"; do
        module_version="$(read_module_version "$app_dir" "$module_name" 2>/dev/null || true)"
        if [ -z "$module_version" ]; then
            warn "Module $module_name not found in app; skipping"
            continue
        fi

        # Skip rebuild if native binaries already exist
        local has_node
        has_node=$(find "$app_dir/node_modules/$module_name" -name "*.node" 2>/dev/null | head -1)
        if [ -n "$has_node" ]; then
            info "Module $module_name already has precompiled binary ($has_node), skipping rebuild"
            continue
        fi

        build_native_module_fresh "$app_dir" "$module_name" "$module_version" 1
    done

    purge_macho_native_modules "$app_dir"

    info "Native modules after rebuild:"
    native_module_report "$app_dir" >&2
}
