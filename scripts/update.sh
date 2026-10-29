#!/usr/bin/env bash
set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

readonly FAKE_HASH="lib.fakeHash"
readonly RELEASES_URL="https://releases.herdr.dev"

log_info() { echo -e "${GREEN}[INFO]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Set by select_package.
PACKAGE=""
PACKAGE_FILE=""
FLAKE_ATTR=""
MAIN_PROGRAM=""

select_package() {
    PACKAGE="$1"
    case "$PACKAGE" in
        tui)
            PACKAGE_FILE="packages/herdr-tui.nix"
            FLAKE_ATTR="herdr-tui"
            MAIN_PROGRAM="herdr"
            ;;
        core)
            PACKAGE_FILE="packages/herdr-core.nix"
            FLAKE_ATTR="herdr-core"
            MAIN_PROGRAM="herdr-core"
            ;;
        app)
            PACKAGE_FILE="packages/herdr-app.nix"
            FLAKE_ATTR="herdr"
            MAIN_PROGRAM="herdr-app"
            ;;
        *)
            log_error "Unknown package: $PACKAGE (use tui, core, or app)"
            exit 1
            ;;
    esac
}

flake_ref() {
    echo "path:$(pwd -P)#$FLAKE_ATTR"
}

flake_path() {
    echo "path:$(pwd -P)"
}

get_current_version() {
    sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$PACKAGE_FILE" | head -1
}

get_latest_version() {
    local version=""
    case "$PACKAGE" in
        tui)
            version=$(gh api "repos/herdrdev/herdr/releases/latest" --jq '.tag_name' 2>/dev/null | sed 's/^v//' || true)
            ;;
        core | app)
            # herdr-core and herdr-app publish on releases.herdr.dev, not as GitHub releases.
            version=$(curl -fsSL "$RELEASES_URL/$PACKAGE/latest.json" | jq -r '.version' 2>/dev/null || true)
            ;;
    esac
    if [ -z "$version" ] || [ "$version" = "null" ]; then
        log_error "Failed to fetch the latest $PACKAGE version"
        exit 1
    fi
    echo "$version"
}

ensure_in_repository_root() {
    if [ ! -f "flake.nix" ] || [ ! -d "packages" ]; then
        log_error "flake.nix or packages/ not found. Run this script from the repository root."
        exit 1
    fi
}

ensure_required_tools_installed() {
    local tool
    for tool in gh nix perl curl jq; do
        command -v "$tool" >/dev/null 2>&1 || { log_error "$tool is required but not installed."; exit 1; }
    done
}

print_usage() {
    echo "Usage: $0 --package tui|core|app [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --package NAME     tui (herdr-tui), core (herdr-core), or app (herdr)"
    echo "  --version VERSION  Update to a specific version"
    echo "  --check            Only check for updates (exit 1 when one is available)"
    echo "  --current          Print the packaged version and exit"
    echo "  --latest           Print the latest upstream version and exit"
    echo "  --help             Show this help message"
}

update_version() {
    local version="$1"
    perl -0pi -e "s/version = \"[^\"]+\";/version = \"$version\";/" "$PACKAGE_FILE"
}

set_src_hash() {
    perl -0pi -e "s|(src = fetchFromGitHub \\{.*?hash = )[^;]+;|\${1}$1;|s" "$PACKAGE_FILE"
}

set_cargo_hash() {
    perl -0pi -e "s|cargoHash = [^;]+;|cargoHash = $1;|" "$PACKAGE_FILE"
}

set_zig_hash() {
    perl -0pi -e "s|(zigDeps = (?:buildPackages\\.)?zig_0_[0-9]+\\.fetchDeps \\{.*?hash = )[^;]+;|\${1}$1;|s" "$PACKAGE_FILE"
}

extract_got_hash() {
    local log_file="$1"
    sed -n 's/.*got:[[:space:]]*\(sha256-[A-Za-z0-9+\/=]*\).*/\1/p' "$log_file" | tail -1
}

expect_hash_mismatch() {
    local label="$1"
    local log_file
    log_file=$(mktemp)

    set +e
    nix build "$(flake_ref)" --no-link --print-build-logs >"$log_file" 2>&1
    local status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        log_error "Expected a hash mismatch while updating $label, but the build succeeded"
        cat "$log_file" >&2
        exit 1
    fi

    local hash
    hash=$(extract_got_hash "$log_file")
    if [ -z "$hash" ]; then
        log_error "Failed to extract replacement hash for $label"
        cat "$log_file" >&2
        exit 1
    fi

    echo "\"$hash\""
}

refresh_hashes() {
    log_info "Refreshing source hash"
    set_src_hash "$FAKE_HASH"
    set_src_hash "$(expect_hash_mismatch "source")"

    log_info "Refreshing Cargo hash"
    set_cargo_hash "$FAKE_HASH"
    set_cargo_hash "$(expect_hash_mismatch "Cargo dependencies")"

    log_info "Refreshing Zig dependency hash"
    set_zig_hash "$FAKE_HASH"
    set_zig_hash "$(expect_hash_mismatch "Zig dependencies")"
}

verify_update() {
    log_info "Building $FLAKE_ATTR"
    nix build "$(flake_ref)" --print-build-logs

    log_info "Checking $FLAKE_ATTR version"
    if [ "$PACKAGE" = app ]; then
        # The app needs a display for most commands; check the binary exists.
        test -x "./result/bin/$MAIN_PROGRAM"
    else
        "./result/bin/$MAIN_PROGRAM" --version
    fi

    if [ "$PACKAGE" = tui ]; then
        log_info "Checking upstream configuration metadata"
        ./scripts/update-config-reference.sh --check
    fi

    log_info "Evaluating flake outputs"
    nix flake check "$(flake_path)" --all-systems --no-build
}

update_flake_lock() {
    log_info "Updating flake.lock"
    nix flake update --flake "$(flake_path)"
}

main() {
    ensure_in_repository_root

    local package=""
    local target_version=""
    local mode="update"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --package) package="$2"; shift 2 ;;
            --version) target_version="$2"; shift 2 ;;
            --check) mode="check"; shift ;;
            --current) mode="current"; shift ;;
            --latest) mode="latest"; shift ;;
            --help) print_usage; exit 0 ;;
            *) log_error "Unknown option: $1"; print_usage; exit 1 ;;
        esac
    done

    if [ -z "$package" ]; then
        log_error "--package is required"
        print_usage
        exit 1
    fi
    select_package "$package"

    if [ "$mode" = current ]; then
        get_current_version
        exit 0
    fi

    ensure_required_tools_installed

    if [ "$mode" = latest ]; then
        get_latest_version
        exit 0
    fi

    local current_version latest_version
    current_version=$(get_current_version)
    latest_version=${target_version:-$(get_latest_version)}

    log_info "$FLAKE_ATTR current version: $current_version"
    log_info "$FLAKE_ATTR latest version: $latest_version"

    if [ "$current_version" = "$latest_version" ]; then
        log_info "Already up to date"
        exit 0
    fi

    if [ "$mode" = check ]; then
        log_info "Update available: $current_version -> $latest_version"
        exit 1
    fi

    log_info "Updating $FLAKE_ATTR from $current_version to $latest_version"
    update_version "$latest_version"
    refresh_hashes
    update_flake_lock
    verify_update
    git diff --stat "$PACKAGE_FILE" flake.lock 2>/dev/null || true
}

main "$@"
